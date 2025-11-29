import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fynso/common/themes/app_color.dart';
import 'package:fynso/common/widgets/custom_button.dart';
import 'package:fynso/common/widgets/custom_text_title.dart';
import 'package:fynso/common/widgets/custom_textfield.dart';
import 'package:fynso/data/models/income_detail.dart';
import 'package:fynso/data/models/income_update_request.dart';
import 'package:fynso/data/services/income_service.dart';

class EditarIngresoScreen extends StatefulWidget {
  const EditarIngresoScreen({super.key});

  @override
  State<EditarIngresoScreen> createState() => _EditarIngresoScreenState();
}

class _EditarIngresoScreenState extends State<EditarIngresoScreen> {
  final IncomeService _service = IncomeService();

  late IncomeDetail _income;

  final _montoCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // No podemos leer arguments aquí, lo hacemos en addPostFrame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
      ModalRoute.of(context)?.settings.arguments as IncomeDetail?;
      if (args != null) {
        _income = args;
        _montoCtrl.text = _income.amount.toString();
        _fechaCtrl.text = _income.date;
        _horaCtrl.text = _income.time;
        _notasCtrl.text = _income.notes ?? '';
        setState(() {});
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<String?> _getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _save() async {
    final amount = double.tryParse(_montoCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido')),
      );
      return;
    }
    final date = _fechaCtrl.text.trim();
    final time = _horaCtrl.text.trim();

    if (date.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fecha y hora son obligatorias')),
      );
      return;
    }

    // Validación mínima de formato fecha
    try {
      DateFormat('yyyy-MM-dd').parseStrict(date);
      DateFormat('HH:mm').parseStrict(time);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Formato de fecha/hora inválido. Usa YYYY-MM-DD y HH:MM'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final jwt = await _getJwt();
      if (jwt == null || jwt.isEmpty) {
        throw Exception('No se encontró token de usuario');
      }

      final req = IncomeUpdateRequest(
        amount: amount,
        date: date,
        time: time,
        notes: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
      );

      final res = await _service.actualizarIngreso(
        jwt: jwt,
        idIncome: _income.idIncome,
        req: req,
      );

      if (!mounted) return;

      if (res.code == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso actualizado')),
        );
        Navigator.of(context).pop('updated');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar ingreso: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomTextTitle('Editar ingreso'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: SizedBox(
                width: 335,
                child: CustomTextField(
                  label: 'Monto',
                  controller: _montoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 335,
                child: CustomTextField(
                  label: 'Fecha (YYYY-MM-DD)',
                  controller: _fechaCtrl,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 335,
                child: CustomTextField(
                  label: 'Hora (HH:MM)',
                  controller: _horaCtrl,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 335,
                child: CustomTextField(
                  label: 'Notas (opcional)',
                  controller: _notasCtrl,
                  maxLines: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : CustomButton(
              text: 'Guardar cambios',
              backgroundColor: AppColor.azulFynso,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
