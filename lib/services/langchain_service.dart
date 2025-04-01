import 'package:langchain/langchain.dart';
import 'openrouter_service.dart';

class LangChainService {
  final OpenRouterService _openRouterService;
  late ConversationChain _chain;
  late ConversationBufferMemory _memory;

  LangChainService({required String apiKey})
    : _openRouterService = OpenRouterService(apiKey: apiKey) {
    // Inicializar la memoria para la conversación
    _memory = ConversationBufferMemory(
      returnMessages: true,
      memoryKey: "history",
      inputKey: "input",
      outputKey: "output",
    );

    // Crear un LLM personalizado para usar con OpenRouter
    final customLLM = CustomLLM(openRouterService: _openRouterService);

    // Inicializar la cadena de conversación
    _chain = ConversationChain(memory: _memory, llm: customLLM);
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

    // Recrear la cadena con la nueva memoria
    final customLLM = CustomLLM(openRouterService: _openRouterService);
    _chain = ConversationChain(memory: _memory, llm: customLLM);
  }
}

// Clase personalizada para usar OpenRouter como un LLM de LangChain
class CustomLLM implements LLM {
  final OpenRouterService openRouterService;

  CustomLLM({required this.openRouterService});

  @override
  Future<String> invoke(String prompt, {Map<String, dynamic>? options}) async {
    return await openRouterService.sendMessage(prompt);
  }

  @override
  Future<LLMResult> generate(
    List<String> prompts, {
    Map<String, dynamic>? options,
  }) async {
    List<Generation> generations = [];

    for (final prompt in prompts) {
      final response = await openRouterService.sendMessage(prompt);
      generations.add(Generation(text: response));
    }

    return LLMResult(generations: [generations]);
  }

  @override
  Future<void> close() async {
    // No hay recursos que cerrar
  }
}
