import 'package:flutter/material.dart';

class InsightRecommendation {
  final String level; // danger | warning | success | info
  final String type;
  final String title;
  final String body;

  InsightRecommendation({
    required this.level,
    required this.type,
    required this.title,
    required this.body,
  });

  factory InsightRecommendation.fromJson(Map<String, dynamic> j) {
    return InsightRecommendation(
      level: (j['level'] ?? 'info').toString(),
      type: (j['type'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      body: (j['body'] ?? '').toString(),
    );
  }

  // Mapeo de colores según level
  Color get color {
    switch (level) {
      case 'danger':
        return const Color(0xFFFFE5E5);
      case 'warning':
        return const Color(0xFFFFF4CC);
      case 'success':
        return const Color(0xFFE5F6E5);
      case 'info':
      default:
        return const Color(0xFFEDE5FF);
    }
  }

  Color get iconColor {
    switch (level) {
      case 'danger':
        return Colors.redAccent;
      case 'warning':
        return const Color(0xFFFFB300);
      case 'success':
        return Colors.green;
      case 'info':
      default:
        return Colors.deepPurple;
    }
  }

  IconData get icon {
    switch (type) {
      case 'no_data':
        return Icons.info_outline;
      case 'set_limit_hint':
        return Icons.settings_outlined;
      case 'limit_usage':
        return Icons.flag_rounded;
      case 'prev_month_change':
        return Icons.trending_up_rounded;
      case 'category_spike':
        return Icons.warning_amber_rounded;
      default:
        return Icons.lightbulb_outline;
    }
  }
}

