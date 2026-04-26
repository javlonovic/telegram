import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/websocket_service.dart';
import '../../data/models/message_model.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chats_provider.dart';

// Current open chat ID
final activeChatIdProvider = StateProvider<int?>((ref) => null);

final messagesProvider = StateNotifierProvider.family<
    MessagesNotifier, AsyncValue<List<MessageEntity>>, int>((ref, chatId) {
  return MessagesNotifier(
    chatId: chatId,
    repository: ref.read(chatRepositoryProvider),
  );
});

class MessagesNotifier
    extends StateNotifier<AsyncValue<List<MessageEntity>>> {
  MessagesNotifier({
    required this.chatId,
    required this.repository,
  }) : super(const AsyncValue.loading()) {
    _init();
  }

  final int chatId;
  final ChatRepository repository;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  Future<void> _init() async {
    await loadHistory();
    await _connectWebSocket();
  }

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => repository.getMessages(chatId),
    );
  }

  Future<void> _connectWebSocket() async {
    await WebSocketService.instance.connect(chatId);
    _wsSub = WebSocketService.instance.messageStream.listen((data) {
      if (data.containsKey('error')) return;
      try {
        final message = MessageModel.fromJson(data).toEntity();
        final current = state.valueOrNull ?? [];
        state = AsyncValue.data([...current, message]);
      } catch (_) {}
    });
  }

  void sendMessage(String content) {
    WebSocketService.instance.sendMessage(content: content);
  }

  void appendMessage(MessageEntity message) {
    final current = state.valueOrNull ?? [];
    // Avoid duplicates (WebSocket may also broadcast the upload)
    if (current.any((m) => m.id == message.id)) return;
    state = AsyncValue.data([...current, message]);
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    WebSocketService.instance.disconnect();
    super.dispose();
  }
}
