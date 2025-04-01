import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'services/langchain_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat con LangChain',
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
                child: Text('LC', style: TextStyle(color: Colors.white)),
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

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  late LangChainService _langChainService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
    _initTextToSpeech();
    _initLangChain();
  }

  // Inicializa LangChain con tu API key
  void _initLangChain() {
    const apiKey =
        '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'; // Reemplaza con tu API key si es diferente
    _langChainService = LangChainService(apiKey: apiKey);
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
          _isLoading
              ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2E8B57),
                ),
              )
              : IconButton(
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
        title: const Text('Chat con LangChain'),
        backgroundColor: const Color(0xFF2E8B57),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _langChainService.clearMemory();
              setState(() {
                _messages.clear();
              });
            },
          ),
        ],
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
    if (text.trim().isEmpty) return;

    _textController.clear();
    ChatMessage message = ChatMessage(text: text, isMe: true);
    setState(() {
      _messages.insert(0, message);
      _isLoading = true;
    });

    try {
      // Usar LangChain para procesar el mensaje
      final responseText = await _langChainService.sendMessage(text);
      ChatMessage response = ChatMessage(text: responseText, isMe: false);
      setState(() {
        _messages.insert(0, response);
        _isLoading = false;
      });
      _speak(responseText);
    } catch (e) {
      print('Error al obtener la respuesta: $e');
      ChatMessage errorResponse = ChatMessage(
        text: 'Error al obtener la respuesta del LLM.',
        isMe: false,
      );
      setState(() {
        _messages.insert(0, errorResponse);
        _isLoading = false;
      });
    }
  }
}
