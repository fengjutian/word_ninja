import 'dart:convert';

import 'package:ai/services/ai_chat_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiChatService.decodeSse', () {
    test('decodes a multi-byte character split across network chunks', () async {
      final bytes = utf8.encode(
        'data: {"choices":[{"delta":{"content":"\u4f60\u597d"}}]}\n\n'
        'data: [DONE]\n\n',
      );
      final split = bytes.indexOf(0xe5) + 1;
      final stream = Stream<List<int>>.fromIterable([
        bytes.sublist(0, split),
        bytes.sublist(split),
      ]);

      expect(await AiChatService.decodeSse(stream).toList(), ['\u4f60\u597d']);
    });

    test('emits a final event without a trailing newline', () async {
      final stream = Stream<List<int>>.value(
        utf8.encode('data:{"choices":[{"delta":{"content":"done"}}]}'),
      );

      expect(await AiChatService.decodeSse(stream).toList(), ['done']);
    });

    test('ignores comments, malformed events, and empty deltas', () async {
      final stream = Stream<List<int>>.value(utf8.encode(
        ': keep-alive\n'
        'data: not-json\n'
        'data: {"choices":[{"delta":{}}]}\n'
        'data: {"choices":[{"delta":{"content":"ok"}}]}\n'
        'data: [DONE]\n'
        'data: {"choices":[{"delta":{"content":"ignored"}}]}\n',
      ));

      expect(await AiChatService.decodeSse(stream).toList(), ['ok']);
    });
  });
}
