import 'package:flutter/material.dart';
import 'package:fynso/common/widgets/custom_text_title.dart';
import 'package:fynso/features/analytics/view/widgets/category_breakdown_card.dart';
import 'package:fynso/features/analytics/view/widgets/category_status_cards_widget.dart';
import 'package:fynso/features/analytics/view/widgets/monthly_spending_card.dart';
import 'package:fynso/features/analytics/view/widgets/recommendations_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedPeriod = "Mes"; // Valor inicial

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
                        CustomTextTitle("Analíticas"),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  // Botón a la derecha
                  // BOTONES PERIOD
                  /*
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PeriodButton(
                        label: "Mes",
                        selected: selectedPeriod == "Mes",
                        onTap: () => setState(() => selectedPeriod = "Mes"),
                      ),
                      const SizedBox(width: 8),
                      PeriodButton(
                        label: "Year",
                        selected: selectedPeriod == "Year",
                        onTap: () => setState(() => selectedPeriod = "Year"),
                      ),
                    ],
                  )*/
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARD: Recomendaciones con IA (dinámico)
            const RecommendationsCard(),

            const SizedBox(height: 20),

            // CARD: Tendencia de gastos mensuales
            MonthlySpendingCard(),

            SizedBox(height: 20),

            CategoryBreakdownCard(),

            SizedBox(height: 20),

            // Tarjetas de categorías dinámicas
            CategoryStatusCardsWidget(),
          ],
        ),
      ),
    );
  }
}
