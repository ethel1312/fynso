import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/view/login_screen.dart';
import '../../../common/utils/timezone.dart';
import '../../../data/repositories/monthly_limit_repository.dart';
import '../../../common/navigation/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  static const _kLastReconKey = 'last_reconcile_yyyymm';
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fireAndForgetReconcileOncePerMonth();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _decideAndNavigateSafely();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _decideAndNavigateSafely() async {
    if (!mounted || _navigated) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token') ?? '';
      if (jwt.isNotEmpty) {
        _navigated = true;
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false,
        );
        return;
      }

      // Pequeño delay solo para mostrar el splash si no hay sesión
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted || _navigated) return;
      final Widget target = const LoginScreen();
      if (!mounted || _navigated) return;
      _navigated = true;
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => target),
        (route) => false,
      );
    } catch (_) {
      if (!mounted || _navigated) return;
      _navigated = true;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Llama reconcile cuando la app vuelve al frente (por si cambió de mes en background)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fireAndForgetReconcileOncePerMonth();
    }
  }

  Future<void> _fireAndForgetReconcileOncePerMonth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token') ?? '';
      if (jwt.isEmpty) return;

      final tzName = await TimezoneUtil.deviceTimeZone();

      // yyyymm local para evitar repetir reconcile el mismo mes
      final now = DateTime.now();
      final yyyymm =
          '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}';
      final last = prefs.getString(_kLastReconKey);

      if (last == yyyymm) return; // ya se reconcilió este mes

      await MonthlyLimitRepository().reconcile(
        jwt: jwt,
        tzName: tzName,
        // Usa el default del usuario si existe:
        applyDefaultLimit: false,
        // Este valor se ignora cuando applyDefaultLimit=false
        defaultLimit: '0.00',
      );

      await prefs.setString(_kLastReconKey, yyyymm);
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
