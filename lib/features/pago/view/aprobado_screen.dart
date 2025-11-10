import 'package:flutter/material.dart';
import 'package:fynso/common/widgets/custom_button.dart';
import 'package:lottie/lottie.dart';

import '../../../common/themes/app_color.dart';

class AprobadoScreen extends StatelessWidget {
  const AprobadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎉 Animación Lottie
                Lottie.asset(
                  'assets/animations/success.json',
                  width: 180,
                  height: 180,
                  repeat: false,
                ),
                const SizedBox(height: 32),

                // Texto principal
                const Text(
                  '¡Pago aprobado!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColor.azulFynso,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Column(
                  children: [
                    const Text(
                      'Tu suscripción se activó correctamente.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Gracias por confiar en Fynso Premium',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Botón principal
                CustomButton(
                  text: "Volver al inicio",
                  backgroundColor: AppColor.azulFynso,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 60),

                // Texto pequeño final
                const Text(
                  'Fynso • Suscripción mensual',
                  style: TextStyle(fontSize: 13, color: Colors.black38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
