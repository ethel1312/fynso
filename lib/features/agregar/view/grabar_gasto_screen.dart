import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fynso/data/services/notification_service.dart';

import 'package:fynso/common/themes/app_color.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_title.dart';
import '../../../common/widgets/fynso_card_dialog.dart';

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
  bool isStopping = false; // evita taps múltiples al detener / cancelar / límite
  bool _isStarting = false; // evita taps múltiples al iniciar la grabación

  // Animación del botón
  late AnimationController _controller;
  late Animation<double> _animation;

  // Audio
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _audioPath;
  bool _recorderOpened = false; // control explícito del estado del recorder

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

    // Mostrar un pequeño tutorial solo la primera vez que se entra a esta pantalla
    _maybeShowRecordTutorial();
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
    final mm = _recordElapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = _recordElapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _maybeShowRecordTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('record_tutorial_seen') ?? false;
    if (seen || !mounted) return;

    await prefs.setBool('record_tutorial_seen', true);
    if (!mounted) return;

    await showFynsoCardDialog<void>(
      context,
      title: 'Graba y sigue con tu día',
      message:
      'Presiona el botón, describe tu gasto con tu voz y luego puedes usar otras apps o bloquear tu celular (sin cerrar Fynso por completo). Tu gasto se procesará en segundo plano.',
      icon: Icons.mic_none_outlined,
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
          child: const Text('Entendido'),
        ),
      ],
    );
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
    if (!_recorderOpened) {
      await _recorder.openRecorder();
      _recorderOpened = true;
    }
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

          if (!mounted) return;

          setState(() {
            _recordElapsed = dur;
            _lastDb = db;
            if (db != null && db > -45) {
              _voiceDetected = true; // ~habla normal cerca del micro
            }
          });

          if (_recordElapsed.inSeconds >= _maxSeconds && !isStopping) {
            _onMaxDurationReached();
          }
        } catch (_) {}
      });

      await _recorder.startRecorder(toFile: _audioPath, codec: Codec.aacMP4);

      if (!mounted) return;

      setState(() {
        isRecording = true;
        _controller.repeat(reverse: true);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Grabación iniciada')));
    } catch (e) {
      if (mounted) {
        setState(() {
          isRecording = false;
          _controller.stop();
        });
      }
      await _showFynsoError('Error al iniciar grabación: $e');
    }
  }

  Future<void> _cancelRecording() async {
    if (!isRecording || isUploading || isStopping) return;

    isStopping = true;
    try {
      try {
        await _recorder.stopRecorder();
      } catch (_) {}

      _recSub?.cancel();
      _recSub = null;

      if (_audioPath != null) {
        final f = File(_audioPath!);
        try {
          if (await f.exists()) {
            await f.delete();
          }
        } catch (_) {}
      }

      _audioPath = null;
      _recordElapsed = Duration.zero;
      _lastDb = null;
      _voiceDetected = false;

      if (!mounted) return;

      setState(() {
        isRecording = false;
        _controller.stop();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Grabación cancelada')));
    } catch (e) {
      await _showFynsoError('No se pudo cancelar: $e');
    } finally {
      await _safeStopAndClose();
      isStopping = false;
    }
  }

  Future<void> _stopRecordingAndUpload() async {
    // ya se controla reentrancia con isStopping en el botón y en _onMaxDurationReached
    isStopping = true;

    try {
      // 1) Detener
      try {
        await _recorder.stopRecorder();
      } catch (_) {}

      if (mounted) {
        setState(() {
          isRecording = false;
          _controller.stop();
        });
      }

      // 2) Revisar archivo
      if (_audioPath == null || !File(_audioPath!).existsSync()) {
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
        if (!mounted) return;
        final choice = await showFynsoCardDialog<String>(
          context,
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
          try {
            if (await f.exists()) await f.delete();
          } catch (_) {}

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
      if (mounted) {
        setState(() => isUploading = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrando tu gasto...'),
          ),
        );
      }

      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');
      if (jwt == null || jwt.isEmpty) {
        // Notificación local para cuando esté en background
        await NotificationService.show(
          title: 'No se pudo registrar tu gasto',
          body: 'No se encontró token de usuario. Vuelve a iniciar sesión.',
        );

        await _showFynsoError('No se encontró token de usuario');
        return;
      }

      await _viewModel.enviarAudio(File(_audioPath!), jwt);

      if (_viewModel.error != null) {
        await NotificationService.show(
          title: 'No se pudo registrar tu gasto',
          body: _viewModel.error!,
        );

        await _showFynsoError(_viewModel.error!);
        return;
      }

      // 4) Navegar al detalle con datos REALES
      final r = _viewModel.transcribeResult;
      if (r != null) {
        final txId = r.createdTransactionId ?? r.transaction?.idTransaction;
        if (txId != null) {
          // ✅ Notificación para el caso en que el usuario se haya ido al home / bloqueado pantalla
          await NotificationService.show(
            title: 'Gasto registrado',
            body: 'Tu gasto ya está disponible en el historial.',
          );

          if (!mounted) return;
          final req = TransactionDetailRequest(jwt: jwt, idTransaction: txId);
          await Navigator.pushNamed(
            context,
            '/detalleGasto',
            arguments: req,
          );
        } else {
          await NotificationService.show(
            title: 'No se pudo registrar tu gasto',
            body: 'No se obtuvo el ID de la transacción.',
          );

          await _showFynsoError('No se obtuvo el ID de la transacción');
        }
      } else {
        await NotificationService.show(
          title: 'No se pudo procesar el audio',
          body: 'No se pudo extraer información del audio.',
        );

        await _showFynsoError('No se pudo extraer información del audio');
      }
    } catch (e) {
      await NotificationService.show(
        title: 'No se pudo registrar tu gasto',
        body: 'Ocurrió un error inesperado. Intenta de nuevo.',
      );

      await _showFynsoError(e.toString());
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }

      // Limpiar estado de audio
      try {
        if (_audioPath != null) {
          final f = File(_audioPath!);
          if (await f.exists()) await f.delete();
        }
      } catch (_) {}
      _audioPath = null;
      _recordElapsed = Duration.zero;
      _lastDb = null;
      _voiceDetected = false;

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
    if (_recorderOpened) {
      try {
        await _recorder.closeRecorder();
      } catch (_) {}
      _recorderOpened = false;
    }
  }

  // ----------------- UI Actions -----------------

  Future<void> _onMicButtonPressed() async {
    // Bloquea mientras se está subiendo, deteniendo o iniciando
    if (isUploading || isStopping || _isStarting) return;

    if (!isRecording) {
      _isStarting = true;
      try {
        await _startRecording();
      } finally {
        _isStarting = false;
      }
    } else {
      await _stopRecordingAndUpload();
    }
  }

  Future<void> _onMaxDurationReached() async {
    if (!isRecording || isStopping) return;
    isStopping = true;
    try {
      // 1) Detener
      try {
        await _recorder.stopRecorder();
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        isRecording = false;
        _controller.stop();
      });

      if (!mounted) return;

      final choice = await showFynsoCardDialog<String>(
        context,
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
          try {
            if (await f.exists()) {
              await f.delete();
            }
          } catch (_) {}
        }
        _audioPath = null;
        _recordElapsed = Duration.zero;
        _lastDb = null;
        _voiceDetected = false;

        // cerrar recorder y limpiar subs para dejar todo listo para regrabar
        await _safeStopAndClose();

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
  Future<void> _showFynsoError(String raw) async {
    if (!mounted) return;
    final msg = raw.startsWith('Exception: ')
        ? raw.substring('Exception: '.length).trim()
        : raw.trim();
    await showFynsoCardDialog<void>(
      context,
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
                scale:
                isRecording ? _animation : const AlwaysStoppedAnimation(1),
                child: GestureDetector(
                  onTap: _onMicButtonPressed,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color:
                      isRecording ? Colors.redAccent : AppColor.azulFynso,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isRecording
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
                    onPressed: isUploading || isStopping ? null : _cancelRecording,
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
                onPressed: isRecording || isUploading || isStopping
                    ? null
                    : () async {
                  await Navigator.pushNamed(
                      context, '/historialMovimientos');
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Mientras procesamos tu audio, puedes usar otras apps o bloquear tu celular (sin cerrar Fynso).',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.45),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
