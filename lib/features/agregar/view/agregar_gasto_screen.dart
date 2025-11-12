import 'package:flutter/material.dart';
import 'package:fynso/common/themes/app_color.dart';
import 'package:fynso/common/widgets/custom_button.dart';
import 'package:fynso/common/widgets/custom_text_title.dart';
import 'package:fynso/common/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../data/models/create_transaction_request.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../home/view_model/monthly_summary_view_model.dart';
import '../view_model/category_view_model.dart';
import 'package:intl/intl.dart';

class AgregarGastoScreen extends StatefulWidget {
  const AgregarGastoScreen({super.key});

  @override
  State<AgregarGastoScreen> createState() => _AgregarGastoScreenState();
}

class _AgregarGastoScreenState extends State<AgregarGastoScreen> {
  final TransactionRepository _repository = TransactionRepository();

  // Controllers
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subcategoryController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _isLoading = false;

  @override
  void dispose() {
    _montoController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    _placeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<String?> _getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Selector de categoría
  Widget _pickerTextField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    bool loading = false,
    bool enabled = true,
  }) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        AbsorbPointer(
          absorbing: true,
          child: CustomTextField(label: label, controller: controller),
        ),
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
                      _categoryController.text = c.nombre;
                      _subcategoryController.text =
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
                      _subcategoryController.text = s.nombre;
                      if (mounted) setState(() {});
                    },
                  );
                },
              ),
      ),
    );
  }

  // ===== ALERTA DE PRESUPUESTO =====
  void _showBudgetAlert(double total, double limite) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¡Alerta de presupuesto!'),
        content: Text(
          'Has gastado S/ ${total.toStringAsFixed(2)} de S/ ${limite.toStringAsFixed(2)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm(CategoryViewModel cvm, MonthlySummaryViewModel monthlySummaryVM) async {
    final monto = _montoController.text.trim();

    if (monto.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El monto es requerido')));
      return;
    }

    final amount = double.tryParse(monto);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un monto válido')));
      return;
    }

    if (cvm.selectedSubcategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una categoría y subcategoría'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');

      if (jwt == null || jwt.isEmpty) {
        throw Exception('No se encontró token de usuario');
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final timeStr =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      final request = CreateTransactionRequest(
        amount: amount,
        idSubcategory: cvm.selectedSubcategory!.idSubcategory,
        date: dateStr,
        time: timeStr,
        place: _placeController.text.trim().isNotEmpty
            ? _placeController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      final response = await _repository.createTransaction(
        jwt: jwt,
        request: request,
      );

      if (!mounted) return;

      if (response.code == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar formulario
        _montoController.clear();
        _categoryController.clear();
        _subcategoryController.clear();
        _placeController.clear();
        _notesController.clear();
        setState(() {
          _selectedDate = DateTime.now();
          _selectedTime = TimeOfDay.now();
        });

        // ===== ALERTA DE PRESUPUESTO =====
        final budgetAlertsEnabled = prefs.getBool('budget_alerts') ?? true;
        if (budgetAlertsEnabled) {
          final totalGastado = monthlySummaryVM.gastado;
          final limitePresupuesto = monthlySummaryVM.limite;

          if (totalGastado >= limitePresupuesto && limitePresupuesto > 0) {
            _showBudgetAlert(totalGastado, limitePresupuesto);
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => MonthlySummaryViewModel()),
      ],
      child: Consumer2<CategoryViewModel, MonthlySummaryViewModel>(
        builder: (context, cvm, monthlyVM, _) {
          return Scaffold(
            appBar: AppBar(
              title: const CustomTextTitle('Registrar'),
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Registra un nuevo gasto',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Monto (requerido)
                  CustomTextField(
                    label: 'Monto *',
                    controller: _montoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categoría
                  _pickerTextField(
                    label: 'Categoría *',
                    controller: _categoryController,
                    loading: cvm.loadingCategories,
                    onTap: () => _openCategoryPicker(cvm),
                    enabled: !cvm.loadingCategories,
                  ),
                  const SizedBox(height: 16),

                  // Subcategoría
                  _pickerTextField(
                    label: 'Subcategoría *',
                    controller: _subcategoryController,
                    loading: cvm.loadingSubcategories,
                    onTap: () => _openSubcategoryPicker(cvm),
                    enabled: cvm.selectedCategory != null,
                  ),
                  const SizedBox(height: 16),

                  // Fecha y hora
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: AppColor.azulFynso,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_selectedDate),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: AppColor.azulFynso,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Lugar
                  CustomTextField(
                    label: 'Lugar (opcional)',
                    controller: _placeController,
                  ),
                  const SizedBox(height: 16),

                  // Notas
                  CustomTextField(
                    label: 'Notas (opcional)',
                    controller: _notesController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Botón guardar
                  CustomButton(
                    text: _isLoading ? 'Guardando...' : 'Guardar gasto',
                    backgroundColor: AppColor.azulFynso,
                    onPressed: _isLoading ? null : () async => _submitForm(cvm, monthlyVM),
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
