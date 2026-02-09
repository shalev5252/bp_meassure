import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/logger.dart';
import 'package:bp_monitor/data/dao/risk_factor_dao.dart';
import 'package:bp_monitor/data/mappers/risk_factor_mapper.dart';
import 'package:bp_monitor/domain/entities/risk_factor_entity.dart';
import 'package:bp_monitor/domain/repositories/risk_factor_repository.dart';

/// Risk factor data access backed by Drift.
class RiskFactorRepositoryImpl implements RiskFactorRepository {
  RiskFactorRepositoryImpl({
    required RiskFactorDao riskFactorDao,
    RiskFactorMapper? mapper,
  })  : _dao = riskFactorDao,
        _mapper = mapper ?? const RiskFactorMapper();

  final RiskFactorDao _dao;
  final RiskFactorMapper _mapper;

  @override
  Future<Result<List<RiskFactorEntity>>> getByPatientId(
      String patientId) async {
    try {
      final rows = await _dao.getByPatientId(patientId);
      return Success(rows.map(_mapper.fromRow).toList());
    } catch (e, st) {
      AppLogger.error('Failed to get risk factors', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> upsert(RiskFactorEntity riskFactor) async {
    try {
      await _dao.upsertRiskFactor(_mapper.toCompanion(riskFactor));
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to upsert risk factor', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteByPatient(String patientId) async {
    try {
      await _dao.deleteByPatient(patientId);
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete risk factors', tag: 'REPO', error: e, stackTrace: st);
      return Err(DatabaseFailure(e.toString()));
    }
  }
}
