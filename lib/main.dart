import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat con OpenRouter',
      theme: ThemeData(
        primarySwatch: Colors.orange, // Color primario
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), // Fondo beige claro
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Color(0xFF654321),
          ), // Texto marrón oscuro
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(
            0xFF2E8B57,
          ), // Color secundario (verde tropical)
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFD700), // Botones amarillo dorado
        ),
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  Widget _textComposerWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: Color(0xFF2E8B57),
            ), // Icono verde tropical
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat con OpenRouter')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          _textComposerWidget(),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    ChatMessage message = ChatMessage(text: text, isMe: true);
    setState(() {
      _messages.insert(0, message);
    });

    try {
      final responseText = await _callOpenRouterAPI(text);
      final respuestaLimpia = _limpiarRespuesta(
        responseText,
      ); // Limpia la respuesta
      ChatMessage response = ChatMessage(text: respuestaLimpia, isMe: false);
      setState(() {
        _messages.insert(0, response);
      });
    } catch (e) {
      print('Error al obtener la respuesta: $e');
      ChatMessage errorResponse = ChatMessage(
        text: 'Error al obtener la respuesta del LLM.',
        isMe: false,
      );
      setState(() {
        _messages.insert(0, errorResponse);
      });
    }
  }

  Future<String> _callOpenRouterAPI(String message) async {
    final apiKey =
        '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'; // Reemplaza con tu clave de API de OpenRouter
    final apiUrl =
        'https://openrouter.ai/api/v1/chat/completions'; // URL de OpenRouter

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://tusitio.com', // Opcional: URL de tu sitio
          'X-Title': 'Tu App', // Opcional: Nombre de tu app
        },
        body: jsonEncode({
          'model': 'deepseek/deepseek-r1-zero:free', // Modelo de OpenRouter
          'messages': [
            {
              'role': 'user',
              'content': message,
            }, // Estructura esperada por la API
          ],
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        // Extrae el contenido de la respuesta
        final responseText =
            decodedResponse['choices'][0]['message']['content'];
        return responseText;
      } else {
        final errorResponse = json.decode(response.body);
        final errorMessage =
            errorResponse['error']['message'] ?? 'Error desconocido';
        print('Error en la llamada al API: ${response.statusCode}');
        print('Respuesta del servidor: ${response.body}');
        return 'Error: $errorMessage'; // Muestra el mensaje de error específico
      }
    } catch (e) {
      print('Error de red: $e');
      return 'Error de red al comunicarse con el LLM.';
    }
  }

  String _limpiarRespuesta(String respuesta) {
    // Elimina caracteres especiales como \boxed, {, }, etc.
    return respuesta
        .replaceAll(r'\boxed', '') // Elimina \boxed
        .replaceAll('{', '') // Elimina {
        .replaceAll('}', '') // Elimina }
        .replaceAll(r'\n', '\n') // Reemplaza saltos de línea
        .trim(); // Elimina espacios en blanco al inicio y final
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key, required this.text, required this.isMe});

  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!isMe)
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: const CircleAvatar(
                backgroundColor: Color(0xFF2E8B57), // Verde tropical
                child: Text('OR', style: TextStyle(color: Colors.white)),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color:
                        isMe
                            ? const Color(0xFFFF7F50)
                            : const Color(
                              0xFF2E8B57,
                            ), // Naranja coral o verde tropical
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (isMe)
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: const CircleAvatar(
                backgroundColor: Color(0xFFFF7F50), // Naranja coral
                child: Text('Yo', style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
