import 'package:bp_monitor/data/database.dart';
import 'package:bp_monitor/domain/entities/user_entity.dart';
import 'package:drift/drift.dart';

/// Maps between [User] (Drift row) and [UserEntity] (domain).
class UserMapper {
  const UserMapper();

  UserEntity fromRow(User row) => UserEntity(
        userId: row.userId,
        email: row.email,
        createdAt: row.createdAt,
        lastLoginAt: row.lastLoginAt,
      );

  UsersCompanion toCompanion(UserEntity entity) => UsersCompanion(
        userId: Value(entity.userId),
        email: Value(entity.email),
        createdAt: Value(entity.createdAt),
        lastLoginAt: Value(entity.lastLoginAt),
      );
}
