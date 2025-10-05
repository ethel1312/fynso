import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_blue.dart';
import '../../../common/widgets/custom_textfield.dart';
import '../../../common/widgets/custom_text_title.dart';

class LoginEmailScreen extends StatelessWidget {
  const LoginEmailScreen({super.key});

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
            // inputs y botón ocupan todo el ancho disponible
            children: [
              const CustomTextTitle("Bienvenido"),
              const SizedBox(height: 8),
              const Text(
                "Por favor ingrese sus datos para continuar",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 32),

              // Inputs
              const CustomTextField(label: "Usuario o correo"),
              const SizedBox(height: 16),
              const CustomTextField(label: "Contraseña", isPassword: true),
              const SizedBox(height: 8),

              // "Olvidaste tu contraseña?"
              Align(
                alignment: Alignment.centerRight,
                child: CustomTextBlue(
                  text: "¿Has olvidado tu contraseña?",
                  onPressed: () {
                    // acción recuperar contraseña
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Nota Términos y condiciones con RichText
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: Colors.black54,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            "Al conectar su cuenta, confirme que acepta nuestros ",
                      ),
                      TextSpan(
                        text: "Términos y Condiciones",
                        style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Acción para abrir Términos y Condiciones
                          },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón Iniciar sesión
              CustomButton(
                text: "Iniciar sesión",
                backgroundColor: const Color(0xFF1565C0),
                onPressed: () {
                  // acción login
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
