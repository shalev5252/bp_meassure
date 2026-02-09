import 'package:bp_monitor/data/dao/medication_dao.dart';
import 'package:bp_monitor/data/dao/patient_dao.dart';
import 'package:bp_monitor/data/dao/reading_dao.dart';
import 'package:bp_monitor/data/dao/risk_factor_dao.dart';
import 'package:bp_monitor/data/dao/tables.dart';
import 'package:bp_monitor/data/dao/user_dao.dart';
import 'package:drift/drift.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Users, Patients, PatientRiskFactors, PatientMedications, Readings],
  daos: [UserDao, PatientDao, RiskFactorDao, MedicationDao, ReadingDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Future migrations go here, e.g.:
          // if (from < 2) { await m.addColumn(...); }
        },
      );
}
