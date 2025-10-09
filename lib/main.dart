import 'package:flutter/material.dart';
import 'package:fynso/features/agregar/view/editar_gasto_screen.dart';
import 'package:fynso/features/home/view/home_screen.dart';
import 'package:fynso/features/splash/view/splash_screen.dart';

import 'common/navigation/main_navigation.dart';
import 'features/agregar/view/detalle_gasto_screen.dart';
import 'features/agregar/view/grabar_gasto_screen.dart';
import 'features/agregar/view/historial_gastos_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fynso',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, //
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Roboto', // para toda la app
      ),
      home: const SplashScreen(),

      // 👇 Rutas disponibles en toda la app
      routes: {
        '/home': (context) => const HomeScreen(),
        '/historialGastos': (context) => const HistorialGastosScreen(),
        '/detalleGasto': (context) => const DetalleGastoScreen(),
        '/grabarGasto': (context) => const GrabarGastoScreen(),
        '/editarGasto': (context) => const EditarGastoScreen(),
      },
    );
  }
}
