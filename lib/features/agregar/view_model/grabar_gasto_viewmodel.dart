import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fynso/data/models/transcribe_response.dart';
import 'package:fynso/data/repositories/audio_repository.dart';

class GrabarGastoViewModel extends ChangeNotifier {
  final AudioRepository repository;
  bool isLoading = false;
  TranscribeResponse? transcribeResult;
  String? error;

  GrabarGastoViewModel(this.repository);

  Future<void> enviarAudio(File audioFile, String jwt) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      transcribeResult = await repository.transcribirAudio(audioFile, jwt);
    } catch (e) {
      error = e.toString();
      transcribeResult = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
