import 'package:flutter/material.dart';
import 'package:fynso/common/widgets/custom_text_title.dart';
import 'package:fynso/features/analytics/view/widgets/category_breakdown_card.dart';
import 'package:fynso/features/analytics/view/widgets/category_status_cards_widget.dart';
import 'package:fynso/features/analytics/view/widgets/monthly_spending_card.dart';
import 'package:fynso/features/analytics/view/widgets/recommendations_card.dart';
import 'package:fynso/features/analytics/view/widgets/premium_lock_screen.dart';
import 'package:fynso/data/repositories/premium_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedPeriod = "Mes"; // Valor inicial
  bool _isCheckingPremium = true;
  bool _isPremium = false;
  final PremiumRepository _premiumRepo = PremiumRepository();

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token') ?? '';
      
      if (jwt.isEmpty) {
        setState(() {
          _isCheckingPremium = false;
          _isPremium = false;
        });
        return;
      }

      final status = await _premiumRepo.verificarEstadoPremium(jwt: jwt);
      setState(() {
        _isPremium = status.isPremium;
        _isCheckingPremium = false;
      });
    } catch (e) {
      print('Error al verificar estado premium: $e');
      setState(() {
        _isCheckingPremium = false;
        _isPremium = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isCheckingPremium
          ? const Center(child: CircularProgressIndicator())
          : !_isPremium
              ? PremiumLockScreen(
                  onUpgradePressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ve a la pestaña de Configuración para actualizar a Premium',
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                )
              : SingleChildScrollView(
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
