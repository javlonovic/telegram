import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl() : _dataSource = ChatRemoteDataSource();

  final ChatRemoteDataSource _dataSource;

  @override
  Future<List<ChatEntity>> getChats() async {
    final models = await _dataSource.getChats();
    final entities = models.map((m) => m.toEntity()).toList();

    // Deduplicate private chats — keep only the most recent per other-user pair.
    final seen = <String>{};
    final deduped = <ChatEntity>[];
    for (final chat in entities) {
      String key;
      if (chat.type == ChatType.private) {
        // Sort member ids and join with underscore for a stable unique key
        final ids = chat.members.map((m) => m.id).toList();
        ids.sort();
        key = 'p_${ids.join('_')}';
      } else {
        key = 'g_${chat.id}';
      }
      if (seen.add(key)) deduped.add(chat);
    }
    return deduped;
  }

  @override
  Future<List<MessageEntity>> getMessages(int chatId, {int page = 1}) async {
    final models = await _dataSource.getMessages(chatId, page: page);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ChatEntity> createPrivateChat(int targetUserId) async {
    final model = await _dataSource.createPrivateChat(targetUserId);
    return model.toEntity();
  }
}
