import 'package:flutter/material.dart';
import '../../../common/themes/app_color.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_textfield.dart';
import '../../../common/widgets/custom_text_title.dart';

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key});

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
              const CustomTextTitle("Nueva contraseña"),
              const SizedBox(height: 8),
              const Text(
                "Por favor escribe tu nueva contraseña",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 32),

              // Inputs de contraseña
              const CustomTextField(label: "Contraseña", isPassword: true),
              const SizedBox(height: 16),
              const CustomTextField(
                label: "Confirmar contraseña",
                isPassword: true,
              ),
              const SizedBox(height: 32),

              // Botón cambiar contraseña
              CustomButton(
                text: "Cambiar contraseña",
                backgroundColor: AppColor.azulFynso,
                onPressed: () async {
                  // Lógica para cambiar contraseña
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
