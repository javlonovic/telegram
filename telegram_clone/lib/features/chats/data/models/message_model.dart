import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel {
  const MessageModel({
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
  final UserModel sender;
  final int chatId;
  final String content;
  final String messageType;
  final DateTime createdAt;
  final String? mediaUrl;
  final String? mediaFileName;
  final int? mediaFileSize;
  final String? mediaMimeType;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      sender: UserModel.fromJson(json['sender'] as Map<String, dynamic>),
      chatId: json['chat'] as int,
      content: json['content'] as String? ?? '',
      messageType: json['message_type'] as String? ?? 'text',
      createdAt: DateTime.parse(json['created_at'] as String),
      mediaUrl: json['media_url'] as String?,
      mediaFileName: json['media_file_name'] as String?,
      mediaFileSize: json['media_file_size'] as int?,
      mediaMimeType: json['media_mime_type'] as String?,
    );
  }

  MessageEntity toEntity() => MessageEntity(
        id: id,
        sender: sender.toEntity(),
        chatId: chatId,
        content: content,
        messageType: _parseType(messageType),
        createdAt: createdAt,
        mediaUrl: mediaUrl,
        mediaFileName: mediaFileName,
        mediaFileSize: mediaFileSize,
        mediaMimeType: mediaMimeType,
      );

  static MessageType _parseType(String t) => MessageType.values.firstWhere(
        (e) => e.name == t,
        orElse: () => MessageType.text,
      );
}
