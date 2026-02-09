import 'package:bp_monitor/core/constants.dart';
import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/domain/entities/reading_entity.dart';

/// Contract for blood pressure reading data access.
abstract class ReadingRepository {
  Future<Result<List<ReadingEntity>>> getByPatientId(
    String patientId, {
    DateTime? from,
    DateTime? to,
    MeasurementQuality? qualityFilter,
  });
  Future<Result<ReadingEntity?>> getById(String readingId);
  Future<Result<void>> upsert(ReadingEntity reading);
  Future<Result<void>> delete(String readingId);
  Future<Result<int>> countByPatientId(String patientId);
}
