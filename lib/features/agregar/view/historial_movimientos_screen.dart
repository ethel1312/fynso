import 'package:flutter/material.dart';
import 'package:fynso/common/themes/app_color.dart';
import 'package:fynso/common/widgets/custom_text_title.dart';

import 'historial_gastos_screen.dart';
import 'historial_ingresos_screen.dart';

class HistorialMovimientosScreen extends StatelessWidget {
  const HistorialMovimientosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const CustomTextTitle('Historial'),
          elevation: 0, // igual que en RegistrarMovimientosScreen
          bottom: TabBar(
            labelColor: AppColor.azulFynso,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
            // 👇 ahora sin AppBar interno
            HistorialGastosScreen(showAppBar: false),
            HistorialIngresosScreen(showAppBar: false),
          ],
        ),
      ),
    );
  }
}
