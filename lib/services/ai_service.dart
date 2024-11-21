import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat.dart';

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String _apiKey;
  final String _model;
  final double _temperature;
  final int _maxTokens;

  AIService({
    required String apiKey,
    String model = 'gpt-3.5-turbo',
    double temperature = 0.7,
    int maxTokens = 1000,
  })  : _apiKey = apiKey,
        _model = model,
        _temperature = temperature,
        _maxTokens = maxTokens;

  Future<String> generateResponse({
    required List<ChatMessage> messages,
    String? documentContext,
  }) async {
    final List<Map<String, String>> formattedMessages = [];

    // Add system message with document context if available
    if (documentContext != null && documentContext.isNotEmpty) {
      formattedMessages.add({
        'role': 'system',
        'content': '''You are an AI assistant helping with document management and policy creation.
Here is the current document content for context:

$documentContext

Please provide relevant assistance based on this document content.''',
      });
    } else {
      formattedMessages.add({
        'role': 'system',
        'content': 'You are an AI assistant helping with document management and policy creation.',
      });
    }

    // Add conversation history
    formattedMessages.addAll(
      messages.map((msg) => {
        'role': msg.role == MessageRole.user ? 'user' : 'assistant',
        'content': msg.content,
      }),
    );

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': formattedMessages,
        'temperature': _temperature,
        'max_tokens': _maxTokens,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to generate AI response: ${response.body}');
    }
  }
}
