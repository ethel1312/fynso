import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view_model/category_status_view_model.dart';
import 'category_status_card.dart';

class CategoryStatusCardsWidget extends StatefulWidget {
  const CategoryStatusCardsWidget({super.key});

  @override
  State<CategoryStatusCardsWidget> createState() =>
      _CategoryStatusCardsWidgetState();
}

class _CategoryStatusCardsWidgetState extends State<CategoryStatusCardsWidget> {
  late final CategoryStatusViewModel _vm = CategoryStatusViewModel();
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
        // Cargar con parámetros por defecto (mes actual)
        await _vm.load(jwt: jwt);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<CategoryStatusViewModel>(
        builder: (context, vm, _) {
          // Estado de carga
          if (vm.loading) {
            return Row(
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    elevation: 3,
                    child: const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    elevation: 3,
                    child: const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Estado de error
          if (vm.error != null) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Error: ${vm.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          // Sin datos
          if (vm.data == null) {
            return const SizedBox.shrink();
          }

          final cards = vm.data!.cards;

          return Row(
            children: [
              CategoryStatusCard(
                title: cards.best.title,
                category: cards.best.category,
                percentage: cards.best.percentage,
                color: cards.best.color,
                icon: cards.best.icon,
              ),
              const SizedBox(width: 12),
              CategoryStatusCard(
                title: cards.attention.title,
                category: cards.attention.category,
                percentage: cards.attention.percentage,
                color: cards.attention.color,
                icon: cards.attention.icon,
              ),
            ],
          );
        },
      ),
    );
  }
}
