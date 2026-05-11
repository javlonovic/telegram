import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
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
    _deduplicateThenLoad();
  }

  final ChatRepository _repository;

  /// Call the backend deduplicate endpoint once, then load chats.
  Future<void> _deduplicateThenLoad() async {
    try {
      await DioClient.instance.dio.post('${ApiConstants.chats}deduplicate/');
    } catch (_) {
      // Non-fatal — proceed even if this fails
    }
    await loadChats();
  }

  Future<void> loadChats() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getChats());
  }

  Future<void> refresh() => loadChats();
}
