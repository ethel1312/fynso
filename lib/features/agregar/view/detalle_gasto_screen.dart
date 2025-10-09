import 'package:flutter/material.dart';
import '../../../common/themes/app_color.dart';
import '../../../common/widgets/custom_button.dart';

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
          "moneda": "PEN",
          "fecha": "2025-10-08",
          "hora": "20:29",
          "lugar": "Starbucks",
          "notas": "",
          "transcripcion": "Ollaste cinco soles en Starbucks.",
        };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del gasto'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          // <-- centramos el contenido horizontalmente
          child: SizedBox(
            width: 335,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // textos a la izquierda
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
                  'Moneda: ${gasto["moneda"]}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fecha: ${gasto["fecha"]}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hora: ${gasto["hora"]}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lugar: ${gasto["lugar"]}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Notas: ${gasto["notas"]}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Transcripción: ${gasto["transcripcion"]}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Center(
                  child: CustomButton(
                    text: 'Editar Gasto',
                    backgroundColor: AppColor.azulFynso,
                    onPressed: () async {
                      Navigator.pushNamed(context, '/editarGasto');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
