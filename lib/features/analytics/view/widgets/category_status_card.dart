import 'package:flutter/material.dart';

class CategoryStatusCard extends StatelessWidget {
  final String title; // Ej: "Mejor categoría"
  final String category; // Ej: "Transporte"
  final String percentage; // Ej: "-15% ahorrado"
  final Color color; // Color base del ícono
  final IconData icon; // Ícono

  const CategoryStatusCard({
    super.key,
    required this.title,
    required this.category,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Ícono principal
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),

              const SizedBox(height: 12),

              // 🔹 Título
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 12),

              // 🔹 Categoría
              Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // 🔹 Porcentaje
              Text(percentage, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
