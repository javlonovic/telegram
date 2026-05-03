import '../../../auth/domain/entities/user_entity.dart';

class ContactEntity {
  const ContactEntity({
    required this.id,
    required this.contact,
    this.nickname = '',
    required this.createdAt,
  });

  final int id;
  final UserEntity contact;
  final String nickname;
  final DateTime createdAt;

  String get displayName =>
      nickname.isNotEmpty ? nickname : contact.username;
}
