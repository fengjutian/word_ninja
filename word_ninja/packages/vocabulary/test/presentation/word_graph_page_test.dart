import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/app_theme/theme_data.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:vocabulary/presentation/pages/word_graph_page.dart';

void main() {
  testWidgets('rebuilds graph when words arrive after the empty state',
      (tester) async {
    Widget app(List<Word> words) => MaterialApp(
          theme: AppTheme.light,
          home: WordGraphPage(words: words),
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
    await tester.pump();

    expect(find.text('priority'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows every vocabulary item as a graph node', (tester) async {
    final words = List.generate(
      9,
      (index) => Word(
        id: '$index',
        userId: 'local',
        word: 'word$index',
        meaning: 'meaning $index',
        difficulty: index % 5 + 1,
        source: 'source-$index',
      ),
    );

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: WordGraphPage(words: words),
    ));

    expect(find.text('8'), findsNWidgets(2));
    expect(find.text('关联节点'), findsOneWidget);
    expect(find.text('关系数量'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
