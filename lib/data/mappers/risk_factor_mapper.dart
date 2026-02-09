import 'package:bp_monitor/core/constants.dart';
import 'package:bp_monitor/data/database.dart';
import 'package:bp_monitor/domain/entities/risk_factor_entity.dart';
import 'package:drift/drift.dart';

/// Maps between [PatientRiskFactor] (Drift row) and [RiskFactorEntity] (domain).
class RiskFactorMapper {
  const RiskFactorMapper();

  RiskFactorEntity fromRow(PatientRiskFactor row) => RiskFactorEntity(
        patientId: row.patientId,
        riskCode: RiskCode.values.byName(row.riskCode),
        isPresent: row.isPresent,
        notes: row.notes,
        updatedAt: row.updatedAt,
      );

  PatientRiskFactorsCompanion toCompanion(RiskFactorEntity entity) =>
      PatientRiskFactorsCompanion(
        patientId: Value(entity.patientId),
        riskCode: Value(entity.riskCode.name),
        isPresent: Value(entity.isPresent),
        notes: Value(entity.notes),
        updatedAt: Value(entity.updatedAt),
      );
}
