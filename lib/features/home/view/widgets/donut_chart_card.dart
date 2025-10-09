import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DonutChartCard extends StatelessWidget {
  const DonutChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final categorias = [
      {
        'nombre': 'Comida',
        'valor': 1150,
        'color': Colors.red,
        'porcentaje': '40%',
      },
      {
        'nombre': 'Transporte',
        'valor': 680,
        'color': Colors.blue,
        'porcentaje': '24%',
      },
      {
        'nombre': 'Servicios',
        'valor': 520,
        'color': Colors.green,
        'porcentaje': '18%',
      },
      {
        'nombre': 'Compras',
        'valor': 350,
        'color': Colors.orange,
        'porcentaje': '12%',
      },
      {
        'nombre': 'Otros',
        'valor': 147,
        'color': Colors.grey,
        'porcentaje': '6%',
      },
    ];

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Gastos por Categoría",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Enero 2025",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: PieChart(
                    PieChartData(
                      sections: categorias
                          .map(
                            (cat) => PieChartSectionData(
                              value: (cat['valor'] as int).toDouble(),
                              color: cat['color'] as Color,
                              showTitle: false,
                            ),
                          )
                          .toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categorias
                        .map(
                          (cat) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: cat['color'] as Color,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(cat['nombre'] as String)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'S/. ${cat['valor']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      cat['porcentaje'] as String,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
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
