import 'package:flutter/material.dart';

import '../../../common/themes/app_color.dart';
import '../../../common/widgets/custom_text_title.dart';
import '../../../data/repositories/income_repository.dart';
import 'agregar_gasto_screen.dart';
import 'agregar_ingreso_screen.dart';

class RegistrarMovimientosScreen extends StatelessWidget {
  const RegistrarMovimientosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const CustomTextTitle('Registrar'),
          bottom: TabBar(
            labelColor: AppColor.azulFynso,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColor.azulFynso,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: "Gastos"),
              Tab(text: "Ingresos"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AgregarGastoScreen(),
            // Tu pantalla actual
            AgregarIngresoScreen(),
            // Nueva pantalla sencilla
          ],
        ),
      ),
    );
  }
}
