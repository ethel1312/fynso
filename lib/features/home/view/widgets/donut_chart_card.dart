import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DonutChartCard extends StatelessWidget {
  const DonutChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Gasto por Categoría",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 1150,
                      color: Colors.blue,
                      title: "Comida\n40%",
                    ),
                    PieChartSectionData(
                      value: 680,
                      color: Colors.green,
                      title: "Transporte\n24%",
                    ),
                    PieChartSectionData(
                      value: 520,
                      color: Colors.orange,
                      title: "Servicios\n18%",
                    ),
                    PieChartSectionData(
                      value: 350,
                      color: Colors.purple,
                      title: "Compras\n12%",
                    ),
                    PieChartSectionData(
                      value: 147,
                      color: Colors.red,
                      title: "Otros\n6%",
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
