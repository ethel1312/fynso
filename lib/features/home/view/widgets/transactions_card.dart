import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/utils/utils.dart'; // para formatMonto si lo usas
import '../../../agregar/view/historial_gastos_screen.dart'; // solo por el route name si lo usas directo
import '../../view_model/recent_transactions_view_model.dart';
import '../../../../data/models/transaction_response.dart';

class TransactionsCard extends StatefulWidget {
  const TransactionsCard({super.key});

  @override
  State<TransactionsCard> createState() => _TransactionsCardState();
}

class _TransactionsCardState extends State<TransactionsCard> {
  late RecentTransactionsViewModel vm;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    vm = RecentTransactionsViewModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final prefs = await SharedPreferences.getInstance();
        final jwt = prefs.getString('jwt_token') ?? '';
        await vm.load(jwt: jwt, limit: 5);
      });
    }
  }

  String _dateLabel(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      bool sameDay(DateTime a, DateTime b) =>
          a.year == b.year && a.month == b.month && a.day == b.day;

      if (sameDay(d, now)) return 'Hoy';
      if (sameDay(d, now.subtract(const Duration(days: 1)))) return 'Ayer';
      // Ej: 07 oct
      return DateFormat('dd MMM', 'es').format(d);
    } catch (_) {
      return '';
    }
  }

  String _titleFor(TransactionResponse t) {
    // Prioridad: descripcion > lugar > subcategoria > categoria
    if (t.descripcion.trim().isNotEmpty) return t.descripcion.trim();
    if ((t.lugar ?? '').trim().isNotEmpty) return t.lugar!.trim();
    if (t.subcategory.trim().isNotEmpty) return t.subcategory.trim();
    return t.category.trim();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: vm,
      child: Consumer<RecentTransactionsViewModel>(
        builder: (context, vm, _) {
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Transacciones Recientes",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/historialGastos');
                        },
                        child: const Text("Ver Todo"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (vm.isLoading) ...[
                    const SizedBox(height: 8),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 8),
                  ] else if (vm.error != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        vm.error!,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ] else if (vm.items.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text('Sin transacciones este mes'),
                    ),
                  ] else ...[
                    // Lista de transacciones (mantenemos tu diseño)
                    ...vm.items.map((t) => _TransactionRow(
                      title: _titleFor(t),
                      category: t.category,
                      dateLabel: _dateLabel(t.fecha),
                      amountLabel: "S/.${formatMonto(t.monto)}",
                    )),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String title;
  final String category;
  final String dateLabel;
  final String amountLabel;

  const _TransactionRow({
    required this.title,
    required this.category,
    required this.dateLabel,
    required this.amountLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Izquierda: título + categoría
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                category,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          // Derecha: fecha corta + monto
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateLabel,
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                amountLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
