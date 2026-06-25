import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:auth/presentation/providers/auth_provider.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

/// 忘记密码页面
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _sent = false;
  String? _error;

  static final _emailRegExp = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.forgotPassword(_emailCtrl.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('找回密码')),
      body: Padding(
        padding: const EdgeInsets.all(NinjaSpacing.xl),
        child: _sent ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),
          const Icon(PhosphorIcons.regular.lockKey, size: 64, color: NinjaColors.primary),
          const SizedBox(height: 24),
          const Text(
            '输入注册邮箱，我们将发送重置链接',
            style: NinjaTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(NinjaSpacing.md),
              margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
              decoration: BoxDecoration(
                color: NinjaColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
              ),
              child: Text(_error!, style: const TextStyle(color: NinjaColors.error)),
            ),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: '邮箱',
              prefixIcon: Icon(PhosphorIcons.regular.envelope),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return '请输入邮箱';
              if (!_emailRegExp.hasMatch(v.trim())) return '请输入有效的邮箱地址';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('发送重置链接'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),
        const Icon(PhosphorIcons.regular.checkCircle, size: 64, color: NinjaColors.success),
        const SizedBox(height: 24),
        const Text(
          '重置链接已发送',
          style: NinjaTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '请检查 ${_emailCtrl.text} 的收件箱',
          style: NinjaTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => context.pop(),
          child: const Text('返回登录'),
        ),
      ],
    );
  }
}
