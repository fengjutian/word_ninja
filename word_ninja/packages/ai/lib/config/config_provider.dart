import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'model_config.dart';

/// 模型配置存储 Key
const _kModelConfigKey = 'ai_model_config';

/// 模型配置 Provider — 可持久化
final modelConfigProvider =
    StateNotifierProvider<ModelConfigNotifier, ModelConfig>((ref) {
  return ModelConfigNotifier();
});

class ModelConfigNotifier extends StateNotifier<ModelConfig> {
  ModelConfigNotifier() : super(ModelConfig.deepSeekV4Pro) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kModelConfigKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        final oldModel = json['modelName'] as String?;
        // 迁移旧模型名到新版本 — 保留用户已保存的 API Key
        if (oldModel == 'deepseek-chat') {
          final oldApiKey = json['apiKey'] as String? ?? '';
          final migrated = ModelConfig.deepSeekV4Pro.copyWith(apiKey: oldApiKey);
          state = migrated;
          await prefs.setString(_kModelConfigKey, jsonEncode(migrated.toJson()));
          return;
        }
        state = ModelConfig.fromJson(json);
      }
    } catch (_) {
      // 使用默认配置
    }
  }

  Future<void> updateConfig(ModelConfig config) async {
    state = config;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kModelConfigKey, jsonEncode(config.toJson()));
    } catch (_) {
      // 持久化失败不影响运行
    }
  }

  Future<void> updateApiKey(String apiKey) async {
    await updateConfig(state.copyWith(apiKey: apiKey));
  }

  Future<void> selectProvider(ModelProvider provider) async {
    switch (provider) {
      case ModelProvider.deepSeek:
        await updateConfig(ModelConfig.deepSeekV4Pro.copyWith(
          apiKey: state.apiKey,
        ));
      case ModelProvider.openAI:
        await updateConfig(ModelConfig.openAI.copyWith(
          apiKey: state.apiKey,
        ));
      case ModelProvider.custom:
        // 保留当前自定义值
        await updateConfig(state.copyWith(provider: ModelProvider.custom));
    }
  }

  /// 切换到 DeepSeek V4 Flash
  Future<void> selectDeepSeekFlash() async {
    await updateConfig(ModelConfig.deepSeekV4Flash.copyWith(
      apiKey: state.apiKey,
    ));
  }
}
