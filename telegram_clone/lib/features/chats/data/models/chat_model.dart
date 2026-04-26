import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/chat_entity.dart';
import 'message_model.dart';

class ChatModel {
  const ChatModel({
    required this.id,
    required this.type,
    required this.members,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
  });

  final int id;
  final String type;
  final List<UserModel> members;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime createdAt;

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final membersJson = json['members'] as List<dynamic>? ?? [];
    final lastMsgJson = json['last_message'] as Map<String, dynamic>?;

    return ChatModel(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'private',
      members: membersJson
          .map((m) => UserModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      lastMessage:
          lastMsgJson != null ? MessageModel.fromJson(lastMsgJson) : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  ChatEntity toEntity() => ChatEntity(
        id: id,
        type: _parseType(type),
        members: members.map((m) => m.toEntity()).toList(),
        lastMessage: lastMessage?.toEntity(),
        unreadCount: unreadCount,
        createdAt: createdAt,
      );

  static ChatType _parseType(String t) {
    return ChatType.values.firstWhere(
      (e) => e.name == t,
      orElse: () => ChatType.private,
    );
  }
}
