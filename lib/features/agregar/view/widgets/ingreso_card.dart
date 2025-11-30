import 'dart:io' show HttpDate;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IngresoCard extends StatelessWidget {
  final double amount;
  final String fecha; // "yyyy-MM-dd" o similar
  final String hora;  // "HH:mm" o "HH:mm:ss"
  final String? notes;
  final VoidCallback? onTap;

  const IngresoCard({
    super.key,
    required this.amount,
    required this.fecha,
    required this.hora,
    this.notes,
    this.onTap,
  });

  DateTime? _parseFlexible(String rawDate, String rawTime) {
    // primero intentamos fecha + hora
    try {
      final joined = '$rawDate $rawTime';
      final dt = DateTime.tryParse(joined);
      if (dt != null) return dt;
    } catch (_) {}

    // solo fecha
    final iso = DateTime.tryParse(rawDate);
    if (iso != null) return iso;

    // HttpDate
    try {
      return HttpDate.parse(rawDate);
    } catch (_) {}

    // yyyy-MM-dd
    final re1 = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
    final m1 = re1.firstMatch(rawDate);
    if (m1 != null) {
      final y = int.parse(m1.group(1)!);
      final mm = int.parse(m1.group(2)!);
      final d = int.parse(m1.group(3)!);
      return DateTime(y, mm, d);
    }

    // dd/MM/yyyy
    final re2 = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
    final m2 = re2.firstMatch(rawDate);
    if (m2 != null) {
      final d = int.parse(m2.group(1)!);
      final mm = int.parse(m2.group(2)!);
      final y = int.parse(m2.group(3)!);
      return DateTime(y, mm, d);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dt = _parseFlexible(fecha, hora);
    final formattedDateTime = dt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(dt)
        : '$fecha $hora';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(
          Icons.arrow_downward_rounded,
          color: Colors.green,
        ),
        title: Text(
          '+ S/ ${amount.toStringAsFixed(2)}',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        subtitle: Text(
          notes?.isNotEmpty == true
              ? '$formattedDateTime\n$notes'
              : formattedDateTime,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
      ),
    );
  }
}
