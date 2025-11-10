// lib/features/home/view/widgets/donut_chart_card.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../view_model/donut_chart_view_model.dart';

class DonutChartCard extends StatefulWidget {
  const DonutChartCard({super.key});

  @override
  State<DonutChartCard> createState() => _DonutChartCardState();
}

class _DonutChartCardState extends State<DonutChartCard> {
  late final DonutChartViewModel _vm = DonutChartViewModel();
  bool _requested = false;

  Future<String?> _getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  String _monthNameES(int mes) {
    const meses = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    if (mes < 1 || mes > 12) return '';
    return meses[mes];
  }

  @override
  void initState() {
    super.initState();
    // Dispara la carga una sola vez con año/mes locales
    Future.microtask(() async {
      if (_requested) return;
      _requested = true;
      final jwt = await _getJwtToken();
      if (jwt != null && jwt.isNotEmpty) {
        final now = DateTime.now();
        await _vm.load(jwt: jwt, year: now.year, month: now.month);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<DonutChartViewModel>(
        builder: (context, vm, _) {
          final tituloMes = (vm.mes > 0 && vm.anio > 0)
              ? '${_monthNameES(vm.mes)} ${vm.anio}'
              : '';

          Widget body;
          if (vm.isLoading) {
            body = const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            );
          } else if (vm.error != null) {
            body = Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(vm.error!, style: const TextStyle(color: Colors.red)),
            );
          } else if (vm.items.isEmpty) {
            body = const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Sin datos este mes'),
            );
          } else {
            body = Row(
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: PieChart(
                    PieChartData(
                      sections: vm.items.asMap().entries.map((entry) {
                        final i = entry.key;
                        final cat = entry.value;
                        return PieChartSectionData(
                          value: cat.montoDouble,
                          // usa monto del backend
                          color: vm.colorForIndex(i),
                          // colores fijos por índice (Resto=gris)
                          showTitle: false,
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: vm.items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final cat = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: vm.colorForIndex(
                                i,
                              ), // mismo color que el chart
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(cat.nombre)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'S/. ${cat.monto}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  cat.porcentajeFmt,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Gastos por Categoría",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        tituloMes,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  body,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
