import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/domain/entities/user_entity.dart';

/// Contract for user data access (local cache of Firebase user).
abstract class UserRepository {
  Future<Result<void>> upsert(UserEntity user);
  Future<Result<UserEntity?>> getById(String userId);
  Future<Result<void>> delete(String userId);
}
