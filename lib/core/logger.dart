import 'dart:developer' as dev;

/// Lightweight logging utility.
///
/// Uses `dart:developer` log which integrates with DevTools and is
/// stripped from release builds by the tree-shaker.
class AppLogger {
  AppLogger._();

  static void debug(String message, {String tag = 'APP'}) {
    dev.log(message, name: tag, level: 500);
  }

  static void info(String message, {String tag = 'APP'}) {
    dev.log(message, name: tag, level: 800);
  }

  static void warning(String message, {String tag = 'APP'}) {
    dev.log(message, name: tag, level: 900);
  }

  static void error(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      name: tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
