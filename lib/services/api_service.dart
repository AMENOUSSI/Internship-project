import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.68:8000';
  static const Map<String, String> headers = {
    "Content-Type": "application/json"
  };

  /// Envoie un message textuel au serveur
  static Future<String> sendMessage(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: headers,
        body: jsonEncode({"message": text}),
      );
      return _processResponse(response);
    } on SocketException catch (_) {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Envoie un fichier audio au serveur
  static Future<String> sendAudio(File audioFile) async {
    if (!await audioFile.exists()) {
      throw Exception('Audio file does not exist.');
    }

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/voice'));
    request.files
        .add(await http.MultipartFile.fromPath('audio', audioFile.path));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        return responseBody; // L'URL ou réponse du fichier audio
      } else {
        throw Exception('Failed to send audio: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception('Failed to send audio: $e');
    }
  }

  static String _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        // Vérifiez que la structure de la réponse contient le format attendu
        if (responseData is Map<String, dynamic> &&
            responseData['response'] is Map<String, dynamic> &&
            responseData['response']['response'] is String) {
          return responseData['response']
              ['response']; // Récupère la réponse imbriquée
        } else {
          throw Exception('Invalid response format.');
        }
      } catch (e) {
        throw Exception('Failed to parse response: $e');
      }
    } else {
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }
}
