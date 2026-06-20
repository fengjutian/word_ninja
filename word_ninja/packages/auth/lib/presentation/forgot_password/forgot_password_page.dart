import 'package:flutter/material.dart';
import 'package:ui_kit/lib/ninja_theme/ninja_theme.dart';

/// 忘记密码页面
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sent = true);
    // TODO 调用后端重置密码 API
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
          const Icon(Icons.lock_reset, size: 64, color: NinjaColors.primary),
          const SizedBox(height: 24),
          const Text(
            '输入注册邮箱，我们将发送重置链接',
            style: NinjaTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: '邮箱',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return '请输入邮箱';
              if (!v.contains('@')) return '邮箱格式不正确';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('发送重置链接'),
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
        const Icon(Icons.check_circle, size: 64, color: NinjaColors.success),
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
          onPressed: () => Navigator.pop(context),
          child: const Text('返回登录'),
        ),
      ],
    );
  }
}
