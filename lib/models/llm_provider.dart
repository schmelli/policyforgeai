enum LLMProvider {
  anthropic,
  openAI,
  ollama,
  // Add more providers as needed
}

class LLMConfig {
  final LLMProvider provider;
  final String? apiKey;
  final String model;
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  const LLMConfig({
    required this.provider,
    this.apiKey,
    required this.model,
    required this.baseUrl,
    this.defaultHeaders = const {},
  });

  factory LLMConfig.anthropic({
    required String apiKey,
    String model = 'claude-3-sonnet-20240229',
  }) {
    return LLMConfig(
      provider: LLMProvider.anthropic,
      apiKey: apiKey,
      model: model,
      baseUrl: 'https://api.anthropic.com/v1/messages',
      defaultHeaders: {
        'anthropic-version': '2023-06-01',
      },
    );
  }

  factory LLMConfig.openAI({
    required String apiKey,
    String model = 'gpt-3.5-turbo',
  }) {
    return LLMConfig(
      provider: LLMProvider.openAI,
      apiKey: apiKey,
      model: model,
      baseUrl: 'https://api.openai.com/v1/chat/completions',
    );
  }

  factory LLMConfig.ollama({
    String model = 'llama2',
    String baseUrl = 'http://localhost:11434/api/chat',
  }) {
    return LLMConfig(
      provider: LLMProvider.ollama,
      model: model,
      baseUrl: baseUrl,
    );
  }

  Map<String, String> getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      ...defaultHeaders,
    };

    switch (provider) {
      case LLMProvider.anthropic:
        if (apiKey != null) {
          headers['x-api-key'] = apiKey!;
        }
        break;
      case LLMProvider.openAI:
        if (apiKey != null) {
          headers['Authorization'] = 'Bearer $apiKey';
        }
        break;
      case LLMProvider.ollama:
        // Ollama doesn't need authentication headers
        break;
    }

    return headers;
  }

  /// Creates a copy of this LLMConfig with the given fields replaced
  LLMConfig copyWith({
    LLMProvider? provider,
    String? apiKey,
    String? model,
    String? baseUrl,
    Map<String, String>? defaultHeaders,
  }) {
    return LLMConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      baseUrl: baseUrl ?? this.baseUrl,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
    );
  }

  Map<String, dynamic> formatMessage(String message) {
    switch (provider) {
      case LLMProvider.anthropic:
        return {
          'model': model,
          'messages': [
            {
              'role': 'user',
              'content': message,
            }
          ],
        };
      case LLMProvider.openAI:
        return {
          'model': model,
          'messages': [
            {
              'role': 'user',
              'content': message,
            }
          ],
        };
      case LLMProvider.ollama:
        return {
          'model': model,
          'messages': [
            {
              'role': 'user',
              'content': message,
            }
          ],
        };
    }
  }

  String parseResponse(Map<String, dynamic> response) {
    switch (provider) {
      case LLMProvider.anthropic:
        return response['content'][0]['text'];
      case LLMProvider.openAI:
        return response['choices'][0]['message']['content'];
      case LLMProvider.ollama:
        return response['message']['content'];
    }
  }
}
