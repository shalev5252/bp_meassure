/// Domain representation of an authenticated user.
class UserEntity {
  const UserEntity({
    required this.userId,
    required this.email,
    required this.createdAt,
    required this.lastLoginAt,
  });

  final String userId;
  final String email;
  final DateTime createdAt;
  final DateTime lastLoginAt;
}
