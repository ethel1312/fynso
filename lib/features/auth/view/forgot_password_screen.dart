import 'package:flutter/material.dart';
import 'package:fynso/common/themes/app_color.dart';
import 'package:fynso/features/auth/view/verify_code_screen.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_textfield.dart';
import '../../../common/widgets/custom_text_title.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CustomTextTitle("¿Olvidaste tu contraseña?"),
              const SizedBox(height: 8),
              const Text(
                "Por favor escribe tu correo electrónico para recibir un código de confirmación para establecer una nueva contraseña.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 32),

              // Input correo
              const CustomTextField(
                label: "Correo electrónico",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Botón confirmar código
              CustomButton(
                text: "Confirmar correo",
                backgroundColor: AppColor.azulFynso,
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VerifyCodeScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
