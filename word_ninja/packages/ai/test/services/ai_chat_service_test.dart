import 'dart:convert';
import 'dart:typed_data';

import 'package:ai/services/ai_chat_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiChatService.connectionResultFromResponse', () {
    test('accepts a non-empty model reply', () {
      final result = AiChatService.connectionResultFromResponse({
        'choices': [
          {
            'message': {'content': 'OK'}
          }
        ]
      });

      expect(result.$1, isTrue);
      expect(result.$2, contains('OK'));
    });

    test('rejects an empty reasoning-model reply', () {
      final result = AiChatService.connectionResultFromResponse({
        'choices': [
          {
            'message': {'content': ''},
            'finish_reason': 'length',
          }
        ]
      });

      expect(result.$1, isFalse);
      expect(result.$2, contains('没有返回文本'));
    });

    test('reports a MiniMax error carried in an HTTP 200 response', () {
      final result = AiChatService.connectionResultFromResponse({
        'base_resp': {'status_code': 1008, 'status_msg': 'insufficient balance'}
      });

      expect(result.$1, isFalse);
      expect(result.$2, contains('1008'));
    });
  });

  group('AiChatService.decodeSse', () {
    test('accepts Dio-style Uint8List chunks', () async {
      final stream = Stream<Uint8List>.value(
        Uint8List.fromList(
          utf8.encode(
            'data: {"choices":[{"delta":{"content":"ok"}}]}\n\n'
            'data: [DONE]\n\n',
          ),
        ),
      );

      expect(await AiChatService.decodeSse(stream).toList(), ['ok']);
    });

    test('decodes a multi-byte character split across network chunks',
        () async {
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
