import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fynso/common/themes/app_color.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../view_model/monthly_spending_view_model.dart';

class MonthlySpendingCard extends StatefulWidget {
  const MonthlySpendingCard({super.key});

  @override
  State<MonthlySpendingCard> createState() => _MonthlySpendingCardState();
}

class _MonthlySpendingCardState extends State<MonthlySpendingCard> {
  late final MonthlySpendingViewModel _vm = MonthlySpendingViewModel();
  bool _booted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_booted) return;
    _booted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token') ?? '';
      if (jwt.isNotEmpty) {
        await _vm.load(jwt: jwt);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<MonthlySpendingViewModel>(
        builder: (context, vm, _) {
          final items = vm.data?.items ?? [];
          final hasData = items.isNotEmpty;
          // y-axis max dinámico (10% margen)
          double maxY = 0;
          if (hasData) {
            for (final it in items) {
              final y = double.tryParse(it.gastoTotal) ?? 0;
              if (y > maxY) maxY = y;
            }
            maxY = (maxY <= 0) ? 1 : maxY * 1.1;
          }

          List<FlSpot> spots = [];
          if (hasData) {
            for (int i = 0; i < items.length; i++) {
              final y = double.tryParse(items[i].gastoTotal) ?? 0;
              spots.add(FlSpot(i.toDouble(), y));
            }
          } else {
            // Placeholder mínimo para evitar layout roto
            spots = const [FlSpot(0, 0)];
            maxY = 1;
          }

          String bottomLabel(int index) {
            if (!hasData) return '';
            final it = items[index];
            final s = DateFormat(
              'MMM',
              'es',
            ).format(DateTime(it.anio, it.mes, 1));
            return s[0].toUpperCase() + s.substring(1);
          }

          final last = hasData ? items.last : null;
          final pctChangeText = (last?.pctChangeFmt ?? '0.00%');
          final isUp =
              (last?.trend == 'sube' || last?.trend == 'sube_desde_cero');
          final isDown = (last?.trend == 'baja');
          final indicatorColor = isUp
              ? const Color(0xFF2E7D32)
              : (isDown ? Colors.redAccent : Colors.black54);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  const Text(
                    "Tendencia de gastos mensuales",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  // 📈 Gráfica real (últimos 7 meses)
                  SizedBox(
                    height: 180,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: (hasData ? (items.length - 1).toDouble() : 0),
                          minY: 0,
                          maxY: maxY,
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((ts) {
                                  final idx = ts.x.toInt();
                                  final label = hasData ? bottomLabel(idx) : '';
                                  final value = ts.y.toStringAsFixed(2);
                                  return LineTooltipItem(
                                    '$label\nS/ $value',
                                    const TextStyle(color: Colors.white),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (!hasData ||
                                      idx < 0 ||
                                      idx >= items.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      bottomLabel(idx),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: false,
                              color: AppColor.azulFynso,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColor.azulFynso.withOpacity(0.15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //Indicadores inferiores
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Indicador de crecimiento
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isUp
                              ? const Color(0xFFE5F6E5)
                              : (isDown
                                    ? const Color(0xFFFFE5E5)
                                    : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isUp
                                  ? Icons.arrow_upward_rounded
                                  : (isDown
                                        ? Icons.arrow_downward_rounded
                                        : Icons.remove_rounded),
                              color: indicatorColor,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              hasData ? "$pctChangeText vs mes anterior" : "",
                              style: TextStyle(
                                color: indicatorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),
                      // Eliminado el chip con fecha fija (requerido)
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
