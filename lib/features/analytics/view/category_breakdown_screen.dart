import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fynso/common/themes/app_color.dart';
import 'package:fynso/common/utils/utils.dart' show formatMonto;
import 'package:fynso/common/ui/category_visuals.dart';
import 'package:fynso/features/analytics/view/widgets/category_breakdown_card.dart'
    show CategoryRow;
import 'package:fynso/features/analytics/view_model/category_breakdown_list_view_model.dart';

class CategoryBreakdownScreen extends StatefulWidget {
  const CategoryBreakdownScreen({super.key});

  @override
  State<CategoryBreakdownScreen> createState() =>
      _CategoryBreakdownScreenState();
}

class _YearMonth {
  final int year;
  final int month;

  const _YearMonth(this.year, this.month);
}

class _CategoryBreakdownScreenState extends State<CategoryBreakdownScreen> {
  late CategoryBreakdownListViewModel vm;
  bool _booted = false;

  // ✅ Evita parpadeo “Sin datos”: loader a pantalla completa hasta terminar init()
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    vm = CategoryBreakdownListViewModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_booted) return;
    _booted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _initializing = true);
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token') ?? '';
      await vm.init(jwt: jwt);
      if (mounted) setState(() => _initializing = false);
    });
  }

  String _monthLabel(int y, int m) {
    final s = DateFormat('MMMM yyyy', 'es').format(DateTime(y, m, 1));
    return s[0].toUpperCase() + s.substring(1);
  }

  // ===== Month Picker helpers =====
  int _ymCompare(int y1, int m1, int y2, int m2) {
    if (y1 != y2) return y1.compareTo(y2);
    return m1.compareTo(m2);
  }

  bool _isMonthInRange({
    required int year,
    required int month,
    required int minY,
    required int minM,
    required int maxY,
    required int maxM,
  }) {
    final lo = _ymCompare(year, month, minY, minM) >= 0;
    final hi = _ymCompare(year, month, maxY, maxM) <= 0;
    return lo && hi;
  }

  Future<void> _openMonthSheet() async {
    if (!mounted) return;

    final range = vm.allowedRangeForPicker();
    final minY = range['minY']!;
    final minM = range['minM']!;
    final maxY = range['maxY']!;
    final maxM = range['maxM']!;

    int tempYear = vm.anio;

    final picked = await showModalBottomSheet<_YearMonth>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: StatefulBuilder(
                builder: (ctx, setStateSheet) {
                  final months = List<int>.generate(12, (i) => i + 1);

                  bool isEnabled(int y, int m) => _isMonthInRange(
                    year: y,
                    month: m,
                    minY: minY,
                    minM: minM,
                    maxY: maxY,
                    maxM: maxM,
                  );

                  String monthName(int m) => DateFormat(
                    'MMM',
                    'es',
                  ).format(DateTime(2000, m, 1)).toUpperCase();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            splashRadius: 20,
                            onPressed:
                                _ymCompare(tempYear - 1, 12, minY, minM) >= 0
                                ? () => setStateSheet(() => tempYear -= 1)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            color: AppColor.azulFynso,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '$tempYear',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            splashRadius: 20,
                            onPressed:
                                _ymCompare(tempYear + 1, 1, maxY, maxM) <= 0
                                ? () => setStateSheet(() => tempYear += 1)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            color: AppColor.azulFynso,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.4,
                        children: [
                          for (final m in months)
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: isEnabled(tempYear, m)
                                    ? AppColor.azulFynso
                                    : Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              onPressed: isEnabled(tempYear, m)
                                  ? () => Navigator.pop(
                                      ctx,
                                      _YearMonth(tempYear, m),
                                    )
                                  : null,
                              child: Text(monthName(m)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _initializing = true); // loader mientras recarga
      vm.anio = picked.year;
      vm.mes = picked.month;
      await vm.load();
      if (mounted) setState(() => _initializing = false);
    }
  }

  bool _isFutureMonth(int y, int m) {
    final now = DateTime.now();
    final cur = DateTime(now.year, now.month, 1);
    final sel = DateTime(y, m, 1);
    return sel.isAfter(cur);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: vm,
      child: Consumer<CategoryBreakdownListViewModel>(
        builder: (context, vm, _) {
          // ✅ Loader a pantalla completa hasta que termine init()/load()
          if (_initializing) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Desglose por categoría'),
                elevation: 1,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final data = vm.data;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Desglose por categoría'),
              elevation: 1,
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                setState(() => _initializing = true);
                await vm.load();
                if (mounted) setState(() => _initializing = false);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ===== Header con flechas + picker (respetando el rango permitido) =====
                  Builder(
                    builder: (ctx) {
                      final r = vm.allowedRangeForPicker();
                      final minY = r['minY']!, minM = r['minM']!;
                      final maxY = r['maxY']!, maxM = r['maxM']!;
                      bool canPrev =
                          _ymCompare(vm.anio, vm.mes, minY, minM) > 0;
                      bool canNext =
                          _ymCompare(vm.anio, vm.mes, maxY, maxM) < 0;

                      return Row(
                        children: [
                          IconButton(
                            splashRadius: 22,
                            icon: const Icon(Icons.chevron_left),
                            color: canPrev ? AppColor.azulFynso : Colors.grey,
                            onPressed: (!vm.loading && canPrev)
                                ? () async {
                                    setState(() => _initializing = true);
                                    final m = vm.mes == 1 ? 12 : vm.mes - 1;
                                    final y = vm.mes == 1
                                        ? vm.anio - 1
                                        : vm.anio;
                                    vm.anio = y;
                                    vm.mes = m;
                                    await vm.load();
                                    if (mounted)
                                      setState(() => _initializing = false);
                                  }
                                : null,
                          ),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColor.azulFynso),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                              ),
                              onPressed: vm.loading ? null : _openMonthSheet,
                              child: Text(
                                _monthLabel(vm.anio, vm.mes),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          IconButton(
                            splashRadius: 22,
                            icon: const Icon(Icons.chevron_right),
                            color: canNext ? AppColor.azulFynso : Colors.grey,
                            onPressed: (!vm.loading && canNext)
                                ? () async {
                                    setState(() => _initializing = true);
                                    final m = vm.mes == 12 ? 1 : vm.mes + 1;
                                    final y = vm.mes == 12
                                        ? vm.anio + 1
                                        : vm.anio;
                                    vm.anio = y;
                                    vm.mes = m;
                                    await vm.load();
                                    if (mounted)
                                      setState(() => _initializing = false);
                                  }
                                : null,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  if (vm.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        vm.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ] else if (data == null) ...[
                    const SizedBox(height: 24),
                    const Center(child: Text('Sin datos')),
                  ] else ...[
                    // ===== Resumen mensual (usa límite actual si existe; si es futuro y el usuario tiene default, NO mostramos banner) =====
                    _SummaryLimitCard(
                      limite: data.limiteActual,
                      // puede ser null => mostramos "—" en el label
                      totalMes: data.totalMes,
                    ),
                    const SizedBox(height: 16),

                    // Banner "Configura tu límite..." SOLO si NO hay límite en meses actuales/pasados
                    // y también en futuros cuando NO existe default_monthly_limit
                    if (!(_isFutureMonth(vm.anio, vm.mes) &&
                            vm.hasUserDefaultLimit) &&
                        ((data.limiteActual ?? 0) <= 0)) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Configura tu límite mensual para ver barras comparativas',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],

                    // Lista completa de categorías (orden ya llega por monto_mes)
                    ...data.items.map((it) {
                      final icon = CategoryVisuals.iconFor(nombre: it.nombre);
                      final color = CategoryVisuals.colorFor(nombre: it.nombre);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CategoryRow(
                          icono: icon,
                          nombre: it.nombre,
                          monto: it.montoMes,
                          esteMes: it.ratioMes.clamp(0.0, 1.0),
                          mesAnterior: it.ratioMesAnterior.clamp(0.0, 1.0),
                          color: color,
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------- Widgets auxiliares -------

class _SummaryLimitCard extends StatelessWidget {
  final double? limite; // puede ser null
  final double totalMes;

  const _SummaryLimitCard({required this.limite, required this.totalMes});

  @override
  Widget build(BuildContext context) {
    final lim = limite ?? 0;
    final ratio = (lim > 0) ? (totalMes / lim).clamp(0.0, 1.0) : 0.0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen mensual',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _kv('Gastado', 'S/.${formatMonto(totalMes)}')),
                Expanded(
                  child: _kv(
                    'Límite',
                    (limite == null) ? '—' : 'S/.${formatMonto(lim)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio.isNaN ? 0 : ratio,
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                color: AppColor.azulFynso,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 2),
        Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
