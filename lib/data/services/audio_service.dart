import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/transcribe_response.dart';

class AudioService {
  final String baseUrl = 'https://fynso.pythonanywhere.com';

  Future<TranscribeResponse> enviarAudio(File audioFile, String jwt) async {
    final uri = Uri.parse('$baseUrl/api/transcribe_and_extract');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'JWT $jwt'
      ..files.add(
        await http.MultipartFile.fromPath('audio', audioFile.path),
      );

    final streamed = await request.send();
    final body = await http.Response.fromStream(streamed);

    if (body.statusCode != 200) {
      throw Exception('Error al enviar audio: ${body.statusCode} ${body.body}');
    }

    final decoded = jsonDecode(body.body) as Map<String, dynamic>;
    if ((decoded['code'] ?? 0) != 1) {
      throw Exception(decoded['message'] ?? 'Error al procesar audio');
    }

    return TranscribeResponse.fromApi(decoded);
  }
}
