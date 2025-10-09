import 'package:flutter/material.dart';
import 'package:fynso/features/auth/view/new_password_screen.dart';
import '../../../common/themes/app_color.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_title.dart';

class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({super.key});

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
              const CustomTextTitle("Verificar Código"),
              const SizedBox(height: 16),
              const Text(
                "Ingresa el código de 4 dígitos que enviamos a tu correo electrónico.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 32),

              // Inputs del código
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 60,
                    height: 60,
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 24),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 3) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Botón confirmar
              CustomButton(
                text: "Confirmar código",
                backgroundColor: AppColor.azulFynso,
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewPasswordScreen(),
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
