import 'package:flutter/material.dart';
import 'package:fynso/features/splash/view/splash_screen.dart';

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
    );
  }
}
