import 'package:flutter/material.dart';

class InsightCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String message1;
  final String message2;
  final Color iconColor;

  const InsightCard({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.message1,
    required this.message2,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message1,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                if (message2.isNotEmpty)
                  Text(
                    message2,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
