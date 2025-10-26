import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/themes/app_color.dart';
import '../../view_model/monthly_summary_view_model.dart';
import '../../../../common/widgets/custom_textfield.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/utils/timezone.dart'; // 👈 NUEVO

class SummaryCard extends StatefulWidget {
  const SummaryCard({super.key});

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> with WidgetsBindingObserver {
  late final MonthlySummaryViewModel _vm = MonthlySummaryViewModel();
  bool _bootstrapped = false;
  bool _reconciling = false;

  // Cacheamos TZ en SharedPreferences para evitar pedirla a cada rato
  static const _kTzName = 'tz_name_cache';

  Future<String?> _getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<String> _getDeviceTz() async {
    final sp = await SharedPreferences.getInstance();
    final cached = sp.getString(_kTzName);
    if (cached != null && cached.isNotEmpty) return cached;

    final tz = await TimezoneUtil.deviceTimeZone();
    await sp.setString(_kTzName, tz);
    return tz;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Al crear: reconciliar y cargar usando TZ real del dispositivo
    Future.microtask(() async {
      if (_bootstrapped) return;
      _bootstrapped = true;
      final jwt = await _getJwt();
      if (jwt != null && jwt.isNotEmpty) {
        final tzName = await _getDeviceTz(); // 👈 TZ real
        await _vm.reconcileOnAppOpen(jwt: jwt, tzName: tzName);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Reconciliar cuando la app vuelve a primer plano (por si pasó la medianoche, días, meses, etc.)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (_reconciling) return;
      _reconciling = true;
      final jwt = await _getJwt();
      if (jwt != null && jwt.isNotEmpty) {
        final tzName = await _getDeviceTz(); // 👈 TZ real
        await _vm.reconcileOnAppOpen(jwt: jwt, tzName: tzName);
      }
      _reconciling = false;
    }
  }

  Future<void> _openEditLimitSheet(BuildContext context, MonthlySummaryViewModel vm) async {
    if (vm.isClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mes cerrado: no es posible editar el límite')),
      );
      return;
    }

    final controller = TextEditingController(
      text: vm.hasBudget ? vm.limite.toStringAsFixed(2) : '',
    );

    // Cargar estado del switch "predeterminado"
    final prefs = await vm.getCarryOverPrefs();
    bool carryOverEnabled = prefs.$1;
    if (!vm.hasBudget && (controller.text.isEmpty) && prefs.$2 > 0) {
      controller.text = prefs.$2.toStringAsFixed(2);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (ctx, setStateSheet) {
              return ChangeNotifierProvider.value(
                value: _vm,
                child: Consumer<MonthlySummaryViewModel>(
                  builder: (_, vm2, __) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Establecer límite mensual',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Límite (S/.)',
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          title: const Text('Usar este límite como predeterminado para próximos meses'),
                          value: carryOverEnabled,
                          onChanged: (v) => setStateSheet(() => carryOverEnabled = v),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: vm2.isSaving ? 'Guardando...' : 'Guardar',
                                backgroundColor: AppColor.azulFynso,
                                onPressed: vm2.isSaving ? null : () async {
                                  final raw = controller.text.trim().replaceAll(',', '.');
                                  final value = double.tryParse(raw);
                                  if (value == null || value <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Ingresa un monto válido > 0')),
                                    );
                                    return;
                                  }
                                  final jwt = await _getJwt();
                                  if (jwt == null || jwt.isEmpty || vm2.summary == null) return;

                                  // 1) Guarda límite del mes actual
                                  final ok = await vm2.setLimit(
                                    jwt: jwt,
                                    anio: vm2.summary!.anio,
                                    mes: vm2.summary!.mes,
                                    limite: value,
                                  );

                                  // 2) Guarda preferencia local del predeterminado
                                  await vm2.setCarryOverPrefs(enabled: carryOverEnabled, defaultLimit: value);

                                  if (ok && mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(
                                        carryOverEnabled
                                            ? 'Límite guardado y marcado como predeterminado'
                                            : 'Límite guardado',
                                      )),
                                    );
                                  } else if (!ok && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(vm2.error ?? 'No se pudo guardar')),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<MonthlySummaryViewModel>(
        builder: (context, vm, _) {
          final hasData = vm.summary != null && vm.error == null;

          final totalTxt   = hasData ? 'S/. ${vm.gastado.toStringAsFixed(2)}' : 'S/. --';
          final limiteTxt  = hasData && vm.hasBudget ? 'S/. ${vm.limite.toStringAsFixed(2)}' : '—';
          final restanteTxt= hasData && vm.hasBudget ? 'S/. ${vm.restante.toStringAsFixed(2)}' : '—';
          final footerTxt  = hasData
              ? '${vm.percentUsedLabel} - ${vm.daysRemaining()} días restantes'
              : (vm.isLoading ? 'Cargando...' : (vm.error ?? '—'));

          return InkWell(
            onTap: hasData ? () => _openEditLimitSheet(context, vm) : null,
            borderRadius: BorderRadius.circular(16),
            child: Card(
              color: AppColor.azulFynso,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: vm.isLoading && !hasData
                    ? const SizedBox(
                  height: 96,
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Gastado este Mes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      totalTxt,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Presupuesto: $limiteTxt",
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Restante: $restanteTxt",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: vm.progress,
                      color: Colors.black,
                      backgroundColor: Colors.white24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      footerTxt,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (hasData && !vm.hasBudget) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Toca para establecer tu presupuesto mensual',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
