import 'package:drift/drift.dart';

/// Local cache of Firebase user.
class Users extends Table {
  TextColumn get userId => text()();
  TextColumn get email => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastLoginAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Patient profile.
class Patients extends Table {
  TextColumn get patientId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get displayName => text()();
  TextColumn get dateOfBirth => text().nullable()();
  TextColumn get sex => text().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {patientId};
}

/// Risk factors per patient (composite PK: patientId + riskCode).
class PatientRiskFactors extends Table {
  TextColumn get patientId => text().references(Patients, #patientId)();
  TextColumn get riskCode => text()();
  BoolColumn get isPresent => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {patientId, riskCode};
}

/// Medications per patient.
class PatientMedications extends Table {
  TextColumn get medicationId => text()();
  TextColumn get patientId => text().references(Patients, #patientId)();
  TextColumn get name => text()();
  TextColumn get doseText => text().nullable()();
  TextColumn get frequencyText => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get startedOn => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {medicationId};
}

/// Blood pressure readings.
class Readings extends Table {
  TextColumn get readingId => text()();
  TextColumn get patientId => text().references(Patients, #patientId)();
  IntColumn get systolic => integer()();
  IntColumn get diastolic => integer()();
  IntColumn get pulse => integer().nullable()();
  DateTimeColumn get takenAt => dateTime()();
  TextColumn get contextTags => text().nullable()();
  TextColumn get measurementQuality => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {readingId};
}
