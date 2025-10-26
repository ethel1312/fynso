import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fynso/common/themes/app_color.dart';

class MonthlySpendingCard extends StatelessWidget {
  const MonthlySpendingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    maxX: 6,
                    minY: 0,
                    maxY: 5,
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
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
                          interval: 1, // 👈 muestra solo un mes por punto
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            const months = [
                              'Ago',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dic',
                              'Ene',
                              'Feb',
                            ];
                            if (value >= 0 && value < months.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  months[value.toInt()],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 2.1),
                          FlSpot(1, 2.8),
                          FlSpot(2, 2.3),
                          FlSpot(3, 3.2),
                          FlSpot(4, 3.6),
                          FlSpot(5, 4.0),
                          FlSpot(6, 4.4),
                        ],
                        isCurved: true,
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
                    color: const Color(0xFFE5F6E5), // verde claro
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.arrow_upward_rounded,
                        color: Color(0xFF2E7D32), // verde oscuro
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "+8.5% vs mes anterior",
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Fecha del reporte
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Enero 2025",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
