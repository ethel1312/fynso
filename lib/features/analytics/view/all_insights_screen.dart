import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view_model/insights_view_model.dart';
import 'widgets/insight_card.dart';

class AllInsightsScreen extends StatefulWidget {
  const AllInsightsScreen({super.key});

  @override
  State<AllInsightsScreen> createState() => _AllInsightsScreenState();
}

class _AllInsightsScreenState extends State<AllInsightsScreen> {
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
        await _vm.load(jwt: jwt, limit: 50); // Cargar todas las recomendaciones
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Recomendaciones con IA',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: _vm,
        child: Consumer<InsightsViewModel>(
          builder: (context, vm, _) {
            final items = vm.data?.items ?? [];
            final hasData = items.isNotEmpty;

            if (vm.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        vm.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lightbulb_outline, color: Colors.grey, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'No hay recomendaciones disponibles',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isTopThree = index < 3;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Etiqueta para las 3 primeras
                    if (isTopThree && index == 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.star,
                              color: Color(0xFFFFB300),
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Recomendaciones más importantes',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Separador después de las top 3
                    if (index == 3)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 8),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Más recomendaciones',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Tarjeta con borde dorado para top 3
                    Container(
                      decoration: isTopThree
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            )
                          : null,
                      child: InsightCard(
                        color: item.color,
                        icon: item.icon,
                        title: item.title,
                        message1: item.body,
                        message2: '',
                        iconColor: item.iconColor,
                      ),
                    ),

                    if (index < items.length - 1) const SizedBox(height: 12),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
