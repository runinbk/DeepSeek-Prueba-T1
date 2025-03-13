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
      title: 'Chat con LLM',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: text,
      isMe: true,
    );
    setState(() {
      _messages.insert(0, message);
    });
    // Aquí iría la llamada al API
    _simulateApiResponse(text);
  }

  void _simulateApiResponse(String text) {
    // Simulación de respuesta del API
    Future.delayed(Duration(milliseconds: 500), () {
      ChatMessage response = ChatMessage(
        text: 'Respuesta del LLM a: $text',
        isMe: false,
      );
      setState(() {
        _messages.insert(0, response);
      });
    });
  }

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
      appBar: AppBar(
        title: Text('Chat con DeepSeek'),
      ),
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
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _textComposerWidget(),
          ),
        ],
      ),
    );
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
            child: CircleAvatar(
              child: Text(isMe ? 'Yo' : 'DpS'),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(isMe ? 'Yo' : 'LLM', style: Theme.of(context).textTheme.titleMedium),
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

Future<String> _callLLMAPI(String message) async {
  final apiKey = 'TU_CLAVE_DE_API'; // Reemplaza con tu clave de API real
  final apiUrl = 'URL_DEL_API_DEL_LLM'; // Reemplaza con la URL del API del LLM

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey', // Si la API requiere autenticación
      },
      body: jsonEncode({
        'prompt': message, // O el nombre del campo que la API espera para el mensaje
      }),
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      final responseText = decodedResponse['choices'][0]['text']; // Ajusta según la estructura de la respuesta
      return responseText;
    } else {
      print('Error en la llamada al API: ${response.statusCode}');
      return 'Error al obtener la respuesta del LLM.';
    }
  } catch (e) {
    print('Error de red: $e');
    return 'Error de red al comunicarse con el LLM.';
  }
}