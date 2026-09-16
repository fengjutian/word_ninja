import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/app_theme/theme_data.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:vocabulary/presentation/pages/word_graph_page.dart';

void main() {
  Future<Map<String, List<Map<String, String>>>> emptyRelations(_) async => {
        'synonyms': [],
        'antonyms': [],
        'related': [],
        'derivatives': [],
      };

  testWidgets('rebuilds graph when words arrive after the empty state',
      (tester) async {
    Widget app(List<Word> words) => ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: WordGraphPage(words: words, relationLoader: emptyRelations),
          ),
        );

    await tester.pumpWidget(app(const []));
    expect(find.text('还没有可关联的单词'), findsOneWidget);

    const word = Word(
      id: '1',
      userId: 'local',
      word: 'priority',
      meaning: '优先事项',
    );
    await tester.pumpWidget(app(const [word]));
    await tester.pumpAndSettle();

    expect(find.text('priority'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('expands semantic relations and filters invalid nodes',
      (tester) async {
    const words = [
      Word(id: '1', userId: 'local', word: 'week', meaning: '周'),
    ];

    Future<Map<String, List<Map<String, String>>>> loadRelations(_) async => {
          'synonyms': [
            {'word': 'seven-day period', 'meaning': '七天周期'},
          ],
          'antonyms': [
            {'word': 'nan', 'meaning': ''},
          ],
          'related': [
            {'word': 'calendar', 'meaning': '日历'},
          ],
          'derivatives': [
            {'word': 'weekly', 'meaning': '每周的'},
          ],
        };

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: WordGraphPage(words: words, relationLoader: loadRelations),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('3'), findsNWidgets(2));
    expect(find.text('关联节点'), findsOneWidget);
    expect(find.text('关系数量'), findsOneWidget);
    expect(find.text('近义词'), findsOneWidget);
    expect(find.text('反义词'), findsOneWidget);
    expect(find.text('相关词'), findsOneWidget);
    expect(find.text('派生词'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
