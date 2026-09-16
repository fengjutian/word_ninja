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
}
