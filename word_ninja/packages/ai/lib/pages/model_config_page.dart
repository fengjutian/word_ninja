import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui_kit/app_theme/design_tokens.dart';

import '../config/config_provider.dart';
import '../config/model_config.dart';
import '../services/ai_chat_service.dart';

part 'model_config_widgets.dart';

class ModelConfigPage extends ConsumerWidget {
  const ModelConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(modelConfigProvider);
    final notifier = ref.read(modelConfigProvider.notifier);
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PageHeader(colors: colors),
                  const SizedBox(height: 28),
                  LayoutBuilder(builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    final providers = _ProviderPanel(
                      config: config,
                      notifier: notifier,
                      colors: colors,
                    );
                    final settings = _SettingsPanel(
                      config: config,
                      notifier: notifier,
                      colors: colors,
                      scheme: scheme,
                    );
                    if (!wide) {
                      return Column(children: [
                        providers,
                        const SizedBox(height: 20),
                        settings,
                      ]);
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 360, child: providers),
                        const SizedBox(width: 20),
                        Expanded(child: settings),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.colors});
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(PhosphorIconsRegular.cpu,
              size: 21, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('模型与服务', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 3),
          Text('配置用于 AI 导师、阅读和写作功能的模型服务',
              style: TextStyle(fontSize: 13, color: colors.mutedText)),
        ]),
      ]);
}

class _ProviderPanel extends StatelessWidget {
  const _ProviderPanel({
    required this.config,
    required this.notifier,
    required this.colors,
  });
  final ModelConfig config;
  final ModelConfigNotifier notifier;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) => _SectionCard(
        colors: colors,
        title: '模型服务',
        subtitle: '选择预设或使用兼容 OpenAI 的服务',
        child: Column(children: [
          _ProviderCard(
            icon: PhosphorIconsRegular.lightning,
            title: 'DeepSeek V4 Pro',
            subtitle: '复杂任务与深度分析',
            selected: config.provider == ModelProvider.deepSeek &&
                config.modelName == ModelConfig.deepSeekV4Pro.modelName,
            onTap: () => notifier.selectProvider(ModelProvider.deepSeek),
          ),
          const SizedBox(height: 10),
          _ProviderCard(
            icon: PhosphorIconsRegular.rocket,
            title: 'DeepSeek V4 Flash',
            subtitle: '快速响应与日常对话',
            selected: config.provider == ModelProvider.deepSeek &&
                config.modelName == ModelConfig.deepSeekV4Flash.modelName,
            onTap: notifier.selectDeepSeekFlash,
          ),
          const SizedBox(height: 10),
          _ProviderCard(
            icon: PhosphorIconsRegular.openAiLogo,
            title: 'OpenAI',
            subtitle: '兼容性与工具调用',
            selected: config.provider == ModelProvider.openAI,
            onTap: () => notifier.selectProvider(ModelProvider.openAI),
          ),
          const SizedBox(height: 10),
          _ProviderCard(
            icon: PhosphorIconsRegular.sparkle,
            title: 'MiniMax M2.7',
            subtitle: '中国大陆节点 · OpenAI 兼容',
            selected: config.provider == ModelProvider.miniMax,
            onTap: () => notifier.selectProvider(ModelProvider.miniMax),
          ),
          const SizedBox(height: 10),
          _ProviderCard(
            icon: PhosphorIconsRegular.slidersHorizontal,
            title: '自定义服务',
            subtitle: '配置模型名称与服务地址',
            selected: config.provider == ModelProvider.custom,
            onTap: () => notifier.selectProvider(ModelProvider.custom),
          ),
        ]),
      );
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.config,
    required this.notifier,
    required this.colors,
    required this.scheme,
  });
  final ModelConfig config;
  final ModelConfigNotifier notifier;
  final AppColorTokens colors;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) => _SectionCard(
        colors: colors,
        title: '当前配置',
        subtitle: '${config.provider.label} · ${config.modelName}',
        trailing: _StatusBadge(
          label: config.apiKey.isEmpty ? '等待配置' : '已配置',
          active: config.apiKey.isNotEmpty,
          colors: colors,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _FieldLabel(label: 'API 密钥', hint: '仅保存在本机'),
          const SizedBox(height: 8),
          _ApiKeyField(
            initialValue: config.apiKey,
            onSaved: notifier.updateApiKey,
          ),
          const SizedBox(height: 20),
          _EndpointFields(
            key: ValueKey('${config.provider.name}:${config.modelName}'),
            config: config,
            onSaved: ({required baseUrl, required modelName}) =>
                notifier.updateEndpoint(
              modelName: modelName,
              baseUrl: baseUrl,
            ),
          ),
          const SizedBox(height: 20),
          _AdvancedSettings(
            config: config,
            colors: colors,
            onChanged: ({required maxTokens, required temperature}) =>
                notifier.updateGeneration(
              temperature: temperature,
              maxTokens: maxTokens,
            ),
          ),
          const SizedBox(height: 22),
          Divider(color: colors.border),
          const SizedBox(height: 18),
          _TestButton(apiKey: config.apiKey, config: config),
        ]),
      );
}
