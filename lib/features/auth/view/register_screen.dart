import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fynso/common/widgets/custom_text_blue.dart';
import 'package:fynso/common/widgets/custom_text_title.dart';
import '../../../common/themes/app_color.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_textfield.dart';
import '../view_model/auth_view_model.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final result = await authVM.register(username, email, password);

    if (result != null && result['code'] == 1) {
      // Registro exitoso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Registro exitoso')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar usuario')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

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
            children: [
              const CustomTextTitle("Regístrate"),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _usernameController,
                label: "Nombre de usuario",
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                label: "Correo electrónico",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _passwordController,
                label: "Contraseña",
                isPassword: true,
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: authVM.isLoading ? "Registrando..." : "Regístrate",
                backgroundColor: AppColor.azulFynso,
                onPressed: authVM.isLoading ? null : _handleRegister,
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿Ya tienes una cuenta? "),
                  CustomTextBlue(
                    text: "Iniciar sesión",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
