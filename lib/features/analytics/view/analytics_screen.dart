import 'package:flutter/material.dart';
import 'package:fynso/common/widgets/custom_text_title.dart';
import 'package:fynso/features/analytics/view/widgets/category_breakdown_card.dart';
import 'package:fynso/features/analytics/view/widgets/category_status_card.dart';
import 'package:fynso/features/analytics/view/widgets/insight_card.dart';
import 'package:fynso/features/analytics/view/widgets/monthly_spending_card.dart';
import 'package:fynso/features/analytics/view/widgets/period_button.dart';

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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARD: Recomendaciones con IA
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: const Color(0xFFFFF4CC),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFFFFB300),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Recomendaciones con IA",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // TARJETAS INTERNAS
                    const InsightCard(
                      color: Color(0xFFFFE5E5),
                      icon: Icons.warning_amber_rounded,
                      title: "Alerta de gasto alto",
                      message1: "Gastaste 25% más en comida esta semana.",
                      message2:
                          "Considera planificar tus comidas para reducir gastos.",
                      iconColor: Colors.redAccent,
                    ),

                    const SizedBox(height: 12),

                    const InsightCard(
                      color: Color(0xFFE5F6E5),
                      icon: Icons.trending_up_rounded,
                      title: "¡Buen progreso!",
                      message1: "Tus costos en transporte bajaron un 15%.",
                      message2: "Sigue usando transporte público.",
                      iconColor: Colors.green,
                    ),

                    const SizedBox(height: 12),

                    const InsightCard(
                      color: Color(0xFFEDE5FF),
                      icon: Icons.flag_rounded,
                      title: "Meta de presupuesto",
                      message1: "Has alcanzado el 81% de tu meta mensual.",
                      message2: "Aún puedes gastar S/653 este mes.",
                      iconColor: Colors.deepPurple,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CARD: Tendencia de gastos mensuales
            MonthlySpendingCard(),

            SizedBox(height: 20),

            CategoryBreakdownCard(),

            SizedBox(height: 20),

            Row(
              children: const [
                CategoryStatusCard(
                  title: 'Mejor categoría',
                  category: 'Transporte',
                  percentage: '-15% ahorrado',
                  color: Color(0xFF4CAF50),
                  icon: Icons.trending_up_rounded,
                ),
                SizedBox(width: 12),
                CategoryStatusCard(
                  title: 'Requiere atención',
                  category: 'Comida',
                  percentage: '+25% más gasto',
                  color: Color(0xFFE53935),
                  icon: Icons.warning_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
