import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/llm_provider.dart';

class AIService {
  final LLMConfig config;
  final double temperature;
  final int maxTokens;

  AIService({
    required this.config,
    required this.temperature,
    required this.maxTokens,
  });

  /// Generate a response from the configured LLM
  Future<String> generateResponse({required String message}) async {
    final requestBody = config.formatMessage(message);

    // Add common parameters
    requestBody['temperature'] = temperature;
    if (config.provider != LLMProvider.anthropic) {
      requestBody['max_tokens'] = maxTokens;
    }

    final response = await http.post(
      Uri.parse(config.baseUrl),
      headers: config.getHeaders(),
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return config.parseResponse(data);
    } else {
      final error = jsonDecode(response.body);
      String errorMessage;

      switch (config.provider) {
        case LLMProvider.anthropic:
          errorMessage = error['error']['message'] ?? response.body;
          break;
        case LLMProvider.openAI:
          errorMessage = error['error']['message'] ?? response.body;
          break;
        case LLMProvider.ollama:
          errorMessage = error['error'] ?? response.body;
          break;
      }

      throw Exception('Failed to generate response: $errorMessage');
    }
  }
}
