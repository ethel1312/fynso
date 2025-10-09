import 'package:flutter/material.dart';
import 'package:fynso/data/models/transaction_detail_response.dart';
import 'package:fynso/features/agregar/view_model/transaction_detail_view_model.dart';
import 'package:provider/provider.dart';
import '../../../common/themes/app_color.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../data/models/transaction_detail_request.dart'; // para formatFecha y formatMonto

class DetalleGastoScreen extends StatefulWidget {
  const DetalleGastoScreen({super.key});

  @override
  State<DetalleGastoScreen> createState() => _DetalleGastoScreenState();
}

class _DetalleGastoScreenState extends State<DetalleGastoScreen> {
  late TransactionDetailViewModel viewModel;
  late int idTransaction;

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
              title: const Text('Detalle del gasto'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
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
                                  if (t == null) return;

                                  Navigator.pushNamed(
                                    context,
                                    '/editarGasto',
                                    arguments: t
                                        .toTransactionResponse(), // t ya es TransactionResponse
                                  );
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
