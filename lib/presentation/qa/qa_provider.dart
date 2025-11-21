import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/providers/api_provider.dart';
import 'package:islamic_app/domain/entities/chat_message.dart';

class QANotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() {
    return [];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = [...state, userMessage];

    // Get AI response
    try {
      ref.read(qaLoadingProvider.notifier).setLoading(true);
      final api = ref.read(mockApiServiceProvider);
      final response = await api.getAnswer(text);

      final aiMessage = ChatMessage(
        id: response['id'],
        text: response['answer'],
        isUser: false,
        timestamp: DateTime.parse(response['timestamp']),
      );
      state = [...state, aiMessage];
    } catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().toString(),
        text: "Sorry, I couldn't get an answer at this time.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, errorMessage];
    } finally {
      ref.read(qaLoadingProvider.notifier).setLoading(false);
    }
  }
}

final qaProvider = NotifierProvider<QANotifier, List<ChatMessage>>(
  QANotifier.new,
);

class QaLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) {
    state = value;
  }
}

final qaLoadingProvider = NotifierProvider<QaLoadingNotifier, bool>(
  QaLoadingNotifier.new,
);
