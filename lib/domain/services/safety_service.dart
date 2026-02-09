import 'package:bp_monitor/domain/entities/reading_entity.dart';

/// Result of a safety check on a reading.
class SafetyCheckResult {
  const SafetyCheckResult({
    required this.hasBpRedFlag,
    required this.hasPulseWarning,
  });

  /// BP red flag: SYS ≥180 OR DIA ≥120. Blocks AI access.
  final bool hasBpRedFlag;

  /// Pulse warning: <50 bpm or >100 bpm. Non-blocking.
  final bool hasPulseWarning;

  bool get hasAnyAlert => hasBpRedFlag || hasPulseWarning;
}

/// Evaluates readings for safety alerts.
class SafetyService {
  const SafetyService();

  /// Check a single reading for safety alerts.
  SafetyCheckResult check(ReadingEntity reading) {
    return SafetyCheckResult(
      hasBpRedFlag: reading.isBpRedFlag,
      hasPulseWarning: reading.isPulseWarning,
    );
  }

  /// Check whether any reading in the list has a BP red flag.
  /// Used to determine if AI should be blocked for the session.
  bool hasActiveRedFlag(List<ReadingEntity> readings) {
    return readings.any((r) => r.isBpRedFlag);
  }
}
