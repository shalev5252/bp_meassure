import 'package:bp_monitor/data/dao/tables.dart';
import 'package:bp_monitor/data/database.dart';
import 'package:drift/drift.dart';

part 'risk_factor_dao.g.dart';

@DriftAccessor(tables: [PatientRiskFactors])
class RiskFactorDao extends DatabaseAccessor<AppDatabase>
    with _$RiskFactorDaoMixin {
  RiskFactorDao(super.db);

  Future<List<PatientRiskFactor>> getByPatientId(String patientId) =>
      (select(patientRiskFactors)
            ..where((t) => t.patientId.equals(patientId)))
          .get();

  Future<void> upsertRiskFactor(PatientRiskFactorsCompanion entry) =>
      into(patientRiskFactors).insertOnConflictUpdate(entry);

  Future<void> deleteByPatient(String patientId) =>
      (delete(patientRiskFactors)
            ..where((t) => t.patientId.equals(patientId)))
          .go();
}
