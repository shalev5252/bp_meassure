import 'dart:io';
import 'dart:math';

import 'package:bp_monitor/data/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const _keyStorageKey = 'bp_monitor_db_key';

/// Provides the encrypted [AppDatabase] singleton.
///
/// The encryption key is generated once and stored in the device keychain
/// via [FlutterSecureStorage]. On subsequent launches the existing key
/// is reused.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'databaseProvider must be overridden after async init. '
    'Call initDatabase() before runApp.',
  );
});

/// Initialise the encrypted database and return it.
///
/// Call this once during app bootstrap, then override [databaseProvider]
/// in the ProviderScope.
Future<AppDatabase> initDatabase() async {
  final key = await _getOrCreateKey();
  final dbDir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbDir.path, 'bp_monitor_encrypted.db'));

  final queryExecutor = NativeDatabase(
    file,
    setup: (db) {
      db.execute("PRAGMA key = '$key'");
    },
  );
  return AppDatabase(queryExecutor);
}

Future<String> _getOrCreateKey() async {
  const storage = FlutterSecureStorage();
  var key = await storage.read(key: _keyStorageKey);
  if (key == null) {
    key = _generateKey(32);
    await storage.write(key: _keyStorageKey, value: key);
  }
  return key;
}

String _generateKey(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rng = Random.secure();
  return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
}
