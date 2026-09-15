import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import '../config/model_config.dart';
import '../config/config_provider.dart';
import '../services/ai_chat_service.dart';

part 'model_config_widgets.dart';

/// 大模型配置页面
class ModelConfigPage extends ConsumerWidget {
  const ModelConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(modelConfigProvider);
    final notifier = ref.read(modelConfigProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('大模型配置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ─── 提供商选择 ───
          Text('模型提供商', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _ProviderCard(
            icon: PhosphorIconsRegular.lightning,
            title: 'DeepSeek V4 Pro',
            subtitle: 'deepseek-v4-pro · 强大 · 适合复杂任务',
            selected: config.provider == ModelProvider.deepSeek &&
                config.maxTokens >= 1000,
            onTap: () => notifier.selectProvider(ModelProvider.deepSeek),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ProviderCard(
            icon: PhosphorIconsRegular.rocket,
            title: 'DeepSeek V4 Flash',
            subtitle: 'deepseek-v4-flash · 极速响应 · 适合简单任务',
            selected: config.provider == ModelProvider.deepSeek &&
                config.maxTokens < 1000,
            onTap: () => notifier.selectDeepSeekFlash(),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ProviderCard(
            icon: PhosphorIconsRegular.openAiLogo,
            title: 'OpenAI',
            subtitle: 'gpt-4o-mini · 兼容性好',
            selected: config.provider == ModelProvider.openAI,
            onTap: () => notifier.selectProvider(ModelProvider.openAI),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ProviderCard(
            icon: PhosphorIconsRegular.wrench,
            title: '自定义',
            subtitle: '手动配置 Base URL 和模型名称',
            selected: config.provider == ModelProvider.custom,
            onTap: () => notifier.selectProvider(ModelProvider.custom),
          ),

          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // ─── API Key ───
          Text('API 密钥', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _ApiKeyField(
            initialValue: config.apiKey,
            onSaved: (key) => notifier.updateApiKey(key),
          ),
          if (config.apiKey.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.checkCircle,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 4),
                  Text('密钥已保存 (${config.apiKey.length} 位)',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.success)),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.md),
          // ─── 测试连接 ───
          _TestButton(apiKey: config.apiKey, config: config),

          const SizedBox(height: AppSpacing.xl),

          // ─── 高级设置 ───
          Text('高级设置', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: '模型', value: config.modelName),
          _InfoRow(label: 'Base URL', value: config.baseUrl),
          _InfoRow(label: 'Temperature', value: config.temperature.toString()),
          _InfoRow(label: 'Max Tokens', value: config.maxTokens.toString()),

          const SizedBox(height: AppSpacing.lg),
          // ─── 当前状态 ───
          Card(
            color: AppColors.success.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.checkCircle,
                      color: AppColors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '已选择 ${config.provider.label} 模型',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
