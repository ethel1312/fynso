import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 👈 NUEVO

import 'package:fynso/features/agregar/view/editar_gasto_screen.dart';
import 'package:fynso/features/home/view/home_screen.dart';
import 'package:fynso/features/pago/view/aprobado_screen.dart';
import 'package:fynso/features/pago/view/pago_screen.dart';
import 'package:fynso/features/pago/view/rechazado_screen.dart';
import 'package:fynso/features/splash/view/splash_screen.dart';

import 'common/navigation/main_navigation.dart';
import 'common/navigation/route_observer.dart';

import 'features/agregar/view/detalle_gasto_screen.dart';
import 'features/agregar/view/grabar_gasto_screen.dart';
import 'features/agregar/view/historial_gastos_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fynso',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Roboto',
      ),

      // 👇 Localización
      // Si quieres que siga el idioma del sistema, elimina 'locale' y deja solo supportedLocales + delegates
      locale: const Locale('es', 'PE'),
      supportedLocales: const [
        Locale('es', 'PE'),
        Locale('es'),        // fallback general en español
        Locale('en', 'US'),  // opcional: inglés
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const SplashScreen(),

      // Rutas disponibles en toda la app
      routes: {
        '/home': (context) => const HomeScreen(),
        '/historialGastos': (context) => const HistorialGastosScreen(),
        '/detalleGasto': (context) => const DetalleGastoScreen(),
        '/grabarGasto': (context) => const GrabarGastoScreen(),
        '/editarGasto': (context) => const EditarGastoScreen(),
        '/pago': (context) => const PagoScreen(),
        '/aprobado': (context) => const AprobadoScreen(),
        '/rechazado': (context) => const RechazadoScreen(),
      },

      // Importante para que RouteAware funcione
      navigatorObservers: [routeObserver],
    );
  }
}
