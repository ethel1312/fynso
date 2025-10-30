import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String nombre;
  final String presupuesto;
  final String iniciales;

  const ProfileCard({
    super.key,
    required this.nombre,
    required this.presupuesto,
    required this.iniciales,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Text(
                iniciales,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nombre completo",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Presupuesto mensual",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    presupuesto,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
