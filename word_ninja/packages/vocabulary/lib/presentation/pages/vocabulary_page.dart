import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/cards/word_card.dart';
import 'package:ui_kit/loading/app_loading.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ui_kit/ui_kit.dart' show AppIcon;
import '../providers/word_provider.dart';
import '../../data/model/word.dart';
import 'add_word_page.dart';

part 'vocabulary_widgets.dart';

/// 单词本主页面 — 词汇学习
class VocabularyPage extends ConsumerStatefulWidget {
  const VocabularyPage({super.key});

  @override
  ConsumerState<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends ConsumerState<VocabularyPage> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _debounceTimer;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(wordListProvider.notifier).loadWords(refresh: true));
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 100) {
      ref.read(wordListProvider.notifier).loadWords();
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(wordListProvider.notifier).search(value);
    });
  }

  void _startQuiz() {
    final words = ref.read(wordListProvider).words;
    if (words.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('需要至少 2 个单词才能开始测验')),
      );
      return;
    }
    context.push('/vocabulary/test', extra: words);
  }

  void _startReview() {
    context.push('/vocabulary/review');
  }

  void _showWordDetail(Word word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _WordDetailSheet(word: word),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wordListProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '搜索单词...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white60),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _onSearchChanged,
              )
            : const Text('词汇学习'),
        actions: [
          if (state.words.isNotEmpty)
            IconButton(
              icon: const Icon(PhosphorIconsRegular.shareNetwork),
              tooltip: '单词图谱',
              onPressed: () => context.push(
                '/vocabulary/graph',
                extra: state.words,
              ),
            ),
          IconButton(
            icon: Icon(_isSearching
                ? PhosphorIconsRegular.x
                : PhosphorIconsRegular.magnifyingGlass),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchCtrl.clear();
                _debounceTimer?.cancel();
                ref.read(wordListProvider.notifier).loadWords(refresh: true);
              }
            }),
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddWordPage.showAsBottomSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(PhosphorIconsRegular.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(WordListState state) {
    if (state.isLoading && state.words.isEmpty) {
      return const AppLoading(message: '加载单词中...');
    }

    if (state.error != null && state.words.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(PhosphorIconsRegular.warningCircle,
                size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(state.error!, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () =>
                  ref.read(wordListProvider.notifier).loadWords(refresh: true),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (state.words.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(PhosphorIconsRegular.bookOpen,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text('还没有单词', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.sm),
            Text('点击 + 添加第一个单词', style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(wordListProvider.notifier).loadWords(refresh: true),
      child: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 80),
        children: [
          // ─── 学习模式入口 ───
          _buildPracticeSection(state.words.length),
          // ─── 单词列表 ───
          ..._buildWordList(state),
        ],
      ),
    );
  }

  Widget _buildPracticeSection(int totalWords) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon.practice(size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('学习模式', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _PracticeCard(
                  icon: PhosphorIconsRegular.chalkboardTeacher,
                  label: '单词测验',
                  subtitle: '选择题模式 · 巩固记忆',
                  color: AppColors.info,
                  onTap: totalWords >= 2 ? _startQuiz : null,
                  disabled: totalWords < 2,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _PracticeCard(
                  icon: PhosphorIconsRegular.cardholder,
                  label: '艾宾浩斯复习',
                  subtitle: '翻转卡片 · 科学记忆',
                  color: AppColors.success,
                  onTap: totalWords >= 1 ? _startReview : null,
                  disabled: totalWords < 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  List<Widget> _buildWordList(WordListState state) {
    final items = <Widget>[];
    // Section header
    items.add(
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          '我的词库（${state.words.length}）',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
    for (var i = 0; i < state.words.length; i++) {
      final word = state.words[i];
      items.add(WordCard(
        word: word.word,
        meaning: word.meaning,
        phonetic: word.phonetic.isNotEmpty ? '/${word.phonetic}/' : null,
        mastery: word.mastery,
        onTap: () => _showWordDetail(word),
      ));
      // Loading indicator at the end
      if (i == state.words.length - 1 && state.hasMore) {
        items.add(
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }
    }
    return items;
  }
}
