import 'package:flutter/material.dart';
import 'package:fynso/common/widgets/custom_text_title.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_textfield.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
            children: [
              const CustomTextTitle("Regístrate"),
              const SizedBox(height: 20),
              // Usando CustomTextField
              const CustomTextField(label: "Nombre de usuario"),
              const SizedBox(height: 16),
              const CustomTextField(
                label: "Correo electrónico",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const CustomTextField(label: "Contraseña", isPassword: true),
              const SizedBox(height: 24),

              CustomButton(
                text: "Regístrate",
                backgroundColor: const Color(0xFF1565C0),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
