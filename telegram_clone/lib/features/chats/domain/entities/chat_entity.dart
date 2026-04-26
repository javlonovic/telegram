import '../../../auth/domain/entities/user_entity.dart';
import 'message_entity.dart';

enum ChatType { private, group, channel }

class ChatEntity {
  const ChatEntity({
    required this.id,
    required this.type,
    required this.members,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
  });

  final int id;
  final ChatType type;
  final List<UserEntity> members;
  final MessageEntity? lastMessage;
  final int unreadCount;
  final DateTime createdAt;

  /// Returns the other member's name for private chats.
  String displayName(int currentUserId) {
    if (type == ChatType.private) {
      final other = members.firstWhere(
        (m) => m.id != currentUserId,
        orElse: () => members.first,
      );
      return other.username;
    }
    return 'Group Chat #$id';
  }

  /// Returns the other member's avatar for private chats.
  String? displayAvatar(int currentUserId) {
    if (type == ChatType.private) {
      final other = members.firstWhere(
        (m) => m.id != currentUserId,
        orElse: () => members.first,
      );
      return other.avatarUrl;
    }
    return null;
  }
}
