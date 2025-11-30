import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fynso/common/themes/app_color.dart';
import 'package:fynso/common/widgets/custom_button.dart';
import 'package:fynso/common/widgets/custom_text_title.dart';
import 'package:fynso/common/widgets/fynso_card_dialog.dart';
import 'package:fynso/data/models/income_detail.dart';
import 'package:fynso/data/models/income_update_request.dart';
import 'package:fynso/data/services/income_service.dart';

class DetalleIngresoScreen extends StatefulWidget {
  const DetalleIngresoScreen({super.key});

  @override
  State<DetalleIngresoScreen> createState() => _DetalleIngresoScreenState();
}

class _DetalleIngresoScreenState extends State<DetalleIngresoScreen> {
  final IncomeService _service = IncomeService();

  bool _loading = true;
  String? _error;
  IncomeDetail? _income;
  int? _idIncome;

  @override
  void initState() {
    super.initState();
    Future.microtask(_init);
  }

  Future<void> _init() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _idIncome = args;
      await _loadDetail();
    } else {
      setState(() {
        _error = 'Id de ingreso inválido.';
        _loading = false;
      });
    }
  }

  Future<String?> _getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _loadDetail() async {
    if (_idIncome == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final jwt = await _getJwt();
      if (jwt == null || jwt.isEmpty) {
        setState(() {
          _error = 'No se encontró token de usuario.';
          _loading = false;
        });
        return;
      }

      final detail = await _service.obtenerIngreso(
        jwt: jwt,
        idIncome: _idIncome!,
      );

      setState(() {
        _income = detail;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar ingreso: $e';
        _loading = false;
      });
    }
  }

  Future<void> _delete() async {
    if (_idIncome == null) return;
    final confirm = await showFynsoCardDialog<bool>(
      context,
      title: 'Eliminar ingreso',
      message:
      '¿Seguro que deseas eliminar este ingreso? Esta acción no se puede deshacer.',
      icon: Icons.delete_outline,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: BorderSide(color: AppColor.azulFynso),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size.fromHeight(44),
          ),
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size.fromHeight(44),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Eliminar'),
        ),
      ],
    ) ??
        false;

    if (!confirm) return;

    try {
      final jwt = await _getJwt();
      if (jwt == null || jwt.isEmpty) return;

      final res = await _service.eliminarIngreso(
        jwt: jwt,
        idIncome: _idIncome!,
      );
      if (!mounted) return;

      if (res.code == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso eliminado')),
        );
        Navigator.of(context).pop('deleted');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar ingreso: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _income;

    return Scaffold(
      appBar: AppBar(
        title: const CustomTextTitle('Detalle del ingreso'),
        elevation: 1,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : t == null
          ? const Center(child: Text('No hay datos'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 335,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Monto',
                    'S/ ${t.amount.toStringAsFixed(2)}'),
                _buildInfoRow('Fecha', t.date),
                _buildInfoRow('Hora', t.time),
                if (t.notes != null && t.notes!.isNotEmpty)
                  _buildInfoRow('Notas', t.notes!),
                const SizedBox(height: 24),
                Center(
                  child: CustomButton(
                    text: 'Editar ingreso',
                    backgroundColor: AppColor.azulFynso,
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/editarIngreso',
                        arguments: t,
                      );
                      if (result == 'updated') {
                        await _loadDetail();
                        // avisar al historial
                        if (!mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Ingreso actualizado correctamente',
                            ),
                          ),
                        );
                        Navigator.of(context).pop('updated');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: CustomButton(
                    text: 'Eliminar ingreso',
                    backgroundColor: Colors.redAccent,
                    onPressed: _delete,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: textColor),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
