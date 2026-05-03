import '../../domain/entities/user_entity.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.phone,
    this.bio = '',
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
  });

  final int id;
  final String username;
  final String phone;
  final String bio;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      phone: json['phone'] as String,
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        username: username,
        phone: phone,
        bio: bio,
        avatarUrl: avatarUrl,
        isOnline: isOnline,
        lastSeen: lastSeen,
        createdAt: createdAt,
      );
}
