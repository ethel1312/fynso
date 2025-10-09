import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/transcribe_response.dart';

class AudioService {
  final String baseUrl = 'https://fynso.pythonanywhere.com';

  Future<TranscribeResponse> enviarAudio(File audioFile, String jwt) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/transcribe_and_extract'),
    );

    request.headers['Authorization'] = 'Bearer $jwt';
    request.files.add(
      await http.MultipartFile.fromPath('audio', audioFile.path),
    );

    var response = await request.send();
    var body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return TranscribeResponse.fromJson(jsonDecode(body));
    } else {
      throw Exception('Error al enviar audio: ${response.statusCode}');
    }
  }
}
