import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/cards/word_card.dart';
import 'package:ui_kit/loading/ninja_loading.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ui_kit/ui_kit.dart' show NinjaIcon;
import '../providers/word_provider.dart';
import '../../data/model/word.dart';
import 'add_word_page.dart';

/// 单词本主页面 — 单词修炼
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
    Future.microtask(() =>
        ref.read(wordListProvider.notifier).loadWords(refresh: true));
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
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 100) {
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
            : const Text('单词修炼'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? PhosphorIconsRegular.x : PhosphorIconsRegular.magnifyingGlass),
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
        backgroundColor: NinjaColors.primary,
        child: const Icon(PhosphorIconsRegular.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(WordListState state) {
    if (state.isLoading && state.words.isEmpty) {
      return const NinjaLoading(message: '加载单词中...');
    }

    if (state.error != null && state.words.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(PhosphorIconsRegular.warningCircle, size: 48, color: NinjaColors.error),
            const SizedBox(height: NinjaSpacing.md),
            Text(state.error!, style: NinjaTextStyles.bodyMedium),
            const SizedBox(height: NinjaSpacing.lg),
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
            const Icon(PhosphorIconsRegular.bookOpen, size: 64, color: NinjaColors.textSecondary),
            const SizedBox(height: NinjaSpacing.md),
            Text('还没有单词', style: NinjaTextStyles.heading3),
            const SizedBox(height: NinjaSpacing.sm),
            Text('点击 + 添加第一个单词',
                style: NinjaTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(wordListProvider.notifier).loadWords(refresh: true),
      child: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.only(top: NinjaSpacing.sm, bottom: 80),
        children: [
          // ─── 修炼模式入口 ───
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
        NinjaSpacing.lg,
        NinjaSpacing.md,
        NinjaSpacing.lg,
        NinjaSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NinjaIcon.sword(size: 20, color: NinjaColors.primary),
              const SizedBox(width: NinjaSpacing.sm),
              Text('修炼模式', style: NinjaTextStyles.heading3),
            ],
          ),
          const SizedBox(height: NinjaSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _PracticeCard(
                  icon: PhosphorIconsRegular.chalkboardTeacher,
                  label: '单词测验',
                  subtitle: '选择题模式 · 巩固记忆',
                  color: NinjaColors.info,
                  onTap: totalWords >= 2 ? _startQuiz : null,
                  disabled: totalWords < 2,
                ),
              ),
              const SizedBox(width: NinjaSpacing.sm),
              Expanded(
                child: _PracticeCard(
                  icon: PhosphorIconsRegular.cardholder,
                  label: '艾宾浩斯复习',
                  subtitle: '翻转卡片 · 科学记忆',
                  color: NinjaColors.success,
                  onTap: totalWords >= 1 ? _startReview : null,
                  disabled: totalWords < 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: NinjaSpacing.sm),
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
          horizontal: NinjaSpacing.lg,
          vertical: NinjaSpacing.xs,
        ),
        child: Text(
          '我的词库（${state.words.length}）',
          style: NinjaTextStyles.caption.copyWith(
            color: NinjaColors.textSecondary,
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

/// 修炼模式卡片
class _PracticeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool disabled;

  const _PracticeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(NinjaSpacing.cardRadius),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(NinjaSpacing.cardRadius),
          child: Container(
            padding: const EdgeInsets.all(NinjaSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NinjaSpacing.cardRadius),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(NinjaSpacing.sm),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: NinjaSpacing.sm),
                Text(label, style: NinjaTextStyles.titleMedium),
                const SizedBox(height: NinjaSpacing.xxs),
                Text(subtitle,
                  style: NinjaTextStyles.caption.copyWith(
                    color: NinjaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 单词详情弹层
class _WordDetailSheet extends ConsumerWidget {
  final Word word;
  _WordDetailSheet({required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.3,
      expand: false,
      builder: (ctx, scrollCtrl) => SingleChildScrollView(
        controller: scrollCtrl,
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: NinjaColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: NinjaSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(NinjaSpacing.xl),
                child: Column(
                  children: [
                    Text(word.word as String, style: NinjaTextStyles.displayMedium),
                    if ((word.phonetic as String).isNotEmpty) ...[
                      const SizedBox(height: NinjaSpacing.sm),
                      Text('/${word.phonetic}/', style: NinjaTextStyles.bodyLarge),
                    ],
                    const SizedBox(height: NinjaSpacing.md),
                    Text(word.meaning as String,
                        style: NinjaTextStyles.heading3.copyWith(color: NinjaColors.primary)),
                    const SizedBox(height: NinjaSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_buildMasteryBadge(word.mastery as int)],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: NinjaSpacing.lg),
            if ((word.example as String).isNotEmpty) ...[
              const Text('例句', style: NinjaTextStyles.heading3),
              const SizedBox(height: NinjaSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(NinjaSpacing.lg),
                  child: Text(word.example as String, style: NinjaTextStyles.bodyLarge),
                ),
              ),
              const SizedBox(height: NinjaSpacing.lg),
            ],
            if ((word.tags as List).isNotEmpty) ...[
              const Text('标签', style: NinjaTextStyles.heading3),
              const SizedBox(height: NinjaSpacing.sm),
              Wrap(
                spacing: NinjaSpacing.sm,
                children: (word.tags as List)
                    .map((tag) => Chip(label: Text(tag.toString()), backgroundColor: NinjaColors.primary.withValues(alpha: 0.1)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMasteryBadge(int mastery) {
    final (color, label) = _masteryInfo(mastery);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text('$label · $mastery%',
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }

  (Color, String) _masteryInfo(int mastery) {
    if (mastery >= 85) return (NinjaColors.success, '已掌握');
    if (mastery >= 60) return (NinjaColors.info, '熟悉');
    if (mastery >= 30) return (NinjaColors.warning, '学习中');
    return (NinjaColors.error, '陌生');
  }
}
