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
      '四格漫画记忆',
      '马上练一下',
    ]) {
      expect(aiTutorSystemPrompt, contains(section));
    }
  });

  test('word teaching prompt makes commonly omitted sections mandatory', () {
    expect(aiTutorSystemPrompt, contains('标题、顺序都不要省略'));
    expect(aiTutorSystemPrompt, contains('不能跳过近义词、反义词或漫画记忆'));
    expect(aiTutorSystemPrompt, contains('> ①'));
    expect(aiTutorSystemPrompt, contains('> ④'));
    expect(aiTutorSystemPrompt, contains('没有自然的反义词'));
  });

  test('prompt prevents reasoning traces from leaking into the answer', () {
    expect(aiTutorSystemPrompt, contains('<think>'));
    expect(aiTutorSystemPrompt, contains('不展示思考过程'));
  });
}
