import 'package:ai_tutor/providers/chat_history_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chat session state requires a valid current session', () {
    const session = ChatSession(
      id: 'test',
      title: 'Test',
      messages: [],
      createdAt: 0,
    );

    final state = ChatSessionsState(
      sessions: [session],
      currentIndex: 0,
    );

    expect(state.current, same(session));
  });
}
