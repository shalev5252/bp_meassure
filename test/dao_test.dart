import 'package:bp_monitor/data/database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _createTestDb() {
  return AppDatabase(NativeDatabase.memory());
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = _createTestDb();
  });

  tearDown(() => db.close());

  group('UserDao', () {
    test('upsert and retrieve user', () async {
      final now = DateTime.now();
      await db.userDao.upsertUser(
        UsersCompanion.insert(
          userId: 'uid1',
          email: 'test@example.com',
          createdAt: now,
          lastLoginAt: now,
        ),
      );
      final user = await db.userDao.getUserById('uid1');
      expect(user, isNotNull);
      expect(user!.email, 'test@example.com');
    });

    test('delete user', () async {
      final now = DateTime.now();
      await db.userDao.upsertUser(
        UsersCompanion.insert(
          userId: 'uid1',
          email: 'test@example.com',
          createdAt: now,
          lastLoginAt: now,
        ),
      );
      await db.userDao.deleteUser('uid1');
      final user = await db.userDao.getUserById('uid1');
      expect(user, isNull);
    });
  });

  group('PatientDao', () {
    setUp(() async {
      final now = DateTime.now();
      await db.userDao.upsertUser(
        UsersCompanion.insert(
          userId: 'uid1',
          email: 'test@example.com',
          createdAt: now,
          lastLoginAt: now,
        ),
      );
    });

    test('upsert and retrieve patient', () async {
      final now = DateTime.now();
      await db.patientDao.upsertPatient(
        PatientsCompanion.insert(
          patientId: 'p1',
          userId: 'uid1',
          displayName: 'John Doe',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final patient = await db.patientDao.getPatientByUserId('uid1');
      expect(patient, isNotNull);
      expect(patient!.displayName, 'John Doe');
    });

    test('delete patient', () async {
      final now = DateTime.now();
      await db.patientDao.upsertPatient(
        PatientsCompanion.insert(
          patientId: 'p1',
          userId: 'uid1',
          displayName: 'John Doe',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await db.patientDao.deletePatient('p1');
      final patient = await db.patientDao.getPatientById('p1');
      expect(patient, isNull);
    });
  });

  group('RiskFactorDao', () {
    setUp(() async {
      final now = DateTime.now();
      await db.userDao.upsertUser(
        UsersCompanion.insert(
          userId: 'uid1',
          email: 'test@example.com',
          createdAt: now,
          lastLoginAt: now,
        ),
      );
      await db.patientDao.upsertPatient(
        PatientsCompanion.insert(
          patientId: 'p1',
          userId: 'uid1',
          displayName: 'John Doe',
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    test('upsert and retrieve risk factors', () async {
      final now = DateTime.now();
      await db.riskFactorDao.upsertRiskFactor(
        PatientRiskFactorsCompanion.insert(
          patientId: 'p1',
          riskCode: 'diabetes_type2',
          updatedAt: now,
          isPresent: const Value(true),
        ),
      );
      final factors = await db.riskFactorDao.getByPatientId('p1');
      expect(factors, hasLength(1));
      expect(factors.first.riskCode, 'diabetes_type2');
      expect(factors.first.isPresent, true);
    });
  });

  group('MedicationDao', () {
    setUp(() async {
      final now = DateTime.now();
      await db.userDao.upsertUser(
        UsersCompanion.insert(
          userId: 'uid1',
          email: 'test@example.com',
          createdAt: now,
          lastLoginAt: now,
        ),
      );
      await db.patientDao.upsertPatient(
        PatientsCompanion.insert(
          patientId: 'p1',
          userId: 'uid1',
          displayName: 'John Doe',
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    test('upsert and retrieve medications', () async {
      final now = DateTime.now();
      await db.medicationDao.upsertMedication(
        PatientMedicationsCompanion.insert(
          medicationId: 'm1',
          patientId: 'p1',
          name: 'Amlodipine',
          updatedAt: now,
        ),
      );
      final meds = await db.medicationDao.getByPatientId('p1');
      expect(meds, hasLength(1));
      expect(meds.first.name, 'Amlodipine');
      expect(meds.first.isActive, true);
    });

    test('filter active only', () async {
      final now = DateTime.now();
      await db.medicationDao.upsertMedication(
        PatientMedicationsCompanion.insert(
          medicationId: 'm1',
          patientId: 'p1',
          name: 'Amlodipine',
          updatedAt: now,
        ),
      );
      await db.medicationDao.upsertMedication(
        PatientMedicationsCompanion.insert(
          medicationId: 'm2',
          patientId: 'p1',
          name: 'OldDrug',
          updatedAt: now,
          isActive: const Value(false),
        ),
      );
      final active =
          await db.medicationDao.getByPatientId('p1', activeOnly: true);
      expect(active, hasLength(1));
      expect(active.first.name, 'Amlodipine');

      final all = await db.medicationDao.getByPatientId('p1');
      expect(all, hasLength(2));
    });
  });

  group('ReadingDao', () {
    setUp(() async {
      final now = DateTime.now();
      await db.userDao.upsertUser(
        UsersCompanion.insert(
          userId: 'uid1',
          email: 'test@example.com',
          createdAt: now,
          lastLoginAt: now,
        ),
      );
      await db.patientDao.upsertPatient(
        PatientsCompanion.insert(
          patientId: 'p1',
          userId: 'uid1',
          displayName: 'John Doe',
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    test('upsert and retrieve reading', () async {
      final now = DateTime.now();
      await db.readingDao.upsertReading(
        ReadingsCompanion.insert(
          readingId: 'r1',
          patientId: 'p1',
          systolic: 130,
          diastolic: 85,
          takenAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final reading = await db.readingDao.getById('r1');
      expect(reading, isNotNull);
      expect(reading!.systolic, 130);
      expect(reading.diastolic, 85);
    });

    test('date range filter', () async {
      final base = DateTime(2025, 1, 15);
      for (var i = 0; i < 5; i++) {
        final day = base.add(Duration(days: i));
        await db.readingDao.upsertReading(
          ReadingsCompanion.insert(
            readingId: 'r$i',
            patientId: 'p1',
            systolic: 120 + i * 5,
            diastolic: 80 + i * 2,
            takenAt: day,
            createdAt: day,
            updatedAt: day,
          ),
        );
      }

      final filtered = await db.readingDao.getByPatientId(
        'p1',
        from: DateTime(2025, 1, 16),
        to: DateTime(2025, 1, 18),
      );
      expect(filtered, hasLength(3));
    });

    test('count readings', () async {
      final now = DateTime.now();
      for (var i = 0; i < 3; i++) {
        await db.readingDao.upsertReading(
          ReadingsCompanion.insert(
            readingId: 'r$i',
            patientId: 'p1',
            systolic: 120,
            diastolic: 80,
            takenAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      final count = await db.readingDao.countByPatientId('p1');
      expect(count, 3);
    });

    test('delete reading', () async {
      final now = DateTime.now();
      await db.readingDao.upsertReading(
        ReadingsCompanion.insert(
          readingId: 'r1',
          patientId: 'p1',
          systolic: 130,
          diastolic: 85,
          takenAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await db.readingDao.deleteReading('r1');
      final reading = await db.readingDao.getById('r1');
      expect(reading, isNull);
    });
  });
}
