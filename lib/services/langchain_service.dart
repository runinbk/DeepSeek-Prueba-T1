import 'package:langchain/langchain.dart';
import 'openrouter_service.dart';

class LangChainService {
  final OpenRouterService _openRouterService;
  late ConversationBufferMemory _memory;
  late ChatPromptTemplate _promptTemplate;
  late BaseChatModel _chatModel;
  late ConversationChain _chain;

  LangChainService({required String apiKey})
    : _openRouterService = OpenRouterService(apiKey: apiKey) {
    // Inicializar la memoria para la conversación
    _memory = ConversationBufferMemory(
      returnMessages: true,
      memoryKey: "history",
      inputKey: "input",
      outputKey: "output",
    );

    // Crear un modelo de chat personalizado usando OpenRouter
    _chatModel = OpenRouterChatModel(openRouterService: _openRouterService);

    // Crear una plantilla de prompt simple para la conversación
    _promptTemplate = ChatPromptTemplate.fromPromptMessages([
      SystemChatMessagePromptTemplate.fromTemplate(
        "Responde en español latinoamericano.",
      ),
      MessagesPlaceholder(variableName: "history"),
      HumanChatMessagePromptTemplate.fromTemplate("{input}"),
    ]);

    // Inicializar la cadena de conversación
    _chain = ConversationChain(
      memory: _memory,
      prompt: _promptTemplate,
      llm: _chatModel,
    );
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      // Utilizar la cadena de conversación para procesar el mensaje
      final response = await _chain.invoke({"input": userMessage});

      // Extraer la respuesta
      String llmResponse = response["output"] as String;

      return llmResponse;
    } catch (e) {
      print('Error en LangChainService: $e');
      return 'Error al procesar tu mensaje con LangChain: $e';
    }
  }

  // Método para limpiar la memoria si es necesario
  void clearMemory() {
    _memory = ConversationBufferMemory(
      returnMessages: true,
      memoryKey: "history",
      inputKey: "input",
      outputKey: "output",
    );

    // No es necesario recrear toda la cadena, solo actualizar la memoria
    _chain = ConversationChain(
      memory: _memory,
      prompt: _promptTemplate,
      llm: _chatModel,
    );
  }
}

// Clase personalizada para usar OpenRouter como un modelo de chat de LangChain
class OpenRouterChatModel extends BaseChatModel {
  final OpenRouterService openRouterService;

  OpenRouterChatModel({required this.openRouterService});

  @override
  String get modelType => "openrouter";

  @override
  Future<List<ChatResult>> generate(
    List<List<ChatMessage>> messagesList, {
    List<String>? stop,
    Map<String, dynamic>? options,
  }) async {
    List<ChatResult> results = [];

    for (final messages in messagesList) {
      // Convertir los mensajes de LangChain al formato que espera OpenRouter
      final List<Map<String, String>> previousMessages = [];
      String lastUserMessage = "";

      for (var message in messages) {
        if (message is HumanChatMessage) {
          previousMessages.add({'role': 'user', 'content': message.content});
          lastUserMessage =
              message.content; // Guardar el último mensaje del usuario
        } else if (message is AIChatMessage) {
          previousMessages.add({
            'role': 'assistant',
            'content': message.content,
          });
        } else if (message is SystemChatMessage) {
          previousMessages.add({'role': 'system', 'content': message.content});
        }
      }

      // Si no hay mensajes del sistema al principio, agregar uno
      if (previousMessages.isEmpty || previousMessages[0]['role'] != 'system') {
        previousMessages.insert(0, {
          'role': 'system',
          'content': 'Responde en español latinoamericano.',
        });
      }

      // Obtener respuesta de OpenRouter
      String aiResponse;
      if (previousMessages.length > 1) {
        // Reutilizar previousMessages sin el último mensaje del usuario
        List<Map<String, String>> contextMessages =
            previousMessages.length > 1
                ? previousMessages.sublist(0, previousMessages.length - 1)
                : [];
        aiResponse = await openRouterService.sendMessage(
          lastUserMessage,
          previousMessages: contextMessages,
        );
      } else {
        // Si solo hay un mensaje (el del usuario)
        aiResponse = await openRouterService.sendMessage(lastUserMessage);
      }

      // Crear el resultado con la generación
      final generation = ChatGeneration(
        message: AIChatMessage(content: aiResponse),
      );
      results.add(ChatResult(generations: [generation]));
    }

    return results;
  }

  @override
  Future<String> predictMessages(
    List<ChatMessage> messages, {
    List<String>? stop,
    Map<String, dynamic>? options,
  }) async {
    final result = await generate([messages], stop: stop, options: options);
    return result[0].generations[0].message.content;
  }

  @override
  Future<void> close() async {
    // No hay recursos que cerrar
  }
}
