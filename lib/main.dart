import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fynso/features/auth/view/terms_screen.dart';
import 'package:provider/provider.dart'; // 👈 necesario

import 'common/navigation/route_observer.dart';
import 'features/auth/view/login_screen.dart';
import 'features/splash/view/splash_screen.dart';
import 'features/home/view/home_screen.dart';
import 'features/agregar/view/editar_gasto_screen.dart';
import 'features/agregar/view/detalle_gasto_screen.dart';
import 'features/agregar/view/grabar_gasto_screen.dart';
import 'features/agregar/view/historial_gastos_screen.dart';
import 'features/pago/view/aprobado_screen.dart';
import 'features/pago/view/pago_screen.dart';
import 'features/pago/view/rechazado_screen.dart';
import 'features/analytics/view/category_breakdown_screen.dart';

// 👇 Importa solo este ViewModel
import 'features/auth/view_model/auth_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(), // 👈 solo uno
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fynso',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'Roboto',
        ),

        locale: const Locale('es', 'PE'),
        supportedLocales: const [
          Locale('es', 'PE'),
          Locale('es'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        home: const SplashScreen(),

        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/historialGastos': (context) => const HistorialGastosScreen(),
          '/detalleGasto': (context) => const DetalleGastoScreen(),
          '/grabarGasto': (context) => const GrabarGastoScreen(),
          '/editarGasto': (context) => const EditarGastoScreen(),
          '/pago': (context) => const PagoScreen(),
          '/aprobado': (context) => const AprobadoScreen(),
          '/rechazado': (context) => const RechazadoScreen(),
          '/desgloseCategorias': (context) => const CategoryBreakdownScreen(),
          '/terminos': (context) => const TermsScreen(),
        },

        navigatorObservers: [routeObserver],
      ),
    );
  }
}
