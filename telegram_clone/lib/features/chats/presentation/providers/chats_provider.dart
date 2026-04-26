import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (_) => ChatRepositoryImpl(),
);

// ---------------------------------------------------------------------------
// Chat List
// ---------------------------------------------------------------------------

final chatsProvider =
    StateNotifierProvider<ChatsNotifier, AsyncValue<List<ChatEntity>>>((ref) {
  return ChatsNotifier(ref.read(chatRepositoryProvider));
});

class ChatsNotifier extends StateNotifier<AsyncValue<List<ChatEntity>>> {
  ChatsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadChats();
  }

  final ChatRepository _repository;

  Future<void> loadChats() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getChats());
  }

  Future<void> refresh() => loadChats();
}
