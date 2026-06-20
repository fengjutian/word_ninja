import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/lib/cards/word_card.dart';
import 'package:ui_kit/lib/loading/ninja_loading.dart';
import 'package:ui_kit/lib/ninja_theme/ninja_theme.dart';
import '../providers/word_provider.dart';

/// 单词本主页面
class VocabularyPage extends ConsumerStatefulWidget {
  const VocabularyPage({super.key});

  @override
  ConsumerState<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends ConsumerState<VocabularyPage> {
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(wordListProvider.notifier).loadWords(refresh: true));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
                onChanged: (v) =>
                    ref.read(wordListProvider.notifier).search(v),
              )
            : const Text('单词修炼'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchCtrl.clear();
                ref.read(wordListProvider.notifier).loadWords(refresh: true);
              }
            }),
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/vocabulary/add'),
        backgroundColor: NinjaColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
            const Icon(Icons.error_outline, size: 48, color: NinjaColors.error),
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
            const Icon(Icons.menu_book, size: 64, color: NinjaColors.textSecondary),
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
      child: ListView.builder(
        padding: const EdgeInsets.only(top: NinjaSpacing.sm, bottom: 80),
        itemCount: state.words.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.words.length) {
            ref.read(wordListProvider.notifier).loadWords();
            return const NinjaLoading(message: '加载更多...');
          }

          final word = state.words[index];
          return WordCard(
            word: word.word,
            meaning: word.meaning,
            phonetic: word.phonetic.isNotEmpty ? '/${word.phonetic}/' : null,
            mastery: word.mastery,
            onTap: () => context.push('/vocabulary/detail/${word.id}'),
          );
        },
      ),
    );
  }
}
