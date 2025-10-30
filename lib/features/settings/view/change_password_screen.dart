import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/themes/app_color.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_textfield.dart';
import '../../../common/widgets/custom_text_title.dart';
import '../../auth/view/verify_code_screen.dart';
import '../../auth/view_model/password_view_model.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email != null) {
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendCode(BuildContext context) async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu correo electrónico')),
      );
      return;
    }

    final viewModel = Provider.of<PasswordViewModel>(context, listen: false);
    final success = await viewModel.sendVerificationCode(email);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.successMessage ?? 'Código enviado')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const VerifyCodeScreen(),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al enviar código'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cambiar contraseña',
          style: TextStyle(color: Colors.black),
        ),
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
              const CustomTextTitle("Cambiar contraseña"),
              const SizedBox(height: 8),
              const Text(
                "Para cambiar tu contraseña, confirma tu correo electrónico y te enviaremos un código de verificación.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 32),

              // Input correo
              CustomTextField(
                label: "Correo electrónico",
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 24),

              // Botón confirmar correo
              Consumer<PasswordViewModel>(
                builder: (context, viewModel, child) {
                  return CustomButton(
                    text: viewModel.isLoading ? "Enviando..." : "Enviar código",
                    backgroundColor: AppColor.azulFynso,
                    onPressed: viewModel.isLoading ? null : () async => _sendCode(context),
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
