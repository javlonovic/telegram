/// Pure domain entity — no JSON, no Flutter, no external deps.
class UserEntity {
  const UserEntity({
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

  UserEntity copyWith({
    int? id,
    String? username,
    String? phone,
    String? bio,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
