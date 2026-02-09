import 'package:bp_monitor/core/constants.dart';
import 'package:bp_monitor/domain/entities/bp_category.dart';
import 'package:bp_monitor/domain/entities/pulse_status.dart';

/// Domain representation of a blood pressure reading.
class ReadingEntity {
  const ReadingEntity({
    required this.readingId,
    required this.patientId,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    required this.takenAt,
    this.contextTags = const [],
    this.measurementQuality,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String readingId;
  final String patientId;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final DateTime takenAt;
  final List<ContextTag> contextTags;
  final MeasurementQuality? measurementQuality;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// BP classification for this reading.
  BpCategory get bpCategory => BpCategory.classify(systolic, diastolic);

  /// Pulse classification, or null if pulse is not recorded.
  PulseStatus? get pulseStatus =>
      pulse != null ? PulseStatus.classify(pulse!) : null;

  /// Whether this reading triggers a BP red flag (crisis).
  bool get isBpRedFlag => bpCategory == BpCategory.crisis;

  /// Whether this reading triggers a pulse warning.
  bool get isPulseWarning {
    final status = pulseStatus;
    return status != null && status != PulseStatus.normal;
  }
}
