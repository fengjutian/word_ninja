part of 'model_config_page.dart';

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.colors,
      required this.title,
      required this.subtitle,
      required this.child,
      this.trailing});
  final AppColorTokens colors;
  final String title, subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: colors.sidebar,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: colors.mutedText)),
                ])),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 20),
          child,
        ]),
      );
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.selected,
      required this.onTap});
  final IconData icon;
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.55)
          : colors.sidebar,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                  color: selected
                      ? scheme.primary.withValues(alpha: 0.55)
                      : colors.border)),
          child: Row(children: [
            Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: selected
                        ? scheme.primary.withValues(alpha: 0.12)
                        : colors.subtleSurface,
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(icon,
                    color: selected ? scheme.primary : colors.mutedText,
                    size: 19)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(fontSize: 11, color: colors.mutedText)),
                ])),
            Icon(
                selected
                    ? PhosphorIconsFill.checkCircle
                    : PhosphorIconsRegular.circle,
                color: selected ? scheme.primary : colors.border,
                size: 18),
          ]),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(
      {required this.label, required this.active, required this.colors});
  final String label;
  final bool active;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final color = active ? colors.success : colors.warning;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color))
        ]));
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.hint});
  final String label;
  final String? hint;
  @override
  Widget build(BuildContext context) => Row(children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        if (hint != null) ...[
          const Spacer(),
          Text(hint!,
              style:
                  TextStyle(fontSize: 11, color: context.appColors.mutedText))
        ]
      ]);
}

class _ApiKeyField extends StatefulWidget {
  const _ApiKeyField({required this.initialValue, required this.onSaved});
  final String initialValue;
  final ValueChanged<String> onSaved;
  @override
  State<_ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends State<_ApiKeyField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);
  bool _obscured = true;
  bool _dirty = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSaved(_controller.text.trim());
    setState(() => _dirty = false);
  }

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: TextField(
                controller: _controller,
                obscureText: _obscured,
                onChanged: (_) => setState(() => _dirty = true),
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                    hintText: 'sk-••••••••••••',
                    prefixIcon: const Icon(PhosphorIconsRegular.key, size: 18),
                    suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscured = !_obscured),
                        icon: Icon(
                            _obscured
                                ? PhosphorIconsRegular.eye
                                : PhosphorIconsRegular.eyeSlash,
                            size: 18))))),
        const SizedBox(width: 10),
        FilledButton.icon(
            onPressed: _dirty || widget.initialValue.isEmpty ? _save : null,
            icon: const Icon(PhosphorIconsRegular.floppyDisk, size: 17),
            label: Text(_dirty ? '保存' : '已保存')),
      ]);
}

class _EndpointFields extends StatefulWidget {
  const _EndpointFields(
      {super.key, required this.config, required this.onSaved});
  final ModelConfig config;
  final void Function({required String modelName, required String baseUrl})
      onSaved;
  @override
  State<_EndpointFields> createState() => _EndpointFieldsState();
}

class _EndpointFieldsState extends State<_EndpointFields> {
  late final _model = TextEditingController(text: widget.config.modelName);
  late final _url = TextEditingController(text: widget.config.baseUrl);
  @override
  void dispose() {
    _model.dispose();
    _url.dispose();
    super.dispose();
  }

  void _save() => widget.onSaved(modelName: _model.text, baseUrl: _url.text);

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _FieldLabel(label: '服务端点'),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              flex: 2,
              child: TextField(
                  controller: _url,
                  onSubmitted: (_) => _save(),
                  decoration: const InputDecoration(
                      labelText: 'Base URL',
                      prefixIcon: Icon(PhosphorIconsRegular.link, size: 18)))),
          const SizedBox(width: 10),
          Expanded(
              child: TextField(
                  controller: _model,
                  onSubmitted: (_) => _save(),
                  decoration: const InputDecoration(labelText: '模型名称'))),
          const SizedBox(width: 10),
          IconButton(
              onPressed: _save,
              tooltip: '保存端点',
              icon: const Icon(PhosphorIconsRegular.check)),
        ]),
      ]);
}

class _AdvancedSettings extends StatefulWidget {
  const _AdvancedSettings(
      {required this.config, required this.colors, required this.onChanged});
  final ModelConfig config;
  final AppColorTokens colors;
  final void Function({required double temperature, required int maxTokens})
      onChanged;
  @override
  State<_AdvancedSettings> createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<_AdvancedSettings> {
  bool _expanded = false;
  late double _temperature = widget.config.temperature;
  late double _tokens = widget.config.maxTokens.toDouble();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: widget.colors.subtleSurface,
            borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          ListTile(
              dense: true,
              onTap: () => setState(() => _expanded = !_expanded),
              leading: const Icon(PhosphorIconsRegular.sliders, size: 18),
              title: const Text('生成参数',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text(
                  'Temperature ${_temperature.toStringAsFixed(1)} · ${_tokens.round()} tokens',
                  style:
                      TextStyle(fontSize: 11, color: widget.colors.mutedText)),
              trailing: Icon(
                  _expanded
                      ? PhosphorIconsRegular.caretUp
                      : PhosphorIconsRegular.caretDown,
                  size: 16)),
          if (_expanded)
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(children: [
                  Row(children: [
                    const SizedBox(
                        width: 95,
                        child: Text('创造性', style: TextStyle(fontSize: 12))),
                    Expanded(
                        child: Slider(
                            value: _temperature,
                            min: 0,
                            max: 2,
                            divisions: 20,
                            label: _temperature.toStringAsFixed(1),
                            onChanged: (value) =>
                                setState(() => _temperature = value),
                            onChangeEnd: (_) => _save()))
                  ]),
                  Row(children: [
                    const SizedBox(
                        width: 95,
                        child: Text('最大长度', style: TextStyle(fontSize: 12))),
                    Expanded(
                        child: Slider(
                            value: _tokens.clamp(512, 8192).toDouble(),
                            min: 512,
                            max: 8192,
                            divisions: 15,
                            label: '${_tokens.round()}',
                            onChanged: (value) =>
                                setState(() => _tokens = value),
                            onChangeEnd: (_) => _save()))
                  ]),
                ])),
        ]),
      );

  void _save() =>
      widget.onChanged(temperature: _temperature, maxTokens: _tokens.round());
}

class _TestButton extends StatefulWidget {
  const _TestButton({required this.apiKey, required this.config});
  final String apiKey;
  final ModelConfig config;
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
        _result = '请先保存 API 密钥';
      });
      return;
    }
    setState(() {
      _loading = true;
      _result = null;
    });
    final (ok, message) =
        await AiChatService(widget.apiKey, config: widget.config)
            .testConnection();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _success = ok;
      _result = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _success == true
        ? context.appColors.success
        : Theme.of(context).colorScheme.error;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(
            child: Text('保存配置后测试服务是否可用',
                style: TextStyle(
                    fontSize: 12, color: context.appColors.mutedText))),
        OutlinedButton.icon(
            onPressed: _loading ? null : _test,
            icon: _loading
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(PhosphorIconsRegular.paperPlaneTilt, size: 17),
            label: Text(_loading ? '测试中…' : '测试连接'))
      ]),
      if (_result != null)
        Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9)),
                child: Row(children: [
                  Icon(
                      _success == true
                          ? PhosphorIconsRegular.checkCircle
                          : PhosphorIconsRegular.warningCircle,
                      size: 17,
                      color: color),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_result!,
                          style: TextStyle(fontSize: 12, color: color)))
                ]))),
    ]);
  }
}
