import 'package:flutter/material.dart';
import 'package:fynso/features/home/view/widgets/add_button.dart';
import 'package:fynso/features/home/view/widgets/comparison_cards.dart';
import 'package:fynso/features/home/view/widgets/donut_chart_card.dart';
import 'package:fynso/features/home/view/widgets/summary_card.dart';
import 'package:fynso/features/home/view/widgets/transactions_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
              // más espacio arriba
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna con textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hola, Isamar!",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Controla tus gastos sabiamente",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  // Botón a la derecha
                  const AddButton(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARD: Total Spent
            SummaryCard(),

            const SizedBox(height: 20),

            // CARD: Gráfica de anillo
            DonutChartCard(),

            const SizedBox(height: 20),

            // CARD: Transacciones recientes
            const TransactionsCard(),

            // const SizedBox(height: 20),

            // DOS CARDS PEQUEÑAS LADO A LADO
            // const ComparisonCards(),
          ],
        ),
      ),
    );
  }
}
