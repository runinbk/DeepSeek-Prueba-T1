import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterService {
  final String apiKey;
  final String modelName;
  final String systemPrompt;

  OpenRouterService({
    required this.apiKey,
    this.modelName = 'deepseek/deepseek-r1-zero:free',
    this.systemPrompt = 'Responde en español latinoamericano.',
  });

  Future<String> sendMessage(
    String message, {
    List<Map<String, String>>? previousMessages,
  }) async {
    final apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

    try {
      // Construir historial de mensajes si existe
      final List<Map<String, String>> messages = [];

      // Añadir mensaje de sistema al inicio
      messages.add({'role': 'system', 'content': systemPrompt});

      // Añadir mensajes previos si existen
      if (previousMessages != null && previousMessages.isNotEmpty) {
        messages.addAll(previousMessages);
      }

      // Añadir mensaje actual del usuario
      messages.add({'role': 'user', 'content': message});

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://tusitio.com',
          'X-Title': 'Tu App',
        },
        body: jsonEncode({'model': modelName, 'messages': messages}),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final responseText =
            decodedResponse['choices'][0]['message']['content'];
        return limpiarRespuesta(responseText);
      } else {
        final errorResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage =
            errorResponse['error']['message'] ?? 'Error desconocido';
        print('Error en la llamada al API: ${response.statusCode}');
        print('Respuesta del servidor: ${response.body}');
        return 'Error: $errorMessage';
      }
    } catch (e) {
      print('Error de red: $e');
      return 'Error de red al comunicarse con el LLM.';
    }
  }

  // Limpia el texto de caracteres especiales
  String limpiarRespuesta(String respuesta) {
    return respuesta
        .replaceAll(r'\boxed', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll(r'\n', '\n')
        .trim();
  }
}
