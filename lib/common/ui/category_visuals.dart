// lib/common/ui/category_visuals.dart
import 'package:flutter/material.dart';
import 'package:fynso/common/themes/app_color.dart';

class CategoryVisuals {
  // === Map por ID (según tu SELECT) ===
  static const Map<int, IconData> _iconById = {
    20: Icons.category_rounded,            // Otros
    21: Icons.fastfood_rounded,            // Comida
    22: Icons.directions_car_rounded,      // Transporte
    23: Icons.home_rounded,                // Vivienda
    24: Icons.lightbulb_rounded,           // Servicios
    25: Icons.local_hospital_rounded,      // Salud
    26: Icons.school_rounded,              // Educación
    27: Icons.movie_filter_rounded,        // Entretenimiento
    28: Icons.shopping_bag_rounded,        // Compras
    29: Icons.flight_takeoff_rounded,      // Viajes
    30: Icons.account_balance_wallet_rounded, // Finanzas
    31: Icons.volunteer_activism_rounded,  // Regalos y donaciones
    32: Icons.receipt_long_rounded,        // Impuestos
    33: Icons.pets_rounded,                // Mascotas
    34: Icons.weekend_rounded,             // Hogar (sofá)
    35: Icons.devices_other_rounded,       // Tecnología
    36: Icons.spa,                         // Cuidado personal
  };

  static final Map<int, Color> _colorById = {
    20: Colors.grey,             // Otros
    21: AppColor.azulFynso,      // Comida
    22: Colors.orange,           // Transporte
    23: Colors.teal,             // Vivienda
    24: Colors.amber,            // Servicios
    25: Colors.redAccent,        // Salud
    26: Colors.blue,             // Educación
    27: Colors.purpleAccent,     // Entretenimiento
    28: Colors.pinkAccent,       // Compras
    29: Colors.indigo,           // Viajes
    30: Colors.green,            // Finanzas
    31: Colors.deepOrange,       // Regalos y donaciones
    32: Colors.brown,            // Impuestos
    33: Colors.lightGreen,       // Mascotas
    34: Colors.blueGrey,         // Hogar
    35: Colors.cyan,             // Tecnología,
    36: Colors.pinkAccent,
  };

  // === Map por nombre normalizado ===
  static const Map<String, IconData> _iconBySlug = {
    'otros': Icons.category_rounded,
    'comida': Icons.fastfood_rounded,
    'transporte': Icons.directions_car_rounded,
    'vivienda': Icons.home_rounded,
    'servicios': Icons.lightbulb_rounded,
    'salud': Icons.local_hospital_rounded,
    'educacion': Icons.school_rounded,
    'entretenimiento': Icons.movie_filter_rounded,
    'compras': Icons.shopping_bag_rounded,
    'viajes': Icons.flight_takeoff_rounded,
    'finanzas': Icons.account_balance_wallet_rounded,
    'regalos y donaciones': Icons.volunteer_activism_rounded,
    'impuestos': Icons.receipt_long_rounded,
    'mascotas': Icons.pets_rounded,
    'hogar': Icons.weekend_rounded,
    'tecnologia': Icons.devices_other_rounded,
    'cuidado personal': Icons.spa,
  };

  static final Map<String, Color> _colorBySlug = {
    'otros': Colors.grey,
    'comida': AppColor.azulFynso,
    'transporte': Colors.orange,
    'vivienda': Colors.teal,
    'servicios': Colors.amber,
    'salud': Colors.redAccent,
    'educacion': Colors.blue,
    'entretenimiento': Colors.purpleAccent,
    'compras': Colors.pinkAccent,
    'viajes': Colors.indigo,
    'finanzas': Colors.green,
    'regalos y donaciones': Colors.deepOrange,
    'impuestos': Colors.brown,
    'mascotas': Colors.lightGreen,
    'hogar': Colors.blueGrey,
    'tecnologia': Colors.cyan,
    'cuidado personal': Colors.pinkAccent,
  };

  /// Icono por ID (si lo tienes) o por nombre (fallback)
  static IconData iconFor({int? idCategory, String? nombre}) {
    if (idCategory != null && _iconById.containsKey(idCategory)) {
      return _iconById[idCategory]!;
    }
    final slug = _slug(nombre ?? '');
    return _iconBySlug[slug] ?? Icons.category_rounded;
  }

  /// Color por ID o nombre
  static Color colorFor({int? idCategory, String? nombre}) {
    if (idCategory != null && _colorById.containsKey(idCategory)) {
      return _colorById[idCategory]!;
    }
    final slug = _slug(nombre ?? '');
    return _colorBySlug[slug] ?? Colors.grey;
  }

  // --------- helpers ---------
  static String _slug(String raw) {
    String s = raw.trim().toLowerCase();
    const _from = 'áéíóúüñ';
    const _to   = 'aeiouun';
    for (int i = 0; i < _from.length; i++) {
      s = s.replaceAll(_from[i], _to[i]);
    }
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s;
  }
}
