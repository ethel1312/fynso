import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF1565C0),
      onPressed: () {
        // TODO: Conectar con lógica de agregar transacción
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
