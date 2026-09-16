import 'package:ai_tutor/prompts/tutor_prompt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('word teaching prompt includes the complete learning scaffold', () {
    for (final section in [
      '核心感觉',
      '近义词辨析',
      '反义词',
      '常用搭配',
      '场景例句',
      '图形记忆',
      '马上练一下',
    ]) {
      expect(aiTutorSystemPrompt, contains(section));
    }
  });

  test('prompt prevents reasoning traces from leaking into the answer', () {
    expect(aiTutorSystemPrompt, contains('<think>'));
    expect(aiTutorSystemPrompt, contains('不展示思考过程'));
  });
}
