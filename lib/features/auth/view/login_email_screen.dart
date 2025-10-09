import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fynso/common/themes/app_color.dart';
import 'package:fynso/features/auth/view/forgot_password_screen.dart';
import 'package:fynso/features/auth/view/terms_screen.dart';
import '../../../common/navigation/main_navigation.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_blue.dart';
import '../../../common/widgets/custom_textfield.dart';
import '../../../common/widgets/custom_text_title.dart';
import '../../home/view/home_screen.dart';
import '../view_model/auth_view_model.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthViewModel _authViewModel = AuthViewModel();

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese usuario y contraseña')),
      );
      return;
    }

    try {
      await _authViewModel.login(username, password);

      if (_authViewModel.authResponse != null) {
        // Login exitoso → navegar al HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const MainNavigation(), // Importa tu HomeScreen
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario o contraseña incorrectos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al iniciar sesión: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: AnimatedBuilder(
        animation: _authViewModel,
        builder: (context, _) {
          return Stack(
            children: [
              // Contenido principal
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      CustomTextField(
                        label: "Usuario o correo",
                        controller: _usernameController,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: "Contraseña",
                        isPassword: true,
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: CustomTextBlue(
                          text: "¿Has olvidado tu contraseña?",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

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
                                  color: AppColor.azulFynso,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TermsScreen(),
                                      ),
                                    );
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
                        backgroundColor: AppColor.azulFynso,
                        onPressed: _authViewModel.isLoading
                            ? null
                            : () => _login(),
                      ),
                    ],
                  ),
                ),
              ),

              // Loader (aparece encima cuando está cargando)
              if (_authViewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColor.azulFynso),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
