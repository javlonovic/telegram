import '../../domain/entities/user_entity.dart';

/// Data model — handles JSON serialization and maps to domain entity.
class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.phone,
    this.bio = '',
    this.avatarUrl,
    required this.createdAt,
  });

  final int id;
  final String username;
  final String phone;
  final String bio;
  final String? avatarUrl;
  final DateTime createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      phone: json['phone'] as String,
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'phone': phone,
        'bio': bio,
        'avatar_url': avatarUrl,
        'created_at': createdAt.toIso8601String(),
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        username: username,
        phone: phone,
        bio: bio,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
      );
}
