import '../../../auth/domain/entities/user_entity.dart';

enum MessageType { text, image, file, audio, video }

class MessageEntity {
  const MessageEntity({
    required this.id,
    required this.sender,
    required this.chatId,
    required this.content,
    required this.messageType,
    required this.createdAt,
    this.mediaUrl,
    this.mediaFileName,
    this.mediaFileSize,
    this.mediaMimeType,
  });

  final int id;
  final UserEntity sender;
  final int chatId;
  final String content;
  final MessageType messageType;
  final DateTime createdAt;

  // Media
  final String? mediaUrl;
  final String? mediaFileName;
  final int? mediaFileSize;
  final String? mediaMimeType;

  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;
  bool get isImage => messageType == MessageType.image;
  bool get isVideo => messageType == MessageType.video;
  bool get isAudio => messageType == MessageType.audio;
  bool get isFile => messageType == MessageType.file;

  bool isMine(int currentUserId) => sender.id == currentUserId;

  String get formattedFileSize {
    if (mediaFileSize == null) return '';
    final kb = mediaFileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}
