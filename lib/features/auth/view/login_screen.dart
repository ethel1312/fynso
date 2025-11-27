import 'dart:math';

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
              onPressed: () async {},
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
