import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/logger.dart';
import 'package:bp_monitor/data/dao/user_dao.dart';
import 'package:bp_monitor/data/mappers/user_mapper.dart';
import 'package:bp_monitor/domain/entities/user_entity.dart';
import 'package:bp_monitor/domain/repositories/user_repository.dart';

/// Local cache of Firebase user backed by Drift.
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required UserDao userDao, UserMapper? mapper})
      : _dao = userDao,
        _mapper = mapper ?? const UserMapper();

  final UserDao _dao;
  final UserMapper _mapper;

  @override
  Future<Result<void>> upsert(UserEntity user) async {
    try {
      await _dao.upsertUser(_mapper.toCompanion(user));
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to upsert user', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity?>> getById(String userId) async {
    try {
      final row = await _dao.getUserById(userId);
      return Success(row != null ? _mapper.fromRow(row) : null);
    } catch (e, st) {
      AppLogger.error('Failed to get user', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(String userId) async {
    try {
      await _dao.deleteUser(userId);
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete user', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }
}
