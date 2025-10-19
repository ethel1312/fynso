import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fynso/features/agregar/view/widgets/boton_mic.dart';
import 'package:fynso/features/agregar/view/widgets/gasto_card.dart';
import '../../../common/themes/app_color.dart';
import '../../../common/utils/utils.dart';
import '../../../data/models/transaction_detail_request.dart';
import '../../../data/models/transaction_response.dart';
import '../view_model/historial_gastos_view_model.dart';
import 'detalle_gasto_screen.dart';
import 'package:intl/intl.dart';

// 👇 Importa el observer global
import '../../../common/navigation/route_observer.dart';

class HistorialGastosScreen extends StatefulWidget {
  const HistorialGastosScreen({super.key});

  @override
  State<HistorialGastosScreen> createState() => _HistorialGastosScreenState();
}

class _HistorialGastosScreenState extends State<HistorialGastosScreen>
    with RouteAware {
  late HistorialGastosViewModel viewModel;
  String jwt = '';

  @override
  void initState() {
    super.initState();
    viewModel = HistorialGastosViewModel();
    _loadTransactions(); // carga inicial
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Se llama cuando volvemos a esta ruta (por ejemplo, cerraste Detalle/Editar)
  @override
  void didPopNext() {
    _loadTransactions(); // recarga al volver
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt_token') ?? '';

    final now = DateTime.now();
    await viewModel.loadTransactions(jwt: jwt, anio: now.year, mes: now.month);

    // Opcional: el notifyListeners del VM ya refresca con el Consumer.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<HistorialGastosViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Historial de gastos'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.transactions.isEmpty
                ? const Center(child: Text('No hay transacciones'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.transactions.length,
              itemBuilder: (context, index) {
                final t = vm.transactions[index];
                return GastoCard(
                  categoria: t.category,
                  subcategoria: t.subcategory,
                  monto: t.monto,
                  fecha: formatFecha(t.fecha),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detalleGasto',
                      arguments: TransactionDetailRequest(
                        idTransaction: t.idTransaction,
                        jwt: jwt,
                      ),
                    );
                  },
                );
              },
            ),
            floatingActionButton: MicButton(
              onPressed: () {
                Navigator.pushNamed(context, '/grabarGasto');
              },
              backgroundColor: AppColor.azulFynso,
            ),
          );
        },
      ),
    );
  }
}
