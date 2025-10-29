import 'package:flutter/material.dart';
import 'package:fynso/common/widgets/custom_text_title.dart';
import 'package:fynso/features/home/view/widgets/add_button.dart';
import 'package:fynso/features/home/view/widgets/donut_chart_card.dart';
import 'package:fynso/features/home/view/widgets/summary_card.dart';
import 'package:fynso/features/home/view/widgets/transactions_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fynso/data/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<String?> _firstNameFuture;

  Future<String?> _loadFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null || jwt.isEmpty) return null;

    final svc = UserService();
    return await svc.getFirstName(jwt);
  }

  @override
  void initState() {
    super.initState();
    _firstNameFuture = _loadFirstName();
  }

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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna con textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String?>(
                          future: _firstNameFuture,
                          builder: (context, snap) {
                            final saludo = (snap.connectionState == ConnectionState.done &&
                                snap.hasData &&
                                (snap.data ?? '').isNotEmpty)
                                ? "Hola, ${snap.data}!"
                                : "Hola!";
                            return CustomTextTitle(saludo);
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Controla tus gastos sabiamente",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const AddButton(),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SummaryCard(),
            const SizedBox(height: 20),
            DonutChartCard(),
            const SizedBox(height: 20),
            const TransactionsCard(),
          ],
        ),
      ),
    );
  }
}
