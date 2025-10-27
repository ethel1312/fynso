import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fynso/common/themes/app_color.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_title.dart';

import '../../../data/services/audio_service.dart';
import '../../../data/repositories/audio_repository.dart';
import '../view_model/grabar_gasto_viewmodel.dart';

// 👉 IMPORTA EL REQUEST QUE USA DetalleGastoScreen
import '../../../data/models/transaction_detail_request.dart';

class GrabarGastoScreen extends StatefulWidget {
  const GrabarGastoScreen({super.key});

  @override
  State<GrabarGastoScreen> createState() => _GrabarGastoScreenState();
}

class _GrabarGastoScreenState extends State<GrabarGastoScreen>
    with SingleTickerProviderStateMixin {
  // UI state
  bool isRecording = false;
  bool isUploading = false;
  bool isStopping = false; // evita taps múltiples al detener

  // Animación del botón
  late AnimationController _controller;
  late Animation<double> _animation;

  // Audio
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _audioPath;

  // VM
  late final GrabarGastoViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = GrabarGastoViewModel(AudioRepository(AudioService()));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..stop(); // solo animar cuando esté grabando

    _animation = Tween<double>(begin: 1.0, end: 1.3)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _safeStopAndClose();
    _controller.dispose();
    super.dispose();
  }

  // ----------------- Permisos -----------------

  Future<void> _showGoToSettingsDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permiso de micrófono requerido'),
        content: const Text(
          'Para grabar tus gastos, habilita el acceso al micrófono en los Ajustes del sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await openAppSettings();
            },
            child: const Text('Abrir ajustes'),
          ),
        ],
      ),
    );
  }

  Future<bool> _ensureMicPermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;

    status = await Permission.microphone.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      await _showGoToSettingsDialog();
    } else {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se requiere el micrófono para grabar')),
      );
    }
    return false;
  }

  // ----------------- Grabación -----------------

  Future<void> _openRecorderIfNeeded() async {
    await _recorder.openRecorder(); // idempotente
  }

  Future<void> _startRecording() async {
    final ok = await _ensureMicPermission();
    if (!ok) return;

    try {
      await _openRecorderIfNeeded();

      final dir = await getApplicationDocumentsDirectory();
      _audioPath = '${dir.path}/gasto.m4a';

      await _recorder.startRecorder(
        toFile: _audioPath,
        codec: Codec.aacMP4,
      );

      setState(() {
        isRecording = true;
        _controller.repeat(reverse: true);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grabación iniciada')),
      );
    } catch (e) {
      setState(() {
        isRecording = false;
        _controller.stop();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar grabación: $e')),
      );
    }
  }

  Future<void> _cancelRecording() async {
    // Cancelar = detener y DESCARTAR archivo, sin subir
    if (!isRecording || isUploading) return;
    try {
      try {
        await _recorder.stopRecorder();
      } catch (_) {}
      // borrar archivo si existe
      if (_audioPath != null) {
        final f = File(_audioPath!);
        if (await f.exists()) {
          await f.delete();
        }
      }
      setState(() {
        isRecording = false;
        _controller.stop();
        _audioPath = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grabación cancelada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cancelar: $e')),
      );
    } finally {
      await _recorder.closeRecorder();
    }
  }

  Future<void> _stopRecordingAndUpload() async {
    if (isStopping) return;
    isStopping = true;

    try {
      // 1) Detener
      try {
        await _recorder.stopRecorder();
      } catch (_) {
        // si ya estaba detenida, ignorar
      }

      setState(() {
        isRecording = false;
        _controller.stop();
      });

      // 2) Revisar archivo
      if (_audioPath == null || !File(_audioPath!).existsSync()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se generó archivo de audio')),
        );
        return;
      }

      // 3) Subir
      setState(() => isUploading = true);

      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');
      if (jwt == null || jwt.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró token de usuario')),
        );
        return;
      }

      await _viewModel.enviarAudio(File(_audioPath!), jwt);

      if (!mounted) return;

      // 4) Navegar al detalle con datos REALES: SIEMPRE TransactionDetailRequest
      final r = _viewModel.transcribeResult;
      if (r != null) {
        // Preferimos el id creado por el backend; si no, usamos el id de la transacción retornada
        final txId = r.createdTransactionId ?? r.transaction?.idTransaction;
        if (txId != null) {
          final req = TransactionDetailRequest(jwt: jwt, idTransaction: txId);
          await Navigator.pushNamed(context, '/detalleGasto', arguments: req);
        } else {
          // Fallback: no hay id -> no podemos cargar detalle por API
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se obtuvo el ID de la transacción')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo extraer información del audio')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar audio: $e')),
        );
      }
    } finally {
      setState(() => isUploading = false);
      isStopping = false;
      await _safeStopAndClose();
    }
  }

  Future<void> _safeStopAndClose() async {
    try {
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
      }
    } catch (_) {}
    try {
      await _recorder.closeRecorder();
    } catch (_) {}
  }

  // ----------------- UI Actions -----------------

  Future<void> _onMicButtonPressed() async {
    if (isUploading) return; // mientras sube, no permitir
    if (!isRecording) {
      await _startRecording();
    } else {
      await _stopRecordingAndUpload();
    }
  }

  // ----------------- Build -----------------

  @override
  Widget build(BuildContext context) {
    final isBusy = isRecording || isUploading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const CustomTextTitle('Grabar gasto'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: isBusy
              ? null
              : () {
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

              // Botón mic con animación solo cuando graba
              ScaleTransition(
                scale: isRecording ? _animation : const AlwaysStoppedAnimation(1),
                child: GestureDetector(
                  onTap: _onMicButtonPressed,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isRecording ? Colors.redAccent : AppColor.azulFynso,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isRecording ? Colors.redAccent : AppColor.azulFynso)
                              .withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Center(
                      child: isUploading
                          ? const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                isUploading
                    ? "Procesando..."
                    : (isRecording ? "Grabando..." : "Listo para grabar"),
                style: TextStyle(
                  color: isUploading
                      ? Colors.blueGrey
                      : (isRecording ? Colors.redAccent : Colors.grey[700]),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Botón Cancelar (solo si está grabando)
              if (isRecording) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: 335,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: isUploading ? null : _cancelRecording,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancelar'),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Ir a historial (bloqueado si está grabando/subiendo)
              CustomButton(
                text: 'Ver historial de gastos',
                backgroundColor: AppColor.azulFynso,
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: isBusy
                    ? null
                    : () async {
                  await Navigator.pushNamed(context, '/historialGastos');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
