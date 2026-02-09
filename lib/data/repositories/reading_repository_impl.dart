import 'package:bp_monitor/core/constants.dart';
import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/logger.dart';
import 'package:bp_monitor/data/dao/reading_dao.dart';
import 'package:bp_monitor/data/mappers/reading_mapper.dart';
import 'package:bp_monitor/domain/entities/reading_entity.dart';
import 'package:bp_monitor/domain/repositories/reading_repository.dart';

/// Blood pressure reading data access backed by Drift.
class ReadingRepositoryImpl implements ReadingRepository {
  ReadingRepositoryImpl({
    required ReadingDao readingDao,
    ReadingMapper? mapper,
  })  : _dao = readingDao,
        _mapper = mapper ?? const ReadingMapper();

  final ReadingDao _dao;
  final ReadingMapper _mapper;

  @override
  Future<Result<List<ReadingEntity>>> getByPatientId(
    String patientId, {
    DateTime? from,
    DateTime? to,
    MeasurementQuality? qualityFilter,
  }) async {
    try {
      final rows = await _dao.getByPatientId(
        patientId,
        from: from,
        to: to,
        qualityFilter: qualityFilter?.name,
      );
      return Success(rows.map(_mapper.fromRow).toList());
    } catch (e, st) {
      AppLogger.error('Failed to get readings', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<ReadingEntity?>> getById(String readingId) async {
    try {
      final row = await _dao.getById(readingId);
      return Success(row != null ? _mapper.fromRow(row) : null);
    } catch (e, st) {
      AppLogger.error('Failed to get reading', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> upsert(ReadingEntity reading) async {
    try {
      await _dao.upsertReading(_mapper.toCompanion(reading));
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to upsert reading', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(String readingId) async {
    try {
      await _dao.deleteReading(readingId);
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete reading', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> countByPatientId(String patientId) async {
    try {
      final count = await _dao.countByPatientId(patientId);
      return Success(count);
    } catch (e, st) {
      AppLogger.error('Failed to count readings', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }
}
