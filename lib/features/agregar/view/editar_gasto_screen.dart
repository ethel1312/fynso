import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/themes/app_color.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_textfield.dart';
import '../../../data/models/transaction_response.dart';
import '../../../data/models/transaction_update_resquest.dart';
import '../view_model/transaction_update_view_model.dart';

class EditarGastoScreen extends StatefulWidget {
  const EditarGastoScreen({super.key});

  @override
  State<EditarGastoScreen> createState() => _EditarGastoScreenState();
}

class _EditarGastoScreenState extends State<EditarGastoScreen> {
  late TextEditingController _categoriaController;
  late TextEditingController _subcategoriaController;
  late TextEditingController _montoController;
  late TextEditingController _fechaController;
  late TextEditingController _horaController;
  late TextEditingController _lugarController;
  late TextEditingController _notasController;
  late TextEditingController _transcripcionController;

  late TransactionResponse transaction;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recibir la transacción desde DetalleGastoScreen
    transaction =
        ModalRoute.of(context)?.settings.arguments as TransactionResponse;

    _categoriaController = TextEditingController(text: transaction.category);
    _subcategoriaController = TextEditingController(
      text: transaction.subcategory,
    );
    _montoController = TextEditingController(
      text: transaction.monto.toString(),
    );
    _fechaController = TextEditingController(
      text: transaction.fecha.substring(0, 10),
    );
    _horaController = TextEditingController(
      text: transaction.fecha.length > 10
          ? transaction.fecha.substring(11, 16)
          : '',
    );
    _lugarController = TextEditingController(text: transaction.lugar ?? '');
    _notasController = TextEditingController(text: transaction.descripcion);
    _transcripcionController = TextEditingController(
      text: transaction.transcripcion ?? '',
    );
  }

  @override
  void dispose() {
    _categoriaController.dispose();
    _subcategoriaController.dispose();
    _montoController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _lugarController.dispose();
    _notasController.dispose();
    _transcripcionController.dispose();
    super.dispose();
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

  Future<String?> _getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionEditViewModel()..loadTransaction(transaction),
      child: Consumer<TransactionEditViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Editar gasto'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
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
                  _buildField("Fecha (YYYY-MM-DD)", _fechaController),
                  const SizedBox(height: 16),
                  _buildField("Hora (HH:MM)", _horaController),
                  const SizedBox(height: 16),
                  _buildField("Lugar", _lugarController),
                  const SizedBox(height: 16),
                  _buildField("Notas", _notasController, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildField(
                    "Transcripción",
                    _transcripcionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  if (vm.isLoading)
                    const CircularProgressIndicator()
                  else
                    CustomButton(
                      text: 'Guardar Cambios',
                      backgroundColor: AppColor.azulFynso,
                      onPressed: () async {
                        final jwt = await _getJwtToken();

                        if (jwt == null || jwt.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No se encontró token de usuario'),
                            ),
                          );
                          return;
                        }

                        final body = TransactionUpdateRequest(
                          category: _categoriaController.text,
                          subcategory: _subcategoriaController.text,
                          amount: double.tryParse(_montoController.text) ?? 0.0,
                          date: _fechaController.text,
                          time: _horaController.text,
                          place: _lugarController.text,
                          notes: _notasController.text,
                        );

                        final success = await vm.updateTransaction(
                          jwt: jwt,
                          idTransaction: transaction.idTransaction,
                          body: body,
                        );

                        if (success) {
                          Navigator.pop(context, vm.transaction);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(vm.error ?? 'Error al actualizar'),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
