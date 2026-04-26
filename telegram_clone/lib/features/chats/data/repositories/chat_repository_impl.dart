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
    return models.map((m) => m.toEntity()).toList();
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
