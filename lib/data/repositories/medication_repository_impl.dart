import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/logger.dart';
import 'package:bp_monitor/data/dao/medication_dao.dart';
import 'package:bp_monitor/data/mappers/medication_mapper.dart';
import 'package:bp_monitor/domain/entities/medication_entity.dart';
import 'package:bp_monitor/domain/repositories/medication_repository.dart';

/// Medication data access backed by Drift.
class MedicationRepositoryImpl implements MedicationRepository {
  MedicationRepositoryImpl({
    required MedicationDao medicationDao,
    MedicationMapper? mapper,
  })  : _dao = medicationDao,
        _mapper = mapper ?? const MedicationMapper();

  final MedicationDao _dao;
  final MedicationMapper _mapper;

  @override
  Future<Result<List<MedicationEntity>>> getByPatientId(
    String patientId, {
    bool? activeOnly,
  }) async {
    try {
      final rows = await _dao.getByPatientId(patientId, activeOnly: activeOnly);
      return Success(rows.map(_mapper.fromRow).toList());
    } catch (e, st) {
      AppLogger.error('Failed to get medications', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> upsert(MedicationEntity medication) async {
    try {
      await _dao.upsertMedication(_mapper.toCompanion(medication));
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to upsert medication', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(String medicationId) async {
    try {
      await _dao.deleteMedication(medicationId);
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete medication', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }
}
