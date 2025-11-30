import 'dart:math';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fynso/features/auth/view_model/auth_view_model.dart';
import 'package:fynso/common/navigation/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fynso/common/widgets/custom_text_blue.dart';
import 'package:fynso/features/auth/view/login_email_screen.dart';
import 'package:fynso/features/auth/view/register_screen.dart';
import '../../../common/themes/app_color.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_title.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  Future<void> _loginWithGoogle(BuildContext context) async {
    try {
      final signIn = GoogleSignIn.instance;

      // 1) Inicializar SOLO con tu Web Client ID como serverClientId
      await signIn.initialize(
        clientId: null, // en Android, normalmente null
        serverClientId:
        '801639122878-kt2tnbo7h4p79t4086hrir2tokd3k8ek.apps.googleusercontent.com',
      );

      // 2) Verificar que la plataforma soporta authenticate()
      if (!signIn.supportsAuthenticate()) {
        debugPrint('❌ GoogleSignIn no soporta authenticate() en este dispositivo');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este dispositivo no soporta Google Sign-In.'),
          ),
        );
        return;
      }

      // 3) Flujo interactivo: usuario elige cuenta
      final GoogleSignInAccount account = await signIn.authenticate();

      debugPrint('✅ GoogleSignIn authenticate OK: ${account.email}');

      // 4) Obtener idToken (para enviarlo a tu backend)
      final GoogleSignInAuthentication googleAuth = account.authentication;
      final String? idToken = googleAuth.idToken;

      debugPrint('✅ GoogleSignIn idToken: ${idToken != null ? 'obtenido' : 'null'}');

      if (idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener el idToken de Google.'),
          ),
        );
        return;
      }

      // 5) Login en tu backend con AuthViewModel
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final ok = await authVM.loginWithGoogle(idToken, account.email);

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo iniciar sesión con Google.'),
          ),
        );
        return;
      }

// 👇 Igual que en LoginEmailScreen: limpiar stack y mandar a MainNavigation
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
      );
    } on GoogleSignInException catch (e) {
      // 🔍 AQUÍ AHORA LOGEAMOS TODO, incluso cuando sea "canceled"
      debugPrint(
          '❌ GoogleSignInException code=${e.code} description=${e.description}');

      String msg;
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // OJO: canceled también se usa cuando el framework de credenciales falla
        msg = 'Inicio de sesión cancelada o fallida.';
      } else {
        msg = 'Error al iniciar sesión con Google: ${e.code.name} '
            '(${e.description ?? 'sin descripción'})';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      debugPrint('❌ Error inesperado en _loginWithGoogle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    }
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomTextTitle("Inicia sesión con:"),
            const SizedBox(height: 40),

            // --- Correo botón ---
            CustomButton(
              text: "Correo electrónico",
              backgroundColor: AppColor.azulFynso,
              icon: const Icon(Icons.email, color: Colors.white, size: 24),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginEmailScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            // ---------------- GOOGLE BUTTON ----------------
            CustomButton(
              text: _isLoading ? "Cargando..." : "Google",
              backgroundColor: Colors.red,
              icon: SvgPicture.asset(
                "assets/icons/google_logo.svg",
                height: 24,
                width: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () async {
                await _loginWithGoogle(context);
              },
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("¿No tienes una cuenta?"),
                CustomTextBlue(
                  text: "Regístrate",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
