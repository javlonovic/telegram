class UserEntity {
  const UserEntity({
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

  UserEntity copyWith({
    int? id,
    String? username,
    String? phone,
    String? bio,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
