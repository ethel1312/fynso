import 'package:intl/intl.dart';

String formatFecha(String fechaIso) {
  try {
    final date = DateTime.parse(fechaIso);
    return DateFormat('d MMM yyyy').format(date); // 9 Oct 2025
  } catch (e) {
    return fechaIso; // fallback si hay error
  }
}

String formatMonto(double monto) {
  return monto.toStringAsFixed(2); // 15.00
}
