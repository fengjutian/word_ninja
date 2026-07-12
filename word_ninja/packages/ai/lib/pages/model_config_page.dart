import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import '../config/model_config.dart';
import '../config/config_provider.dart';
import '../services/ai_chat_service.dart';

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
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          // ─── 提供商选择 ───
          Text('模型提供商', style: NinjaTextStyles.titleMedium),
          const SizedBox(height: NinjaSpacing.sm),
          _ProviderCard(
            icon: PhosphorIconsRegular.lightning,
            title: 'DeepSeek V4 Pro',
            subtitle: 'deepseek-v4-pro · 强大 · 适合复杂任务',
            selected: config.provider == ModelProvider.deepSeek &&
                config.maxTokens >= 1000,
            onTap: () => notifier.selectProvider(ModelProvider.deepSeek),
          ),
          const SizedBox(height: NinjaSpacing.sm),
          _ProviderCard(
            icon: PhosphorIconsRegular.rocket,
            title: 'DeepSeek V4 Flash',
            subtitle: 'deepseek-v4-flash · 极速响应 · 适合简单任务',
            selected: config.provider == ModelProvider.deepSeek &&
                config.maxTokens < 1000,
            onTap: () => notifier.selectDeepSeekFlash(),
          ),
          const SizedBox(height: NinjaSpacing.sm),
          _ProviderCard(
            icon: PhosphorIconsRegular.openAiLogo,
            title: 'OpenAI',
            subtitle: 'gpt-4o-mini · 兼容性好',
            selected: config.provider == ModelProvider.openAI,
            onTap: () => notifier.selectProvider(ModelProvider.openAI),
          ),
          const SizedBox(height: NinjaSpacing.sm),
          _ProviderCard(
            icon: PhosphorIconsRegular.wrench,
            title: '自定义',
            subtitle: '手动配置 Base URL 和模型名称',
            selected: config.provider == ModelProvider.custom,
            onTap: () => notifier.selectProvider(ModelProvider.custom),
          ),

          const SizedBox(height: NinjaSpacing.xl),
          const Divider(),
          const SizedBox(height: NinjaSpacing.md),

          // ─── API Key ───
          Text('API 密钥', style: NinjaTextStyles.titleMedium),
          const SizedBox(height: NinjaSpacing.sm),
          _ApiKeyField(
            initialValue: config.apiKey,
            onSaved: (key) => notifier.updateApiKey(key),
          ),
          if (config.apiKey.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: NinjaSpacing.sm),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.checkCircle,
                      color: NinjaColors.success, size: 16),
                  const SizedBox(width: 4),
                  Text('密钥已保存 (${config.apiKey.length} 位)',
                      style: NinjaTextStyles.caption.copyWith(
                          color: NinjaColors.success)),
                ],
              ),
            ),

          const SizedBox(height: NinjaSpacing.md),
          // ─── 测试连接 ───
          _TestButton(apiKey: config.apiKey, config: config),

          const SizedBox(height: NinjaSpacing.xl),

          // ─── 高级设置 ───
          Text('高级设置', style: NinjaTextStyles.titleMedium),
          const SizedBox(height: NinjaSpacing.sm),
          _InfoRow(label: '模型', value: config.modelName),
          _InfoRow(label: 'Base URL', value: config.baseUrl),
          _InfoRow(label: 'Temperature', value: config.temperature.toString()),
          _InfoRow(label: 'Max Tokens', value: config.maxTokens.toString()),

          const SizedBox(height: NinjaSpacing.lg),
          // ─── 当前状态 ───
          Card(
            color: NinjaColors.success.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(NinjaSpacing.lg),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.checkCircle,
                      color: NinjaColors.success),
                  const SizedBox(width: NinjaSpacing.sm),
                  Expanded(
                    child: Text(
                      '已选择 ${config.provider.label} 模型',
                      style: NinjaTextStyles.bodyMedium,
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

/// 提供商选择卡片
class _ProviderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? NinjaColors.primary : NinjaColors.textSecondary;
    return Material(
      color: selected
          ? NinjaColors.primary.withValues(alpha: 0.08)
          : NinjaColors.surface,
      borderRadius: BorderRadius.circular(NinjaSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NinjaSpacing.cardRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(NinjaSpacing.cardRadius),
            border: Border.all(
              color: selected
                  ? NinjaColors.primary.withValues(alpha: 0.4)
                  : NinjaColors.divider.withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.all(NinjaSpacing.lg),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: NinjaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: NinjaTextStyles.titleMedium.copyWith(
                          color: selected
                              ? NinjaColors.primary
                              : NinjaColors.textPrimary,
                        )),
                    const SizedBox(height: NinjaSpacing.xxs),
                    Text(subtitle, style: NinjaTextStyles.caption),
                  ],
                ),
              ),
              if (selected)
                const Icon(PhosphorIconsRegular.checkCircle,
                    color: NinjaColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// API Key 输入字段 — 带保存按钮
class _ApiKeyField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onSaved;

  const _ApiKeyField({required this.initialValue, required this.onSaved});

  @override
  State<_ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends State<_ApiKeyField> {
  late TextEditingController _ctrl;
  bool _obscured = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _saved = widget.initialValue.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant _ApiKeyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _ctrl.text) {
      _ctrl.text = widget.initialValue;
      _saved = widget.initialValue.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSaved(_ctrl.text.trim());
    setState(() => _saved = _ctrl.text.trim().isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _ctrl,
            obscureText: _obscured,
            decoration: InputDecoration(
              hintText: 'sk-...',
              suffixIcon: IconButton(
                icon: Icon(_obscured
                    ? PhosphorIconsRegular.eye
                    : PhosphorIconsRegular.eyeSlash),
                onPressed: () => setState(() => _obscured = !_obscured),
              ),
            ),
            onChanged: (_) => setState(() => _saved = false),
            onFieldSubmitted: (_) => _save(),
          ),
        ),
        const SizedBox(width: NinjaSpacing.sm),
        SizedBox(
          height: 40,
          child: FilledButton.icon(
            onPressed: _save,
            icon: Icon(
              _saved ? PhosphorIconsRegular.checkCircle : PhosphorIconsRegular.floppyDisk,
              size: 18,
            ),
            label: Text(_saved ? '已保存' : '保存'),
            style: FilledButton.styleFrom(
              backgroundColor: _saved ? NinjaColors.success : NinjaColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// 信息行
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NinjaSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: NinjaTextStyles.bodyMedium),
          Text(value,
              style: NinjaTextStyles.caption.copyWith(
                color: NinjaColors.textSecondary,
              )),
        ],
      ),
    );
  }
}

