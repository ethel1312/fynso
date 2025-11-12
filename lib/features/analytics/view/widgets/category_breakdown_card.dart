import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fynso/features/analytics/view_model/category_breakdown_view_model.dart';
import 'package:fynso/common/utils/utils.dart' show formatMonto;
import 'package:fynso/common/ui/category_visuals.dart';
import 'package:fynso/common/ui/category_badge.dart';

class CategoryBreakdownCard extends StatefulWidget {
  final VoidCallback? onVerTodo;

  /// Por si más adelante quieres controlar el periodo desde afuera:
  final int? anio;
  final int? mes;
  final int top;

  const CategoryBreakdownCard({
    super.key,
    this.onVerTodo,
    this.anio,
    this.mes,
    this.top = 5,
  });

  @override
  State<CategoryBreakdownCard> createState() => _CategoryBreakdownCardState();
}

class _CategoryBreakdownCardState extends State<CategoryBreakdownCard> {
  late CategoryBreakdownViewModel vm;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    vm = CategoryBreakdownViewModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token') ?? '';

      final now = DateTime.now();
      final anio = widget.anio ?? now.year;
      final mes = widget.mes ?? now.month;

      await vm.load(jwt: jwt, anio: anio, mes: mes, top: widget.top);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: vm,
      child: Consumer<CategoryBreakdownViewModel>(
        builder: (context, vm, _) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con título + "Ver Todo"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Desglose por categoría",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed:
                            widget.onVerTodo ??
                            () => Navigator.pushNamed(
                              context,
                              '/desgloseCategorias',
                            ),
                        child: const Text("Ver Todo"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (vm.loading) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ] else if (vm.error != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        vm.error!,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ] else if (vm.data == null || vm.data!.topItems.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text('Sin gastos este mes'),
                    ),
                  ] else ...[
                    // Nota si el límite es 0
                    if ((vm.data?.limiteActual ?? 0) <= 0) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Configura tu límite mensual para ver barras comparativas',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],

                    // Filas dinámicas (top N)
                    ...vm.data!.topItems.map((it) {
                      final icon = CategoryVisuals.iconFor(nombre: it.nombre);
                      final color = CategoryVisuals.colorFor(nombre: it.nombre);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CategoryRow(
                          icono: icon,
                          nombre: it.nombre,
                          monto: it.montoMes,
                          esteMes: it.ratioMes.clamp(0.0, 1.0),
                          mesAnterior: it.ratioMesAnterior.clamp(0.0, 1.0),
                          color: color,
                        ),
                      );
                    }).toList(),
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

// ==================== Sub-widgets ====================

class CategoryRow extends StatelessWidget {
  final IconData icono;
  final String nombre;
  final double monto;
  final double esteMes;
  final double mesAnterior;
  final Color color;

  const CategoryRow({
    super.key,
    required this.icono,
    required this.nombre,
    required this.monto,
    required this.esteMes,
    required this.mesAnterior,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila principal con ícono, nombre y monto
        Row(
          children: [
            CategoryBadge(icon: icono, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                nombre,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "S/.${formatMonto(monto)}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Barras comparativas
        CategoryBar(etiqueta: "Este mes", valor: esteMes, color: color),
        const SizedBox(height: 6),
        CategoryBar(
          etiqueta: "Mes anterior",
          valor: mesAnterior,
          color: Colors.grey,
        ),
      ],
    );
  }
}

class CategoryBar extends StatelessWidget {
  final String etiqueta;
  final double valor;
  final Color color;

  const CategoryBar({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            FractionallySizedBox(
              widthFactor: valor.isNaN ? 0 : valor.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
