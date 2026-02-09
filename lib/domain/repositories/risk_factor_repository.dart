import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/domain/entities/risk_factor_entity.dart';

/// Contract for patient risk factor data access.
abstract class RiskFactorRepository {
  Future<Result<List<RiskFactorEntity>>> getByPatientId(String patientId);
  Future<Result<void>> upsert(RiskFactorEntity riskFactor);
  Future<Result<void>> deleteByPatient(String patientId);
}
