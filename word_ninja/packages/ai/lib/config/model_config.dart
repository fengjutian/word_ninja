/// AI 模型提供商枚举
enum ModelProvider {
  openAI,
  deepSeek,
  custom;

  String get label {
    switch (this) {
      case ModelProvider.openAI:
        return 'OpenAI';
      case ModelProvider.deepSeek:
        return 'DeepSeek';
      case ModelProvider.custom:
        return '自定义';
    }
  }
}

/// AI 模型配置
class ModelConfig {
  final ModelProvider provider;
  final String modelName;
  final String baseUrl;
  final String apiKey;
  final double temperature;
  final int maxTokens;

  const ModelConfig({
    this.provider = ModelProvider.deepSeek,
    this.modelName = 'deepseek-chat',
    this.baseUrl = 'https://api.deepseek.com/v1',
    this.apiKey = '',
    this.temperature = 0.7,
    this.maxTokens = 1000,
  });

  /// DeepSeek V4 Pro 默认配置
  static const deepSeekV4Pro = ModelConfig(
    provider: ModelProvider.deepSeek,
    modelName: 'deepseek-chat',
    baseUrl: 'https://api.deepseek.com/v1',
    temperature: 0.7,
    maxTokens: 2000,
  );

  /// DeepSeek V4 Flash 默认配置 — 更快响应，适合简单任务
  static const deepSeekV4Flash = ModelConfig(
    provider: ModelProvider.deepSeek,
    modelName: 'deepseek-chat',
    baseUrl: 'https://api.deepseek.com/v1',
    temperature: 0.5,
    maxTokens: 512,
  );

  /// OpenAI 默认配置
  static const openAI = ModelConfig(
    provider: ModelProvider.openAI,
    modelName: 'gpt-4o-mini',
    baseUrl: 'https://api.openai.com/v1',
    temperature: 0.7,
    maxTokens: 1000,
  );

  ModelConfig copyWith({
    ModelProvider? provider,
    String? modelName,
    String? baseUrl,
    String? apiKey,
    double? temperature,
    int? maxTokens,
  }) =>
      ModelConfig(
        provider: provider ?? this.provider,
        modelName: modelName ?? this.modelName,
        baseUrl: baseUrl ?? this.baseUrl,
        apiKey: apiKey ?? this.apiKey,
        temperature: temperature ?? this.temperature,
        maxTokens: maxTokens ?? this.maxTokens,
      );

  Map<String, dynamic> toJson() => {
        'provider': provider.name,
        'modelName': modelName,
        'baseUrl': baseUrl,
        'temperature': temperature,
        'maxTokens': maxTokens,
      };

  factory ModelConfig.fromJson(Map<String, dynamic> json) => ModelConfig(
        provider: ModelProvider.values.firstWhere(
          (e) => e.name == json['provider'],
          orElse: () => ModelProvider.deepSeek,
        ),
        modelName: json['modelName'] as String? ?? 'deepseek-chat',
        baseUrl: json['baseUrl'] as String? ?? 'https://api.deepseek.com/v1',
        apiKey: json['apiKey'] as String? ?? '',
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
        maxTokens: json['maxTokens'] as int? ?? 2000,
      );
}
