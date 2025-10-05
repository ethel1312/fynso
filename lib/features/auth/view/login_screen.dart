import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fynso/common/widgets/custom_text_blue.dart';
import 'package:fynso/features/auth/view/login_email_screen.dart';
import 'package:fynso/features/auth/view/register_screen.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_title.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomTextTitle("Inicia sesión con:"),
            const SizedBox(height: 40),
            CustomButton(
              text: "Correo electrónico",
              backgroundColor: const Color(0xFF1565C0),
              icon: const Icon(Icons.email, color: Colors.white, size: 24),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginEmailScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: "Google",
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

              onPressed: () {},
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
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
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
