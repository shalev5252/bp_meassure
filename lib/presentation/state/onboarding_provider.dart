import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/data/database_provider.dart';
import 'package:bp_monitor/data/repositories/medication_repository_impl.dart';
import 'package:bp_monitor/data/repositories/patient_repository_impl.dart';
import 'package:bp_monitor/data/repositories/reading_repository_impl.dart';
import 'package:bp_monitor/data/repositories/risk_factor_repository_impl.dart';
import 'package:bp_monitor/data/repositories/user_repository_impl.dart';
import 'package:bp_monitor/domain/repositories/medication_repository.dart';
import 'package:bp_monitor/domain/repositories/patient_repository.dart';
import 'package:bp_monitor/domain/repositories/reading_repository.dart';
import 'package:bp_monitor/domain/repositories/risk_factor_repository.dart';
import 'package:bp_monitor/domain/repositories/user_repository.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Repository providers (shared across the app, not just onboarding)
// ---------------------------------------------------------------------------

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return UserRepositoryImpl(userDao: db.userDao);
});

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PatientRepositoryImpl(patientDao: db.patientDao);
});

final riskFactorRepositoryProvider = Provider<RiskFactorRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RiskFactorRepositoryImpl(riskFactorDao: db.riskFactorDao);
});

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MedicationRepositoryImpl(medicationDao: db.medicationDao);
});

final readingRepositoryProvider = Provider<ReadingRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ReadingRepositoryImpl(readingDao: db.readingDao);
});

// ---------------------------------------------------------------------------
// Onboarding completion check
// ---------------------------------------------------------------------------

/// Whether the current user has completed onboarding (i.e. has a patient profile).
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) return false;

  final repo = ref.watch(patientRepositoryProvider);
  final result = await repo.getByUserId(user.uid);
  return switch (result) {
    Success(:final value) => value != null,
    Err() => false,
  };
});
