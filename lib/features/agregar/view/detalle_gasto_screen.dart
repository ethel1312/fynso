import 'package:flutter/material.dart';

class DetalleGastoScreen extends StatelessWidget {
  const DetalleGastoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> gasto =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {
          "categoria": "Comida",
          "subcategoria": "Restaurante",
          "monto": 5.0,
          "fecha": "Hoy",
        };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Gasto'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categoría: ${gasto["categoria"]}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Subcategoría: ${gasto["subcategoria"]}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Cantidad: S/ ${gasto["monto"]}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha: ${gasto["fecha"]}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Editar Gasto presionado')),
                );
              },
              child: const Text('Editar Gasto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
