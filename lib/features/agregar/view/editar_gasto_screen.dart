import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../common/themes/app_color.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_title.dart';
import '../../../common/widgets/custom_textfield.dart';
import '../../../data/models/transaction_response.dart';
import '../../../data/models/transaction_update_resquest.dart';
import '../view_model/transaction_update_view_model.dart';
import '../view_model/category_view_model.dart';

class EditarGastoScreen extends StatefulWidget {
  const EditarGastoScreen({super.key});

  @override
  State<EditarGastoScreen> createState() => _EditarGastoScreenState();
}

class _EditarGastoScreenState extends State<EditarGastoScreen> {
  // Controllers
  late TextEditingController _categoriaController;
  late TextEditingController _subcategoriaController;
  late TextEditingController _montoController;
  late TextEditingController _fechaController;
  late TextEditingController _horaController;
  late TextEditingController _lugarController;
  late TextEditingController _notasController;
  late TextEditingController _transcripcionController;

  late TransactionResponse transaction;

  // Flags para inicializar solo una vez
  bool _controllersInitialized = false; // no volver a pisar textos del usuario
  bool _vmInitialized = false; // init de CategoryViewModel

  @override
  void initState() {
    super.initState();
    // Crea controllers una sola vez (vacíos)
    _categoriaController = TextEditingController();
    _subcategoriaController = TextEditingController();
    _montoController = TextEditingController();
    _fechaController = TextEditingController();
    _horaController = TextEditingController();
    _lugarController = TextEditingController();
    _notasController = TextEditingController();
    _transcripcionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recibe la transacción de la ruta
    transaction =
        ModalRoute.of(context)?.settings.arguments as TransactionResponse;

    // Setea textos con valores de DB SOLO la primera vez
    if (!_controllersInitialized) {
      _categoriaController.text = transaction.category;
      _subcategoriaController.text = transaction.subcategory;
      _montoController.text = transaction.monto.toString();

      // Parsear fecha correctamente - manejo robusto
      String fechaStr = '';
      String horaStr = '';

      try {
        // Intenta parsear la fecha del backend
        DateTime fechaDt;

        // Si la fecha tiene formato ISO con T (ej: 2025-10-29T13:45:00)
        if (transaction.fecha.contains('T')) {
          fechaDt = DateTime.parse(transaction.fecha);
        }
        // Si es formato con espacio (ej: 2025-10-29 13:45:00)
        else if (transaction.fecha.contains(' ')) {
          final parts = transaction.fecha.split(' ');
          if (parts.length >= 2) {
            fechaStr = parts[0]; // fecha
            horaStr = parts[1].substring(0, 5); // hora HH:mm
            // Validar que sea formato correcto
            if (fechaStr.length == 10 && fechaStr.contains('-')) {
              _fechaController.text = fechaStr;
              _horaController.text = horaStr;
              _lugarController.text = transaction.lugar ?? '';
              _notasController.text = transaction.descripcion;
              _transcripcionController.text = transaction.transcripcion ?? '';
              _controllersInitialized = true;
              return; // Salir temprano si funciona
            }
          }
          fechaDt = DateTime.parse(transaction.fecha);
        }
        // Intenta parse directo
        else {
          fechaDt = DateTime.parse(transaction.fecha);
        }

        fechaStr = DateFormat('yyyy-MM-dd').format(fechaDt);
        horaStr = DateFormat('HH:mm').format(fechaDt);
      } catch (e) {
        // Si todo falla, usar valores por defecto
        print('Error parsing fecha: ${transaction.fecha}, error: $e');
        fechaStr = DateTime.now().toString().substring(0, 10);
        horaStr = '00:00';
      }

      _fechaController.text = fechaStr;
      _horaController.text = horaStr;
      _lugarController.text = transaction.lugar ?? '';
      _notasController.text = transaction.descripcion;
      _transcripcionController.text = transaction.transcripcion ?? '';
      _controllersInitialized = true;
    }
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

  Future<String?> _getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ---------- Helpers de UI: TextField con “menú desplegable” ----------
  Widget _pickerTextField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    bool loading = false,
    bool enabled = true,
  }) {
    return Center(
      child: SizedBox(
        width: 335,
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            // Mantiene el estilo de tu CustomTextField
            AbsorbPointer(
              absorbing: true,
              child: CustomTextField(label: label, controller: controller),
            ),
            // Zona táctil encima
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled
                      ? () {
                          FocusScope.of(context).unfocus();
                          onTap();
                        }
                      : null,
                ),
              ),
            ),
            // Icono / loading a la derecha
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_drop_down),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCategoryPicker(CategoryViewModel cvm) async {
    final jwt = await _getJwtToken();
    if (jwt == null || jwt.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró token de usuario')),
      );
      return;
    }

    // Carga categorías si aún no están
    if (cvm.categories.isEmpty && !cvm.loadingCategories) {
      await cvm.loadCategories(jwt: jwt);
    }
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: cvm.categories.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No hay categorías.'),
              )
            : ListView.separated(
                itemCount: cvm.categories.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final c = cvm.categories[i];
                  return ListTile(
                    title: Text(c.nombre),
                    onTap: () async {
                      Navigator.pop(context);
                      await cvm.selectCategoryById(
                        jwt: jwt,
                        idCategory: c.idCategory,
                      );
                      // Refresca UI según selección
                      _categoriaController.text = c.nombre;
                      _subcategoriaController.text =
                          cvm.selectedSubcategory?.nombre ?? '';
                      if (mounted) setState(() {});
                    },
                  );
                },
              ),
      ),
    );
  }

  Future<void> _openSubcategoryPicker(CategoryViewModel cvm) async {
    final jwt = await _getJwtToken();
    if (jwt == null || jwt.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró token de usuario')),
      );
      return;
    }

    if (cvm.selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero selecciona una categoría')),
      );
      return;
    }

    // Asegura subcategorías cargadas
    if (cvm.subcategories.isEmpty && !cvm.loadingSubcategories) {
      await cvm.loadSubcategories(
        jwt: jwt,
        idCategory: cvm.selectedCategory!.idCategory,
      );
    }
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: cvm.subcategories.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No hay subcategorías para esta categoría.'),
              )
            : ListView.separated(
                itemCount: cvm.subcategories.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final s = cvm.subcategories[i];
                  return ListTile(
                    title: Text(s.nombre),
                    onTap: () {
                      Navigator.pop(context);
                      cvm.selectSubcategoryById(s.idSubcategory);
                      _subcategoriaController.text = s.nombre;
                      if (mounted) setState(() {});
                    },
                  );
                },
              ),
      ),
    );
  }

  bool _isTransactionInCurrentMonth() {
    try {
      final now = DateTime.now();
      final txDate = DateTime.parse(transaction.fecha);
      return txDate.year == now.year && txDate.month == now.month;
    } catch (e) {
      return true; // Si no se puede parsear, permitir editar
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfMonth = !_isTransactionInCurrentMonth();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              TransactionEditViewModel()..loadTransaction(transaction),
        ),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
      ],
      child: Consumer2<TransactionEditViewModel, CategoryViewModel>(
        builder: (context, vm, cvm, _) {
          // Init de categorías/subcategorías y selección inicial SOLO una vez
          if (!_vmInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final jwt = await _getJwtToken();
              if (jwt != null && jwt.isNotEmpty) {
                // Carga categorías si hace falta
                if (cvm.categories.isEmpty) {
                  await cvm.loadCategories(jwt: jwt);
                }
                // Selecciona categoría y subcategoría inicial por nombre
                if (cvm.categories.isNotEmpty) {
                  final cat = cvm.categories.firstWhere(
                    (c) =>
                        c.nombre.toLowerCase() ==
                        transaction.category.toLowerCase(),
                    orElse: () => cvm.categories.first,
                  );
                  await cvm.selectCategoryById(
                    jwt: jwt,
                    idCategory: cat.idCategory,
                  );

                  // Empareja subcategoría por nombre si existe
                  final sub = cvm.subcategories.where(
                    (s) =>
                        s.nombre.toLowerCase() ==
                        transaction.subcategory.toLowerCase(),
                  );
                  if (sub.isNotEmpty) {
                    cvm.selectSubcategoryById(sub.first.idSubcategory);
                  }

                  // Refleja en UI una sola vez
                  _categoriaController.text =
                      cvm.selectedCategory?.nombre ?? transaction.category;
                  _subcategoriaController.text =
                      cvm.selectedSubcategory?.nombre ??
                      transaction.subcategory;
                  if (mounted) setState(() {});
                }
              }
              if (mounted) setState(() => _vmInitialized = true);
            });
          }

          return Scaffold(
            appBar: AppBar(title: const CustomTextTitle('Editar gasto')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Mensaje de advertencia si está fuera del mes actual
                  if (isOutOfMonth)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Este gasto está fuera del mes actual. Solo puedes registrar gastos del mes en curso.',
                              style: TextStyle(
                                color: Colors.orange[900],
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ---------- Categoría (textfield con desplegable) ----------
                  _pickerTextField(
                    label: 'Categoría',
                    controller: _categoriaController,
                    loading: cvm.loadingCategories,
                    onTap: () => _openCategoryPicker(cvm),
                    enabled: !cvm.loadingCategories,
                  ),
                  const SizedBox(height: 16),

                  // ---------- Subcategoría ----------
                  _pickerTextField(
                    label: 'Subcategoría',
                    controller: _subcategoriaController,
                    loading: cvm.loadingSubcategories,
                    onTap: () => _openSubcategoryPicker(cvm),
                    enabled: cvm.selectedCategory != null,
                  ),
                  const SizedBox(height: 16),

                  // ---------- Resto de campos ----------
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

                  // ---------- Transcripción solo lectura si existe ----------
                  if (_transcripcionController.text.trim().isNotEmpty)
                    _buildReadOnlyTranscription(),

                  const SizedBox(height: 24),
                  if (vm.isLoading)
                    const CircularProgressIndicator()
                  else
                    CustomButton(
                      text: 'Guardar Cambios',
                      backgroundColor: AppColor.azulFynso,
                      onPressed: () async {
                        // Validaciones
                        if (cvm.selectedSubcategory == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selecciona una subcategoría'),
                            ),
                          );
                          return;
                        }

                        final jwt = await _getJwtToken();
                        if (jwt == null || jwt.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No se encontró token de usuario'),
                            ),
                          );
                          return;
                        }

                        // Enviar ID (id_subcategory) + demás campos
                        final body = TransactionUpdateRequest(
                          amount: double.tryParse(_montoController.text) ?? 0.0,
                          date: _fechaController.text,
                          time: _horaController.text,
                          place: _lugarController.text,
                          notes: _notasController.text,
                          idSubcategory: cvm.selectedSubcategory!.idSubcategory,
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

  // Helper para otros textos
  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Center(
      child: SizedBox(
        width: 335,
        child: CustomTextField(
          label: label,
          controller: controller,
          maxLines: maxLines,
          enabled: enabled,
        ),
      ),
    );
  }

  // 🔹 Transcripción solo lectura, gris y no editable
  Widget _buildReadOnlyTranscription() {
    final text = _transcripcionController.text;

    return Center(
      child: SizedBox(
        width: 335,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Transcripción",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
