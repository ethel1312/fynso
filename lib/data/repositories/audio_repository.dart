import 'dart:io';
import '../services/audio_service.dart';
import '../models/transcribe_response.dart';

class AudioRepository {
  final AudioService service;

  AudioRepository(this.service);

  Future<TranscribeResponse> transcribirAudio(File audioFile, String jwt) {
    return service.enviarAudio(audioFile, jwt);
  }
}
