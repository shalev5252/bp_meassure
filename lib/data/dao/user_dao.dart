import 'package:bp_monitor/data/dao/tables.dart';
import 'package:bp_monitor/data/database.dart';
import 'package:drift/drift.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<void> upsertUser(UsersCompanion user) =>
      into(users).insertOnConflictUpdate(user);

  Future<User?> getUserById(String userId) =>
      (select(users)..where((t) => t.userId.equals(userId)))
          .getSingleOrNull();

  Future<void> deleteUser(String userId) =>
      (delete(users)..where((t) => t.userId.equals(userId))).go();
}
