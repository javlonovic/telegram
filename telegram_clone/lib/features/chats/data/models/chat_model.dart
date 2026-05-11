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
    // members arrive as ChatMemberSerializer: {"user": {...}, "role": "...", "joined_at": "..."}
    final membersJson = json['members'] as List<dynamic>? ?? [];
    final lastMsgJson = json['last_message'] as Map<String, dynamic>?;

    return ChatModel(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'private',
      members: membersJson.map((m) {
        final map = m as Map<String, dynamic>;
        // Unwrap nested user object if present (ChatMemberSerializer format)
        final userMap = (map.containsKey('user') && map['user'] is Map)
            ? map['user'] as Map<String, dynamic>
            : map;
        return UserModel.fromJson(userMap);
      }).toList(),
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
    switch (t.toLowerCase().trim()) {
      case 'private':
        return ChatType.private;
      case 'group':
        return ChatType.group;
      case 'channel':
        return ChatType.channel;
      default:
        return ChatType.private;
    }
  }
}
