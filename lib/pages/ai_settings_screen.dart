import 'package:flutter/material.dart';
import '../models/llm_provider.dart';
import '../models/settings.dart';

class AISettingsScreen extends StatefulWidget {
  final AISettings settings;
  final Function(AISettings) onSettingsChanged;

  const AISettingsScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  late LLMProvider _selectedProvider;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  late TextEditingController _baseUrlController;
  late double _temperature;
  late int _maxTokens;
  late bool _streamResponses;

  @override
  void initState() {
    super.initState();
    _selectedProvider = widget.settings.llmConfig.provider;
    _apiKeyController =
        TextEditingController(text: widget.settings.llmConfig.apiKey);
    _modelController =
        TextEditingController(text: widget.settings.llmConfig.model);
    _baseUrlController =
        TextEditingController(text: widget.settings.llmConfig.baseUrl);
    _temperature = widget.settings.temperature;
    _maxTokens = widget.settings.maxTokens;
    _streamResponses = widget.settings.streamResponses;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  void _updateSettings() {
    LLMConfig config;
    switch (_selectedProvider) {
      case LLMProvider.anthropic:
        config = LLMConfig.anthropic(
          apiKey: _apiKeyController.text,
          model: _modelController.text,
        );
        break;
      case LLMProvider.openAI:
        config = LLMConfig.openAI(
          apiKey: _apiKeyController.text,
          model: _modelController.text,
        );
        break;
      case LLMProvider.ollama:
        config = LLMConfig.ollama(
          model: _modelController.text,
          baseUrl: _baseUrlController.text,
        );
        break;
    }

    final settings = AISettings(
      llmConfig: config,
      temperature: _temperature,
      maxTokens: _maxTokens,
      streamResponses: _streamResponses,
    );

    widget.onSettingsChanged(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LLM Provider',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<LLMProvider>(
                    value: _selectedProvider,
                    decoration: const InputDecoration(
                      labelText: 'Provider',
                      border: OutlineInputBorder(),
                    ),
                    items: LLMProvider.values.map((provider) {
                      return DropdownMenuItem(
                        value: provider,
                        child: Text(provider.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedProvider = value;
                          // Reset fields when provider changes
                          _apiKeyController.clear();
                          _modelController.clear();
                          switch (value) {
                            case LLMProvider.anthropic:
                              _modelController.text =
                                  'claude-3-sonnet-20240229';
                              break;
                            case LLMProvider.openAI:
                              _modelController.text = 'gpt-3.5-turbo';
                              break;
                            case LLMProvider.ollama:
                              _modelController.text = 'llama2';
                              _baseUrlController.text =
                                  'http://localhost:11434/api/chat';
                              break;
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedProvider != LLMProvider.ollama)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Authentication',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API Key',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Model Configuration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: 'Model Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_selectedProvider == LLMProvider.ollama) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _baseUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Base URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text('Temperature'),
                  Slider(
                    value: _temperature,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: _temperature.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        _temperature = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _maxTokens.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Max Tokens',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final tokens = int.tryParse(value);
                      if (tokens != null) {
                        setState(() {
                          _maxTokens = tokens;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _updateSettings();
              Navigator.pop(context);
            },
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
