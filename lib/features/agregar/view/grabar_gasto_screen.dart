import 'package:flutter/material.dart';
import 'package:fynso/common/themes/app_color.dart';
import 'dart:async';

import '../../../common/widgets/custom_button.dart';

class GrabarGastoScreen extends StatefulWidget {
  const GrabarGastoScreen({super.key});

  @override
  State<GrabarGastoScreen> createState() => _GrabarGastoScreenState();
}

class _GrabarGastoScreenState extends State<GrabarGastoScreen>
    with SingleTickerProviderStateMixin {
  bool isRecording = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      isRecording = !isRecording;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRecording ? '🎙️ Grabación iniciada' : '⏹️ Grabación detenida',
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    if (isRecording) {
      Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => isRecording = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Grabar gasto'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home'); // ir al Home
          },
        ),
      ),
      body: Center(
        // 🔹 Centra todo el contenido horizontal y verticalmente
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // 🔹 Centrado vertical ajustado
            crossAxisAlignment: CrossAxisAlignment.center,
            // 🔹 Centrado horizontal
            children: [
              const Text(
                'Presiona el botón para grabar tu gasto',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 🔹 Botón centrado con animación
              ScaleTransition(
                scale: isRecording
                    ? _animation
                    : const AlwaysStoppedAnimation(1),
                child: GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isRecording
                          ? Colors.redAccent
                          : AppColor.azulFynso,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isRecording
                                      ? Colors.redAccent
                                      : AppColor.azulFynso)
                                  .withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                isRecording ? "Grabando..." : "Listo para grabar",
                style: TextStyle(
                  color: isRecording ? Colors.redAccent : Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 60),

              // Botón personalizado para ver historial de gastos
              CustomButton(
                text: 'Ver historial de gastos',
                backgroundColor: AppColor.azulFynso,
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: () async {
                  Navigator.pushNamed(context, '/historialGastos');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
