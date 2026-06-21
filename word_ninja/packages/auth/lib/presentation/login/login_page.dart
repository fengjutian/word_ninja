import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import '../providers/auth_provider.dart';

/// 登录页面
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  static final _emailRegExp = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(NinjaSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: NinjaColors.primary,
                    ),
                    child: const Center(
                      child: Text('忍', style: TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      )),
                    ),
                  ),
                  const SizedBox(height: NinjaSpacing.lg),
                  Text('Word Ninja', style: NinjaTextStyles.displayMedium),
                  const SizedBox(height: NinjaSpacing.xs),
                  Text('登录继续你的忍者修炼',
                      style: NinjaTextStyles.bodyMedium),
                  const SizedBox(height: NinjaSpacing.xxl),

                  // 错误提示
                  if (state.error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(NinjaSpacing.md),
                      margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
                      decoration: BoxDecoration(
                        color: NinjaColors.error.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(NinjaSpacing.buttonRadius),
                      ),
                      child: Text(state.error!,
                          style: const TextStyle(color: NinjaColors.error)),
                    ),

                  // 邮箱
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '邮箱',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '请输入邮箱';
                      if (!_emailRegExp.hasMatch(v.trim())) return '请输入有效的邮箱地址';
                      return null;
                    },
                  ),
                  const SizedBox(height: NinjaSpacing.lg),

                  // 密码
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: '密码',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return '请输入密码';
                      if (v.length < 8) return '密码至少8位';
                      return null;
                    },
                  ),
                  const SizedBox(height: NinjaSpacing.xl),

                  // 登录按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.status == AuthStatus.loading ? null : _submit,
                      child: state.status == AuthStatus.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('登 录'),
                    ),
                  ),
                  const SizedBox(height: NinjaSpacing.lg),

                  // 辅助链接
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: const Text('忘记密码？'),
                      ),
                    ],
                  ),
                  // 注册入口
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('还没有账号？立即注册'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
