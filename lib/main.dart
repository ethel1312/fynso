import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// ViewModels
import 'common/themes/app_color.dart';
import 'common/themes/theme_view_model.dart';
import 'data/services/notification_service.dart';
import 'features/auth/view_model/auth_view_model.dart';
import 'features/auth/view_model/password_view_model.dart';
import 'features/settings/view_model/premium_view_model.dart';

// Pantallas
import 'features/splash/view/splash_screen.dart';
import 'features/auth/view/login_screen.dart';
import 'features/home/view/home_screen.dart';
import 'features/agregar/view/editar_gasto_screen.dart';
import 'features/agregar/view/detalle_gasto_screen.dart';
import 'features/agregar/view/grabar_gasto_screen.dart';
import 'features/agregar/view/historial_gastos_screen.dart';
import 'features/pago/view/aprobado_screen.dart';
import 'features/pago/view/pago_screen.dart';
import 'features/pago/view/rechazado_screen.dart';
import 'features/pago/view/pendiente_screen.dart';
import 'features/analytics/view/category_breakdown_screen.dart';
import 'features/auth/view/terms_screen.dart';
import 'common/navigation/route_observer.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fynso/data/services/notification_service.dart';
// ... tus otros imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await NotificationService.init(); // solo inicializa
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PasswordViewModel()),
        ChangeNotifierProvider(create: (_) => PremiumViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Fynso',
            themeMode: themeVM.currentTheme,

            // 👈 cambia en tiempo real
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              cardColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
              ),
              cardTheme: const CardThemeData(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              colorScheme: const ColorScheme.light(
                primary: Colors.deepPurple,
                secondary: Colors.deepPurpleAccent,
                surface: Colors.white,
                background: Colors.white,
                onSurface: Colors.black87,
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.black87),
                bodyMedium: TextStyle(color: Colors.black87),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black, // texto negro
                  side: const BorderSide(color: AppColor.azulFynso),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.azulFynso, // Azul Fynso
                ),
              ),
              fontFamily: 'Roboto',
            ),

            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              cardTheme: const CardThemeData(
                color: Color(0xFF1E1E1E),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              colorScheme: const ColorScheme.dark(
                primary: Colors.amber,
                secondary: Colors.amberAccent,
                surface: Color(0xFF1E1E1E),
                background: Color(0xFF121212),
                onSurface: Colors.white70,
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white70),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white, // texto e iconos blancos
                  side: const BorderSide(color: Colors.white), // borde blanco
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.azulFynso, // Blanco en oscuro
                ),
              ),
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
              '/pendiente': (context) => const PendienteScreen(),
              '/desgloseCategorias': (context) =>
                  const CategoryBreakdownScreen(),
              '/terminos': (context) => const TermsScreen(),
            },

            navigatorObservers: [routeObserver],
          );
        },
      ),
    );
  }
}
