import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view_model/insights_view_model.dart';
import '../all_insights_screen.dart';
import 'insight_card.dart';

class RecommendationsCard extends StatefulWidget {
  const RecommendationsCard({super.key});

  @override
  State<RecommendationsCard> createState() => _RecommendationsCardState();
}

class _RecommendationsCardState extends State<RecommendationsCard> {
  late final InsightsViewModel _vm = InsightsViewModel();
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
        await _vm.load(jwt: jwt, limit: 3);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<InsightsViewModel>(
        builder: (context, vm, _) {
          final items = vm.data?.items ?? [];
          final hasData = items.isNotEmpty;

          return InkWell(
            onTap: hasData
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AllInsightsScreen(),
                      ),
                    );
                  }
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Card(
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
                            color: Color(0xFFFFF4CC),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFFFFB300),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Recomendaciones con IA",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (hasData)
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.grey,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // TARJETAS INTERNAS
                    if (vm.loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (vm.error != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            vm.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      )
                    else if (!hasData)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No hay recomendaciones disponibles'),
                        ),
                      )
                    else
                      ...items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: idx < items.length - 1 ? 12 : 0,
                          ),
                          child: InsightCard(
                            color: item.color,
                            icon: item.icon,
                            title: item.title,
                            message1: item.body,
                            message2: '',
                            iconColor: item.iconColor,
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}




