import 'package:flutter/material.dart';
import 'package:fynso/features/agregar/view/widgets/boton_mic.dart';
import 'package:fynso/features/agregar/view/widgets/gasto_card.dart';

import 'detalle_gasto_screen.dart';

class HistorialGastosScreen extends StatelessWidget {
  const HistorialGastosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gastos = [
      {
        "categoria": "Comida",
        "subcategoria": "Restaurante",
        "monto": 5.00,
        "fecha": "Hoy",
      },
      {
        "categoria": "Comida",
        "subcategoria": "Restaurante",
        "monto": 15.00,
        "fecha": "dom, 5 oct.",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
        backgroundColor: Colors.blue[800],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: gastos.length,
        itemBuilder: (context, index) {
          final gasto = gastos[index];
          return GastoCard(
            categoria: gasto["categoria"].toString(),
            subcategoria: gasto["subcategoria"].toString(),
            monto: gasto["monto"] as double,
            fecha: gasto["fecha"].toString(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DetalleGastoScreen(),
                  settings: RouteSettings(arguments: gasto),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: MicButton(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Micrófono presionado')));
        },
        backgroundColor: Colors.blue[800]!,
      ),
    );
  }
}
