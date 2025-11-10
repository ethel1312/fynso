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

  // ======= Guard rails de grabación =======
  static const int _maxSeconds = 30; // límite de grabación
  Duration _recordElapsed = Duration.zero;
  StreamSubscription? _recSub; // progreso del recorder
  double? _lastDb; // decibeles (si el plugin los emite)
  bool _voiceDetected = false; // heurística de voz/ruido

  @override
  void initState() {
    super.initState();

    _viewModel = GrabarGastoViewModel(AudioRepository(AudioService()));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..stop();

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _recSub?.cancel();
    _recSub = null;
    _safeStopAndClose();
    _controller.dispose();
    super.dispose();
  }

  // ----------------- Helpers -----------------

  String _fmtElapsed() {
    final mm = _recordElapsed.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final ss = _recordElapsed.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$mm:$ss';
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

      // reset
      _recordElapsed = Duration.zero;
      _lastDb = null;
      _voiceDetected = false;

      // progreso/decibeles
      await _recorder.setSubscriptionDuration(
        const Duration(milliseconds: 200),
      );
      _recSub?.cancel();
      _recSub = _recorder.onProgress?.listen((event) {
        try {
          final dur = (event.duration as Duration?) ?? Duration.zero;
          final db = (event.decibels as double?);

          setState(() {
            _recordElapsed = dur;
            _lastDb = db;
            if (db != null && db > -45)
              _voiceDetected = true; // ~habla normal cerca del micro
          });

          if (_recordElapsed.inSeconds >= _maxSeconds && !isStopping) {
            _onMaxDurationReached();
          }
        } catch (_) {}
      });

      await _recorder.startRecorder(toFile: _audioPath, codec: Codec.aacMP4);

      setState(() {
        isRecording = true;
        _controller.repeat(reverse: true);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Grabación iniciada')));
    } catch (e) {
      setState(() {
        isRecording = false;
        _controller.stop();
      });
      if (!mounted) return;
      await _showFynsoError('Error al iniciar grabación: $e');
    }
  }

  Future<void> _cancelRecording() async {
    if (!isRecording || isUploading) return;
    try {
      try {
        await _recorder.stopRecorder();
      } catch (_) {}
      _recSub?.cancel();
      _recSub = null;
      if (_audioPath != null) {
        final f = File(_audioPath!);
        if (await f.exists()) await f.delete();
      }
      setState(() {
        isRecording = false;
        _controller.stop();
        _audioPath = null;
        _recordElapsed = Duration.zero;
        _lastDb = null;
        _voiceDetected = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Grabación cancelada')));
    } catch (e) {
      if (!mounted) return;
      await _showFynsoError('No se pudo cancelar: $e');
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
      } catch (_) {}

      setState(() {
        isRecording = false;
        _controller.stop();
      });

      // 2) Revisar archivo
      if (_audioPath == null || !File(_audioPath!).existsSync()) {
        if (!mounted) return;
        await _showFynsoError('No se generó archivo de audio');
        return;
      }

      // 2b) Heurísticas de "audio vacío"
      final f = File(_audioPath!);
      final len = await f.length();
      final tooSmall = len < 2500; // header o casi vacío
      final tooShort = _recordElapsed.inMilliseconds < 700;
      final likelySilent = !_voiceDetected;

      if (tooSmall || tooShort || likelySilent) {
        final choice = await _showFynsoCardDialog<String>(
          title: 'No detectamos audio claro',
          message:
              'Parece que el micrófono no capturó voz o el volumen fue muy bajo. '
              '¿Quieres regrabar o enviar de todos modos?',
          icon: Icons.mic_off_outlined,
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColor.azulFynso),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: () => Navigator.pop(context, 'regrabar'),
              child: const Text('Regrabar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.azulFynso,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: () => Navigator.pop(context, 'enviar'),
              child: const Text('Enviar igual'),
            ),
          ],
        );

        if (choice != 'enviar') {
          if (await f.exists()) await f.delete();
          _audioPath = null;
          _recordElapsed = Duration.zero;
          _lastDb = null;
          _voiceDetected = false;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Listo para regrabar')),
            );
          }
          return;
        }
      }

      // 3) Subir
      setState(() => isUploading = true);

      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');
      if (jwt == null || jwt.isEmpty) {
        if (!mounted) return;
        await _showFynsoError('No se encontró token de usuario');
        return;
      }

      await _viewModel.enviarAudio(File(_audioPath!), jwt);

      if (_viewModel.error != null) {
        await _showFynsoError(_viewModel.error!);
        return;
      }

      // 4) Navegar al detalle con datos REALES
      final r = _viewModel.transcribeResult;
      if (r != null) {
        final txId = r.createdTransactionId ?? r.transaction?.idTransaction;
        if (txId != null) {
          final req = TransactionDetailRequest(jwt: jwt, idTransaction: txId);
          await Navigator.pushNamed(context, '/detalleGasto', arguments: req);
        } else {
          await _showFynsoError('No se obtuvo el ID de la transacción');
        }
      } else {
        await _showFynsoError('No se pudo extraer información del audio');
      }
    } catch (e) {
      if (mounted) {
        await _showFynsoError(e.toString());
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
    _recSub?.cancel();
    _recSub = null;
    try {
      await _recorder.closeRecorder();
    } catch (_) {}
  }

  // ----------------- UI Actions -----------------

  Future<void> _onMicButtonPressed() async {
    if (isUploading) return;
    if (!isRecording) {
      await _startRecording();
    } else {
      await _stopRecordingAndUpload();
    }
  }

  Future<void> _onMaxDurationReached() async {
    if (!isRecording || isStopping) return;
    isStopping = true;
    try {
      try {
        await _recorder.stopRecorder();
      } catch (_) {}
      setState(() {
        isRecording = false;
        _controller.stop();
      });

      final choice = await _showFynsoCardDialog<String>(
        title: 'Límite de 30 segundos',
        message:
            'Llegaste al máximo permitido. ¿Deseas enviar este audio o prefieres regrabarlo?',
        icon: Icons.timer_outlined,
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColor.azulFynso),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: () => Navigator.pop(context, 'regrabar'),
            child: const Text('Regrabar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.azulFynso,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: () => Navigator.pop(context, 'enviar'),
            child: const Text('Enviar'),
          ),
        ],
      );

      if (choice == 'enviar') {
        await _stopRecordingAndUpload();
      } else {
        // limpiar archivo y estado
        if (_audioPath != null) {
          final f = File(_audioPath!);
          if (await f.exists()) {
            await f.delete();
          }
        }
        _audioPath = null;
        _recordElapsed = Duration.zero;
        _lastDb = null;
        _voiceDetected = false;
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Listo para regrabar')));
        }
      }
    } finally {
      isStopping = false;
    }
  }

  // =================== Fynso Dialogs (bonitos) ===================
  Future<T?> _showFynsoCardDialog<T>({
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
    required List<Widget> actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColor.azulFynso.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: AppColor.azulFynso.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColor.azulFynso.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: AppColor.azulFynso),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: actions
                      .map(
                        (w) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: w,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFynsoError(String raw) async {
    final msg = raw.startsWith('Exception: ')
        ? raw.substring('Exception: '.length).trim()
        : raw.trim();
    await _showFynsoCardDialog<void>(
      title: 'No se pudo registrar el gasto',
      message: msg.isEmpty ? 'Ocurrió un error inesperado.' : msg,
      icon: Icons.error_outline,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.azulFynso,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size.fromHeight(44),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }

  // ----------------- Build -----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomTextTitle('Grabar gasto'),
        elevation: 0,
        automaticallyImplyLeading: false,
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
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Botón mic con animación solo cuando graba
              ScaleTransition(
                scale: isRecording
                    ? _animation
                    : const AlwaysStoppedAnimation(1),
                child: GestureDetector(
                  onTap: _onMicButtonPressed,
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
                    child: Center(
                      child: isUploading
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
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

              // Timer con padding animado: más separación cuando está grabando
              if (isRecording)
                AnimatedPadding(
                  padding: const EdgeInsets.only(top: 36),
                  // ajusta 36→40/48 si quieres más aire
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  child: Text(
                    '${_fmtElapsed()} / 00:30',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                const SizedBox(height: 24),

              // Estado
              const SizedBox(height: 8),
              Text(
                isUploading
                    ? 'Procesando...'
                    : (isRecording ? 'Grabando...' : 'Listo para grabar'),
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
                onPressed: isRecording || isUploading
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
