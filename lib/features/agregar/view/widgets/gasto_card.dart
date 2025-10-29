import 'package:flutter/material.dart';
import 'dart:io' show HttpDate; // Para parsear "Tue, 28 Oct 2025 00:00:00 GMT"

class GastoCard extends StatelessWidget {
  final String categoria;
  final String subcategoria;
  final double monto;
  final String fecha; // puede venir en ISO, HTTP-date, dd/MM/yyyy o yyyy-MM-dd
  final VoidCallback onTap;

  const GastoCard({
    super.key,
    required this.categoria,
    required this.subcategoria,
    required this.monto,
    required this.fecha,
    required this.onTap,
  });

  DateTime? _parseDateFlexible(String raw) {
    // 1) ISO
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    // 2) HTTP/RFC-1123
    try {
      return HttpDate.parse(raw); // devuelve UTC
    } catch (_) {}

    // 3) dd/MM/yyyy
    final ddMMyyyy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
    final m1 = ddMMyyyy.firstMatch(raw);
    if (m1 != null) {
      final d = int.parse(m1.group(1)!);
      final m = int.parse(m1.group(2)!);
      final y = int.parse(m1.group(3)!);
      return DateTime(y, m, d);
    }

    // 4) yyyy-MM-dd
    final yyyymmdd = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
    final m2 = yyyymmdd.firstMatch(raw);
    if (m2 != null) {
      final y = int.parse(m2.group(1)!);
      final m = int.parse(m2.group(2)!);
      final d = int.parse(m2.group(3)!);
      return DateTime(y, m, d);
    }

    return null;
  }

  String _formatFechaSoloDia(String raw) {
    final dt = _parseDateFlexible(raw);
    if (dt == null) return raw; // fallback si no se pudo parsear

    // OJO: NO hacemos toLocal(); usamos Y-M-D "tal cual" (fecha pura)
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final fechaCorta = _formatFechaSoloDia(fecha);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text('$categoria - $subcategoria'),
        subtitle: Text(fechaCorta),
        trailing: Text('S/ ${monto.toStringAsFixed(2)}'),
        onTap: onTap,
      ),
    );
  }
}
