import 'package:flutter/material.dart';
import '../../../common/themes/app_color.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_textfield.dart';

class EditarGastoScreen extends StatefulWidget {
  const EditarGastoScreen({super.key});

  @override
  State<EditarGastoScreen> createState() => _EditarGastoScreenState();
}

class _EditarGastoScreenState extends State<EditarGastoScreen> {
  late TextEditingController _categoriaController;
  late TextEditingController _subcategoriaController;
  late TextEditingController _montoController;
  late TextEditingController _monedaController;
  late TextEditingController _fechaController;
  late TextEditingController _horaController;
  late TextEditingController _lugarController;
  late TextEditingController _notasController;
  late TextEditingController _transcripcionController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> gasto =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {
          "categoria": "",
          "subcategoria": "",
          "monto": 0.0,
          "moneda": "PEN",
          "fecha": "",
          "hora": "",
          "lugar": "",
          "notas": "",
          "transcripcion": "",
        };

    _categoriaController = TextEditingController(text: gasto["categoria"]);
    _subcategoriaController = TextEditingController(
      text: gasto["subcategoria"],
    );
    _montoController = TextEditingController(text: gasto["monto"].toString());
    _monedaController = TextEditingController(text: gasto["moneda"]);
    _fechaController = TextEditingController(text: gasto["fecha"]);
    _horaController = TextEditingController(text: gasto["hora"]);
    _lugarController = TextEditingController(text: gasto["lugar"]);
    _notasController = TextEditingController(text: gasto["notas"]);
    _transcripcionController = TextEditingController(
      text: gasto["transcripcion"],
    );
  }

  @override
  void dispose() {
    _categoriaController.dispose();
    _subcategoriaController.dispose();
    _montoController.dispose();
    _monedaController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _lugarController.dispose();
    _notasController.dispose();
    _transcripcionController.dispose();
    super.dispose();
  }

  void _guardarGasto() {
    final gastoEditado = {
      "categoria": _categoriaController.text,
      "subcategoria": _subcategoriaController.text,
      "monto": double.tryParse(_montoController.text) ?? 0.0,
      "moneda": _monedaController.text,
      "fecha": _fechaController.text,
      "hora": _horaController.text,
      "lugar": _lugarController.text,
      "notas": _notasController.text,
      "transcripcion": _transcripcionController.text,
    };

    Navigator.pop(context, gastoEditado);
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Center(
      child: SizedBox(
        width: 335,
        child: CustomTextField(
          label: label,
          controller: controller,
          maxLines: maxLines,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar gasto'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildField("Categoría", _categoriaController),
            const SizedBox(height: 16),
            _buildField("Subcategoría", _subcategoriaController),
            const SizedBox(height: 16),
            _buildField("Monto", _montoController),
            const SizedBox(height: 16),
            _buildField("Moneda", _monedaController),
            const SizedBox(height: 16),
            _buildField("Fecha", _fechaController),
            const SizedBox(height: 16),
            _buildField("Hora", _horaController),
            const SizedBox(height: 16),
            _buildField("Lugar", _lugarController),
            const SizedBox(height: 16),
            _buildField("Notas", _notasController, maxLines: 3),
            const SizedBox(height: 16),
            _buildField("Transcripción", _transcripcionController, maxLines: 3),
            const SizedBox(height: 24),
            Center(
              child: CustomButton(
                text: 'Guardar Cambios',
                backgroundColor: AppColor.azulFynso,
                onPressed: () async {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
