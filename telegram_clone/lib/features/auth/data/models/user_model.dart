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
    // id can arrive as int or string depending on the endpoint
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    return UserModel(
      id: id,
      username: json['username'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(json['last_seen'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
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
