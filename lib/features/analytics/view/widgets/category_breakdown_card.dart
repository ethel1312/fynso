import 'package:flutter/material.dart';
import 'package:fynso/common/themes/app_color.dart';

class CategoryBreakdownCard extends StatelessWidget {
  const CategoryBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Desglose por categoría",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            CategoryRow(
              icono: Icons.fastfood_rounded,
              nombre: "Comida",
              monto: 1150,
              esteMes: 0.85,
              mesAnterior: 0.75,
              color: AppColor.azulFynso,
            ),
            SizedBox(height: 16),
            CategoryRow(
              icono: Icons.directions_car_rounded,
              nombre: "Transporte",
              monto: 680,
              esteMes: 0.65,
              mesAnterior: 0.55,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            CategoryRow(
              icono: Icons.lightbulb_rounded,
              nombre: "Servicios",
              monto: 520,
              esteMes: 0.55,
              mesAnterior: 0.50,
              color: Colors.amber,
            ),
            SizedBox(height: 16),
            CategoryRow(
              icono: Icons.shopping_bag_rounded,
              nombre: "Compras",
              monto: 350,
              esteMes: 0.40,
              mesAnterior: 0.35,
              color: Colors.pinkAccent,
            ),
          ],
        ),
      ),
    );
  }
}

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(icono, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Text(
              "\$${monto.toStringAsFixed(0)}",
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
              widthFactor: valor,
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
