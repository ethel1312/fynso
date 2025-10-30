import 'package:flutter/material.dart';

class CategoryStatusStats {
  final String current;
  final String previous;
  final String delta;
  final double? pctChange;

  CategoryStatusStats({
    required this.current,
    required this.previous,
    required this.delta,
    required this.pctChange,
  });

  factory CategoryStatusStats.fromJson(Map<String, dynamic> j) {
    return CategoryStatusStats(
      current: (j['current'] ?? '0.00').toString(),
      previous: (j['previous'] ?? '0.00').toString(),
      delta: (j['delta'] ?? '0.00').toString(),
      pctChange: (j['pct_change'] as num?)?.toDouble(),
    );
  }
}

class CategoryStatusCard {
  final String title;
  final String category;
  final String percentage;
  final String colorHex; // ej: "#4CAF50"
  final String iconName; // ej: "trending_up_rounded"
  final CategoryStatusStats? stats;

  CategoryStatusCard({
    required this.title,
    required this.category,
    required this.percentage,
    required this.colorHex,
    required this.iconName,
    this.stats,
  });

  factory CategoryStatusCard.fromJson(Map<String, dynamic> j) {
    return CategoryStatusCard(
      title: (j['title'] ?? '').toString(),
      category: (j['category'] ?? '—').toString(),
      percentage: (j['percentage'] ?? 'Sin datos').toString(),
      colorHex: (j['color'] ?? '#BDBDBD').toString(),
      iconName: (j['icon'] ?? 'insights_rounded').toString(),
      stats: j['stats'] != null 
          ? CategoryStatusStats.fromJson(j['stats']) 
          : null,
    );
  }

  // Convertir color hex a Color
  Color get color {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  // Mapeo de nombres de iconos a IconData
  IconData get icon {
    switch (iconName) {
      case 'trending_up_rounded':
        return Icons.trending_up_rounded;
      case 'trending_down_rounded':
        return Icons.trending_down_rounded;
      case 'trending_flat_rounded':
        return Icons.trending_flat_rounded;
      case 'warning_rounded':
        return Icons.warning_rounded;
      case 'insights_rounded':
        return Icons.insights_rounded;
      default:
        return Icons.insights_rounded;
    }
  }
}

class CategoryStatusCardsData {
  final CategoryStatusCard best;
  final CategoryStatusCard attention;

  CategoryStatusCardsData({
    required this.best,
    required this.attention,
  });

  factory CategoryStatusCardsData.fromJson(Map<String, dynamic> j) {
    return CategoryStatusCardsData(
      best: CategoryStatusCard.fromJson(j['best']),
      attention: CategoryStatusCard.fromJson(j['attention']),
    );
  }
}

class CategoryStatusResponse {
  final int anio;
  final int mes;
  final CategoryStatusCardsData cards;

  CategoryStatusResponse({
    required this.anio,
    required this.mes,
    required this.cards,
  });

  factory CategoryStatusResponse.fromJson(Map<String, dynamic> j) {
    final data = j['data'] as Map<String, dynamic>;
    final month = data['month'] as Map<String, dynamic>;
    final cards = data['cards'] as Map<String, dynamic>;

    return CategoryStatusResponse(
      anio: (month['anio'] as int?) ?? DateTime.now().year,
      mes: (month['mes'] as int?) ?? DateTime.now().month,
      cards: CategoryStatusCardsData.fromJson(cards),
    );
  }
}
