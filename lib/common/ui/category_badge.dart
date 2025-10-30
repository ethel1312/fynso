import 'package:flutter/material.dart';

class CategoryBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const CategoryBadge({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(6),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
