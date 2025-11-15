import 'package:flutter/material.dart';
import 'package:fynso/common/widgets/custom_text_title.dart';
import 'package:fynso/data/models/transaction_detail_response.dart';
import 'package:fynso/features/agregar/view_model/transaction_detail_view_model.dart';
import 'package:provider/provider.dart';
import '../../../common/themes/app_color.dart';
import '../../../common/widgets/fynso_card_dialog.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../data/models/transaction_detail_request.dart'; // para formatFecha y formatMonto
import '../../../common/utils/utils.dart';

class DetalleGastoScreen extends StatefulWidget {
  const DetalleGastoScreen({super.key});

  @override
  State<DetalleGastoScreen> createState() => _DetalleGastoScreenState();
}

class _DetalleGastoScreenState extends State<DetalleGastoScreen> {
  late TransactionDetailViewModel viewModel;

  // 👇 Guarda los args para poder recargar luego
  TransactionDetailRequest? _args;

  @override
  void initState() {
    super.initState();
    viewModel = TransactionDetailViewModel();

    // Cargamos la transacción usando el objeto TransactionDetailRequest
    Future.microtask(() async {
      final args =
          ModalRoute.of(context)?.settings.arguments
              as TransactionDetailRequest?;
      if (args != null) {
        _args = args; // <- los guardamos para recargar más tarde
        await viewModel.loadTransactionDetail(
          jwt: args.jwt,
          idTransaction: args.idTransaction,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<TransactionDetailViewModel>(
        builder: (context, vm, _) {
          final t = vm.transaction;

          return Scaffold(
            appBar: AppBar(
              title: const CustomTextTitle('Detalle del gasto'),
              elevation: 1,
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.error != null
                ? Center(child: Text(vm.error!))
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
                            _buildInfoRow('Categoría', t.category.nombre),
                            _buildInfoRow('Subcategoría', t.subcategory.nombre),
                            _buildInfoRow('Tipo', t.transactionType.nombre),
                            _buildInfoRow('Monto', 'S/${formatMonto(t.monto)}'),
                            _buildInfoRow('Fecha', formatFecha(t.fecha)),
                            if (t.lugar != null && t.lugar!.isNotEmpty)
                              _buildInfoRow('Lugar', t.lugar!),
                            if (t.descripcion.isNotEmpty)
                              _buildInfoRow('Descripción', t.descripcion),
                            if (t.transcripcion != null &&
                                t.transcripcion!.isNotEmpty)
                              _buildInfoRow('Transcripción', t.transcripcion!),
                            const SizedBox(height: 24),
                            Center(
                              child: CustomButton(
                                text: 'Editar Gasto',
                                backgroundColor: AppColor.azulFynso,
                                onPressed: () async {
                                  // 👇 Espera el resultado del editor
                                  final result = await Navigator.pushNamed(
                                    context,
                                    '/editarGasto',
                                    arguments: t.toTransactionResponse(),
                                  );

                                  // Si volvió con éxito (no null), recarga el detalle
                                  if (result != null && _args != null) {
                                    await vm.loadTransactionDetail(
                                      jwt: _args!.jwt,
                                      idTransaction: _args!.idTransaction,
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: CustomButton(
                                text: 'Eliminar Gasto',
                                backgroundColor: Colors.redAccent,
                                onPressed: () async {
                                  if (_args == null) return;
                                  final confirm = await showFynsoCardDialog<bool>(
                                    context: context,
                                    title: 'Eliminar gasto',
                                    message:
                                        '¿Seguro que deseas eliminar este gasto? Esta acción no se puede deshacer.',
                                    icon: Icons.delete_outline,
                                    actions: [
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          side: BorderSide(
                                            color: AppColor.azulFynso,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          minimumSize: const Size.fromHeight(
                                            44,
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          minimumSize: const Size.fromHeight(
                                            44,
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  );
                                  if (confirm != true) return;

                                  final ok = await vm.deleteTransaction(
                                    jwt: _args!.jwt,
                                    idTransaction: _args!.idTransaction,
                                  );
                                  if (!mounted) return;
                                  if (ok) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Gasto eliminado'),
                                      ),
                                    );
                                    Navigator.of(context).pop('deleted');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          vm.error ?? 'No se pudo eliminar',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
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

