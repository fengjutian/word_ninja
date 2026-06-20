import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/lib/ninja_theme/ninja_theme.dart';
import '../../data/model/word.dart';
import '../providers/word_provider.dart';

/// 添加单词页
class AddWordPage extends ConsumerStatefulWidget {
  const AddWordPage({super.key});

  @override
  ConsumerState<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends ConsumerState<AddWordPage> {
  final _formKey = GlobalKey<FormState>();
  final _wordCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();
  final _phoneticCtrl = TextEditingController();
  final _exampleCtrl = TextEditingController();

  @override
  void dispose() {
    _wordCtrl.dispose();
    _meaningCtrl.dispose();
    _phoneticCtrl.dispose();
    _exampleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加单词'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('保存',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _wordCtrl,
                decoration: const InputDecoration(
                  labelText: '单词',
                  hintText: '输入英文单词',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '请输入单词' : null,
              ),
              const SizedBox(height: NinjaSpacing.md),
              TextFormField(
                controller: _meaningCtrl,
                decoration: const InputDecoration(
                  labelText: '释义',
                  hintText: '输入中文释义',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '请输入释义' : null,
              ),
              const SizedBox(height: NinjaSpacing.md),
              TextFormField(
                controller: _phoneticCtrl,
                decoration: const InputDecoration(
                  labelText: '音标（可选）',
                  hintText: '如 ˈbjuːtəfəl',
                ),
              ),
              const SizedBox(height: NinjaSpacing.md),
              TextFormField(
                controller: _exampleCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '例句（可选）',
                  hintText: '输入包含该单词的例句',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: NinjaSpacing.xl),
              // AI 补全按钮
              OutlinedButton.icon(
                onPressed: _aiAutoComplete,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('AI 智能补全'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final word = Word(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: '',
      word: _wordCtrl.text.trim(),
      meaning: _meaningCtrl.text.trim(),
      phonetic: _phoneticCtrl.text.trim(),
      example: _exampleCtrl.text.trim(),
    );
    // 通过 Provider 保存
    ref.read(wordListProvider.notifier).addWord(word);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('单词已添加')),
    );
    Navigator.pop(context);
  }

  void _aiAutoComplete() {
    final word = _wordCtrl.text.trim();
    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入单词')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI 补全中...')),
    );
    // TODO 调用 AiWordService.completeWord
  }
}
