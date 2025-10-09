import 'package:flutter/material.dart';
import 'package:fynso/features/agregar/view/widgets/boton_mic.dart';

import 'historial_gastos_screen.dart';

class GrabarGastoScreen extends StatelessWidget {
  const GrabarGastoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grabar Gasto'),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Presiona el botón para grabar tu gasto',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Icon(Icons.mic, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            MicButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Grabación iniciada')),
                );
              },
              backgroundColor: Colors.blue[800]!,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Otra opción: ir directo al historial sin grabar
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistorialGastosScreen(),
                  ),
                );
              },
              child: const Text('Ver Historial de Gastos'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
