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
    // For private chats, show the other person's name
    if (type == ChatType.private) {
      // Try to find a member that isn't the current user
      final others = members.where((m) => m.id != currentUserId).toList();
      if (others.isNotEmpty) return others.first.username;
      // Fallback: show first member (edge case: chatting with yourself)
      if (members.isNotEmpty) return members.first.username;
    }
    return 'Group Chat #$id';
  }

  /// Returns the other member's avatar for private chats.
  String? displayAvatar(int currentUserId) {
    if (type == ChatType.private) {
      final others = members.where((m) => m.id != currentUserId).toList();
      if (others.isNotEmpty) return others.first.avatarUrl;
      if (members.isNotEmpty) return members.first.avatarUrl;
    }
    return null;
  }
}
