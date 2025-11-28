import 'dart:convert';
import 'dart:io';
import 'package:fynso/common/config.dart' as app_config;
import 'package:http/http.dart' as http;
import 'package:background_downloader/background_downloader.dart';
import '../models/transcribe_response.dart';

class AudioService {
  final String baseUrl = app_config.Config.baseUrl;

  Future<TranscribeResponse> enviarAudio(File audioFile, String jwt) async {
    final url = '$baseUrl/api/transcribe_and_extract';

    // Extraemos baseDirectory, directory y filename a partir de la ruta real
    final (baseDirectory, directory, filename) =
    await Task.split(filePath: audioFile.path);

    // Definimos la tarea de subida multi-part
    final task = UploadTask(
      url: url,
      baseDirectory: baseDirectory,
      directory: directory,
      filename: filename,
      fileField: 'audio', // 👈 tu backend espera "audio" en request.files.get("audio")
      headers: {
        'Authorization': 'JWT $jwt',
      },
      // Si quieres progreso para debug, puedes cambiar a statusAndProgress
      updates: Updates.status,
    );

    // Lanzamos el upload y esperamos el resultado (aunque la app se vaya a background)
    final result = await FileDownloader().upload(task);

    if (result.status != TaskStatus.complete) {
      // Aquí puedes loguear más info si quieres
      throw Exception(
        'Error al enviar audio: '
            '${result.responseStatusCode ?? ''} '
            '${result.exception?.toString() ?? ''}',
      );
    }

    final body = result.responseBody;
    if (body == null) {
      throw Exception('Respuesta vacía del servidor');
    }

    final decoded = jsonDecode(body) as Map<String, dynamic>;
    if ((decoded['code'] ?? 0) != 1) {
      throw Exception(decoded['message'] ?? 'Error al procesar audio');
    }

    return TranscribeResponse.fromApi(decoded);
  }
}
