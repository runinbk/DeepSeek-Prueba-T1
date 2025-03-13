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
      theme: ThemeData(primarySwatch: Colors.blue),
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
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration.collapsed(
                hintText: 'Enviar un mensaje',
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat con OpenRouter')),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _textComposerWidget(),
          ),
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
      ChatMessage response = ChatMessage(text: responseText, isMe: false);
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
        // Ajusta según la estructura de la respuesta de la API
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
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key, required this.text, required this.isMe});

  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(child: Text(isMe ? 'Yo' : 'OR')),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isMe ? 'Yo' : 'OpenRouter',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
