import 'package:flutter/material.dart';
import 'package:fynso/common/themes/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../data/repositories/audio_repository.dart';
import '../../../data/services/audio_service.dart';
import '../view_model/grabar_gasto_viewmodel.dart';
import '../../../data/models/transcribe_response.dart';

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

  final recorder = FlutterSoundRecorder();
  String? audioPath;
  late GrabarGastoViewModel viewModel;

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

    // Inicializa ViewModel
    viewModel = GrabarGastoViewModel(AudioRepository(AudioService()));

    // Inicializa recorder de manera segura
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    // Solicitar permisos
    if (!await Permission.microphone.isGranted) {
      await Permission.microphone.request();
    }

    await recorder.openRecorder();
  }

  @override
  void dispose() {
    _controller.dispose();
    recorder.closeRecorder();
    super.dispose();
  }

  Future<void> startRecording() async {
    try {
      await recorder.openRecorder();

      Directory dir = await getApplicationDocumentsDirectory();
      audioPath = '${dir.path}/gasto.m4a';

      await recorder.startRecorder(toFile: audioPath, codec: Codec.aacMP4);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al iniciar grabación: $e')));
    }
  }

  Future<void> stopRecording() async {
    try {
      await recorder.stopRecorder();

      if (audioPath == null) return;

      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');

      print("🟢 JWT leído antes de enviar audio: $jwt"); // <-- agrega esto

      if (jwt == null || jwt.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró token de usuario')),
        );
        return;
      }

      await viewModel.enviarAudio(File(audioPath!), jwt);

      if (viewModel.transcribeResult != null &&
          viewModel.transcribeResult!.extracted.isNotEmpty) {
        final gasto = viewModel.transcribeResult!.extracted;
        Navigator.pushNamed(context, '/detalleGasto', arguments: gasto);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo extraer información del audio'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al detener grabación: $e')));
    }
  }

  void _toggleRecording() async {
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
      await startRecording();
    } else {
      await stopRecording();
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
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Presiona el botón para grabar tu gasto',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
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
