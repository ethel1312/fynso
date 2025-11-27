import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fynso/common/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/view/login_screen.dart';
import '../../../common/utils/timezone.dart';
import '../../../data/repositories/monthly_limit_repository.dart';
import '../../../common/navigation/main_navigation.dart';
import '../../../common/widgets/fynso_card_dialog.dart';
import '../../../common/themes/app_color.dart';
import '../../onboarding/view/onboarding_screen.dart';

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
      final canContinue = await _checkAppUpdateAndMaybeShowDialog();
      if (!canContinue) {
        // Hay una actualización forzada. No navegamos a ningún lado.
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      // 🔹 Check onboarding
      final seenOnboarding = prefs.getBool('onboarding_seen') ?? false;
      if (!seenOnboarding) {
        _navigated = true;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
        );
        return;
      }

      // 🔹 Check JWT
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

  Future<bool> _checkAppUpdateAndMaybeShowDialog() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final versionCode = int.tryParse(info.buildNumber) ?? 0;

      const baseUrl = Config.baseUrl;
      final uri = Uri.parse('$baseUrl/api/app/check_update').replace(
        queryParameters: {
          'platform': 'android',
          'version_code': '$versionCode',
        },
      );

      final resp = await http.get(uri, headers: {'Accept': 'application/json'});

      if (resp.statusCode != 200) {
        return true;
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      if ((decoded['code'] ?? 0) != 1) {
        return true;
      }

      final data = (decoded['data'] as Map<String, dynamic>?) ?? {};
      final hasUpdate = data['has_update'] == true;
      if (!hasUpdate) {
        return true;
      }

      final forceUpdate = data['force_update'] == true;
      final latest = (data['latest'] as Map<String, dynamic>?) ?? {};
      final versionName = latest['version_name']?.toString() ?? '';
      final downloadUrl = latest['download_url']?.toString() ?? '';
      final releaseNotes = latest['release_notes']?.toString() ?? '';

      if (downloadUrl.isEmpty) {
        return true;
      }

      if (forceUpdate) {
        await showFynsoCardDialog<void>(
          context,
          title: 'Actualización obligatoria',
          message: versionName.isNotEmpty
              ? 'Debes actualizar a la versión $versionName para seguir usando Fynso.\n\n$releaseNotes'
              : 'Debes actualizar la aplicación para seguir usando Fynso.\n\n$releaseNotes',
          icon: Icons.system_update_alt,
          barrierDismissible: false,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.azulFynso,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: () async {
                await _openUpdateUrl(downloadUrl);
              },
              child: const Text('Actualizar ahora'),
            ),
          ],
        );
        return false;
      } else {
        final choice = await showFynsoCardDialog<String>(
          context,
          title: 'Nueva versión disponible',
          message: versionName.isNotEmpty
              ? 'Hay una nueva versión de Fynso ($versionName) disponible.\n\n$releaseNotes'
              : 'Hay una nueva versión de Fynso disponible.\n\n$releaseNotes',
          icon: Icons.system_update_alt,
          barrierDismissible: true,
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: BorderSide(color: AppColor.azulFynso),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: () => Navigator.pop(context, 'later'),
              child: const Text('Más tarde'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.azulFynso,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: () => Navigator.pop(context, 'update'),
              child: const Text('Actualizar'),
            ),
          ],
        );

        if (choice == 'update') {
          await _openUpdateUrl(downloadUrl);
        }

        return true;
      }
    } catch (_) {
      return true;
    }
  }

  Future<void> _openUpdateUrl(String urlStr) async {
    final uri = Uri.tryParse(urlStr);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColor.azulFynso.withOpacity(0.4), // parte superior más clara
              AppColor.azulFynso, // parte inferior más intensa
            ],
          ),
        ),
        child: const Center(
          child: Text(
            "Fynso",
            style: TextStyle(
              color: Colors.white, // letra blanca
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
