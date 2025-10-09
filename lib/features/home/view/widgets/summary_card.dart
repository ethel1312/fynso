import 'package:flutter/material.dart';
import 'package:fynso/common/themes/app_color.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColor.azulFynso, // Card azul
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Total Gastado este Mes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white, // letra blanca
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "S/.2,847",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // letra blanca
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Presupuesto: S/.3,500",
                  style: TextStyle(color: Colors.white), // letra blanca
                ),
                Text(
                  "Restante: S/.653",
                  style: TextStyle(color: Colors.white), // letra blanca
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.813,
              color: Colors.black, // barra de progreso negra
              backgroundColor: Colors.white24, // fondo más claro
            ),
            const SizedBox(height: 4),
            const Text(
              "81.3% usado - 9 días restantes",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
