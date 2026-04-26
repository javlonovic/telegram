import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<List<ChatEntity>> getChats();
  Future<List<MessageEntity>> getMessages(int chatId, {int page = 1});
  Future<ChatEntity> createPrivateChat(int targetUserId);
}
