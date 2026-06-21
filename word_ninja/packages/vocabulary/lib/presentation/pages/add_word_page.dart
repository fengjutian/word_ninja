import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai/providers/ai_providers.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
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
  bool _isAiLoading = false;
  bool _isSaving = false;

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
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('保存',
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
                onPressed: _isAiLoading ? null : _aiAutoComplete,
                icon: _isAiLoading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                label: Text(_isAiLoading ? 'AI 补全中...' : 'AI 智能补全'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final word = Word(
        id: '', // 由后端生成
        userId: '',
        word: _wordCtrl.text.trim(),
        meaning: _meaningCtrl.text.trim(),
        phonetic: _phoneticCtrl.text.trim(),
        example: _exampleCtrl.text.trim(),
      );
      await ref.read(wordListProvider.notifier).addWord(word);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('单词已添加')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _aiAutoComplete() async {
    final word = _wordCtrl.text.trim();
    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入单词')),
      );
      return;
    }
    setState(() => _isAiLoading = true);
    try {
      final service = ref.read(aiWordServiceProvider);
      final result = await service.completeWord(word);
      if (!mounted) return;
      setState(() {
        final meaning = result['meaning'] as String?;
        final phonetic = result['phonetic'] as String?;
        final example = result['example'] as String?;
        if (_meaningCtrl.text.trim().isEmpty && meaning != null && meaning.isNotEmpty) {
          _meaningCtrl.text = meaning;
        }
        if (_phoneticCtrl.text.trim().isEmpty && phonetic != null && phonetic.isNotEmpty) {
          _phoneticCtrl.text = phonetic;
        }
        if (_exampleCtrl.text.trim().isEmpty && example != null && example.isNotEmpty) {
          _exampleCtrl.text = example;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI 补全完成'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI 补全失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAiLoading = false);
    }
  }
}
