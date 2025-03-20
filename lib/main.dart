import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

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
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
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
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
    _initTextToSpeech();
  }

  // Inicializa el reconocimiento de voz
  void _initSpeechToText() async {
    await _speech.initialize();
    setState(() {});
  }

  // Inicializa el texto a voz
  void _initTextToSpeech() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.8);
  }

  // Escucha la voz del usuario y la convierte en texto
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _textController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // Convierte texto a voz
  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Widget _textComposerWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
            onPressed: _listen,
            color: const Color(0xFF2E8B57),
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF2E8B57)),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat con OpenRouter'),
        backgroundColor: const Color(0xFF2E8B57),
      ),
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
      final respuestaLimpia = _limpiarRespuesta(responseText);
      ChatMessage response = ChatMessage(text: respuestaLimpia, isMe: false);
      setState(() {
        _messages.insert(0, response);
      });
      _speak(respuestaLimpia);
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
    final apiKey = 'tu_clave_de_api_aqui';
    final apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://tusitio.com',
          'X-Title': 'Tu App',
        },
        body: jsonEncode({
          'model': 'deepseek/deepseek-r1-zero:free',
          'messages': [
            {'role': 'user', 'content': message},
            {
              'role': 'system',
              'content': 'Responde en español latinoamericano.',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final responseText =
            decodedResponse['choices'][0]['message']['content'];
        return responseText;
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
  String _limpiarRespuesta(String respuesta) {
    return respuesta
        .replaceAll(r'\boxed', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll(r'\n', '\n')
        .trim();
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
                backgroundColor: Color(0xFF2E8B57),
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
                            : const Color(0xFF2E8B57),
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
                backgroundColor: Color(0xFFFF7F50),
                child: Text('Yo', style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
