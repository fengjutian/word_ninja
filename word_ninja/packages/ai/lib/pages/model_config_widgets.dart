part of 'model_config_page.dart';

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
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.08)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.divider.withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        )),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (selected)
                const Icon(PhosphorIconsRegular.checkCircle,
                    color: AppColors.primary, size: 20),
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
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          height: 40,
          child: FilledButton.icon(
            onPressed: _save,
            icon: Icon(
              _saved
                  ? PhosphorIconsRegular.checkCircle
                  : PhosphorIconsRegular.floppyDisk,
              size: 18,
            ),
            label: Text(_saved ? '已保存' : '保存'),
            style: FilledButton.styleFrom(
              backgroundColor: _saved ? AppColors.success : AppColors.primary,
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
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
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Card(
              color: (_success == true ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      _success == true
                          ? PhosphorIconsRegular.checkCircle
                          : PhosphorIconsRegular.warningCircle,
                      color: _success == true
                          ? AppColors.success
                          : AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _result!,
                        style: AppTextStyles.caption.copyWith(
                          color: _success == true
                              ? AppColors.success
                              : AppColors.error,
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
