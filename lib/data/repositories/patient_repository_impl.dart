import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/logger.dart';
import 'package:bp_monitor/data/dao/patient_dao.dart';
import 'package:bp_monitor/data/mappers/patient_mapper.dart';
import 'package:bp_monitor/domain/entities/patient_entity.dart';
import 'package:bp_monitor/domain/repositories/patient_repository.dart';

/// Single patient per user, backed by Drift.
class PatientRepositoryImpl implements PatientRepository {
  PatientRepositoryImpl({
    required PatientDao patientDao,
    PatientMapper? mapper,
  })  : _dao = patientDao,
        _mapper = mapper ?? const PatientMapper();

  final PatientDao _dao;
  final PatientMapper _mapper;

  @override
  Future<Result<void>> upsert(PatientEntity patient) async {
    try {
      await _dao.upsertPatient(_mapper.toCompanion(patient));
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to upsert patient', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<PatientEntity?>> getByUserId(String userId) async {
    try {
      final row = await _dao.getPatientByUserId(userId);
      return Success(row != null ? _mapper.fromRow(row) : null);
    } catch (e, st) {
      AppLogger.error('Failed to get patient by userId', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<PatientEntity?>> getById(String patientId) async {
    try {
      final row = await _dao.getPatientById(patientId);
      return Success(row != null ? _mapper.fromRow(row) : null);
    } catch (e, st) {
      AppLogger.error('Failed to get patient by id', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(String patientId) async {
    try {
      await _dao.deletePatient(patientId);
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete patient', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }
}
