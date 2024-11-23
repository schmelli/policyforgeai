import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String apiKey;
  final String model;
  final double temperature;
  final int maxTokens;

  AIService({
    required this.apiKey,
    required this.model,
    required this.temperature,
    required this.maxTokens,
  });

  /// Generate a response from the AI model
  Future<String> generateResponse({required String message}) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': message,
          }
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to generate response: ${response.body}');
    }
  }
}
