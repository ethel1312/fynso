import 'package:flutter/material.dart';

class GastoCard extends StatelessWidget {
  final String categoria;
  final String subcategoria;
  final double monto;
  final String fecha;
  final VoidCallback onTap;

  const GastoCard({
    super.key,
    required this.categoria,
    required this.subcategoria,
    required this.monto,
    required this.fecha,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text('$categoria - $subcategoria'),
        subtitle: Text(fecha),
        trailing: Text('S/ $monto'),
        onTap: onTap,
      ),
    );
  }
}