/// API 连接测试按钮
class _TestButton extends StatefulWidget {
  final String apiKey;
  final ModelConfig config;

  const _TestButton({required this.apiKey, required this.config});

  @override
  State<_TestButton> createState() => _TestButtonState();
}

class _TestButtonState extends State<_TestButton> {
  bool _loading = false;
  String? _result;
  bool? _success;

  Future<void> _test() async {
    if (widget.apiKey.isEmpty) {
      setState(() {
        _success = false;
        _result = '请先保存 API 密钥再测试。';
      });
      return;
    }
    setState(() {
      _loading = true;
      _result = null;
      _success = null;
    });
    final service = AiChatService(widget.apiKey, config: widget.config);
    final (ok, msg) = await service.testConnection();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _success = ok;
      _result = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = _result != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _loading ? null : _test,
          icon: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(PhosphorIconsRegular.paperPlaneTilt, size: 18),
          label: Text(_loading ? '测试中…' : '测试连接'),
        ),
        if (hasResult)
          Padding(
            padding: const EdgeInsets.only(top: NinjaSpacing.sm),
            child: Card(
              color: (_success == true
                      ? NinjaColors.success
                      : NinjaColors.error)
                  .withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(NinjaSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      _success == true
                          ? PhosphorIconsRegular.checkCircle
                          : PhosphorIconsRegular.warningCircle,
                      color: _success == true
                          ? NinjaColors.success
                          : NinjaColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: NinjaSpacing.sm),
                    Expanded(
                      child: Text(
                        _result!,
                        style: NinjaTextStyles.caption.copyWith(
                          color: _success == true
                              ? NinjaColors.success
                              : NinjaColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
