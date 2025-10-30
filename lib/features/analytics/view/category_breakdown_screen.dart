import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fynso/common/themes/app_color.dart';
import 'package:fynso/common/utils/utils.dart' show formatMonto;
import 'package:fynso/common/ui/category_visuals.dart';
import 'package:fynso/features/analytics/view/widgets/category_breakdown_card.dart' show CategoryRow;
import 'package:fynso/features/analytics/view_model/category_breakdown_list_view_model.dart';

class CategoryBreakdownScreen extends StatefulWidget {
  const CategoryBreakdownScreen({super.key});

  @override
  State<CategoryBreakdownScreen> createState() => _CategoryBreakdownScreenState();
}

class _CategoryBreakdownScreenState extends State<CategoryBreakdownScreen> {
  late CategoryBreakdownListViewModel vm;
  bool _booted = false;

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
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token') ?? '';
      await vm.init(jwt: jwt);
    });
  }

  String _monthLabel(int y, int m) {
    final s = DateFormat('MMMM yyyy', 'es').format(DateTime(y, m, 1));
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: vm,
      child: Consumer<CategoryBreakdownListViewModel>(
        builder: (context, vm, _) {
          final data = vm.data;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Desglose por categoría'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            ),
            body: RefreshIndicator(
              onRefresh: () => vm.load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header: selector de mes simple (prev/next)
                  Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        icon: const Icon(Icons.chevron_left),
                        color: AppColor.azulFynso,
                        onPressed: vm.loading ? null : vm.prevMonth,
                      ),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: BorderSide(color: AppColor.azulFynso),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          ),
                          onPressed: null, // Si quieres un month picker, lo puedes agregar aquí
                          child: Text(_monthLabel(vm.anio, vm.mes), overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      IconButton(
                        splashRadius: 22,
                        icon: const Icon(Icons.chevron_right),
                        color: AppColor.azulFynso,
                        onPressed: vm.loading ? null : vm.nextMonth,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (vm.loading) ...[
                    const SizedBox(height: 24),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 24),
                  ] else if (vm.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(vm.error!, style: const TextStyle(color: Colors.red)),
                    ),
                  ] else if (data == null) ...[
                    const SizedBox(height: 24),
                    const Center(child: Text('Sin datos')),
                  ] else ...[
                    // Resumen de límite vs gasto total del mes
                    _SummaryLimitCard(
                      limite: data.limiteActual,
                      totalMes: data.totalMes,
                    ),
                    const SizedBox(height: 16),

                    if (data.limiteActual <= 0) ...[
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

                    // Lista completa de categorías ordenadas por gasto del mes
                    ...data.items.map((it) {
                      final icon  = CategoryVisuals.iconFor(nombre: it.nombre);
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
  final double limite;
  final double totalMes;

  const _SummaryLimitCard({
    required this.limite,
    required this.totalMes,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (limite > 0) ? (totalMes / limite).clamp(0.0, 1.0) : 0.0;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen mensual', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _kv('Gastado', 'S/.${formatMonto(totalMes)}')),
                Expanded(child: _kv('Límite',  limite > 0 ? 'S/.${formatMonto(limite)}' : '—')),
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
