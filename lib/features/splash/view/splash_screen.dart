import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/view/login_screen.dart';
import '../../../common/utils/timezone.dart';
import '../../../data/repositories/monthly_limit_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _fireAndForgetReconcile();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  Future<void> _fireAndForgetReconcile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token') ?? '';
      if (jwt.isEmpty) return;

      final tzName = await TimezoneUtil.deviceTimeZone();

      await MonthlyLimitRepository().reconcile(
        jwt: jwt,
        tzName: tzName,
        applyDefaultLimit: false,
        defaultLimit: '0.00',
      );
    } catch (_) {
      // silencioso
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          "Fynso",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
