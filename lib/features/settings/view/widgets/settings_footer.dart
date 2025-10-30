import 'package:flutter/material.dart';
import 'package:fynso/common/themes/app_color.dart';
import 'package:fynso/common/widgets/custom_text_blue.dart';

class SettingsFooter extends StatelessWidget {
  const SettingsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Fynso v1.0.0", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        CustomTextBlue(
          text: "Términos y condiciones",
          isBold: false, // si quieres que se vea más liviano
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/terminos',
            ); // o tu ruta correspondiente
          },
        ),
      ],
    );
  }
}
