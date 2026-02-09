import 'package:bp_monitor/core/constants.dart';

/// Pulse rate classification.
enum PulseStatus {
  low,
  normal,
  high;

  /// Classify a pulse value.
  static PulseStatus classify(int bpm) {
    if (bpm < PulseThresholds.lowMin) return low;
    if (bpm > PulseThresholds.highMax) return high;
    return normal;
  }
}
