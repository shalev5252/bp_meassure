import 'package:bp_monitor/domain/entities/reading_entity.dart';
import 'package:bp_monitor/domain/services/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

ReadingEntity _reading({
  required int sys,
  required int dia,
  int? pulse,
  DateTime? takenAt,
}) {
  final now = takenAt ?? DateTime.now();
  return ReadingEntity(
    readingId: 'r${sys}_$dia',
    patientId: 'p1',
    systolic: sys,
    diastolic: dia,
    pulse: pulse,
    takenAt: now,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  const service = AnalyticsService();

  group('AnalyticsService', () {
    test('returns null for fewer than 3 readings', () {
      final readings = [_reading(sys: 120, dia: 80)];
      expect(service.compute(readings), isNull);
      expect(service.hasEnoughReadings(readings), false);
    });

    test('computes averages correctly', () {
      final readings = [
        _reading(sys: 120, dia: 80, pulse: 70),
        _reading(sys: 130, dia: 85, pulse: 75),
        _reading(sys: 140, dia: 90, pulse: 80),
      ];
      final result = service.compute(readings)!;
      expect(result.avgSystolic, closeTo(130, 0.1));
      expect(result.avgDiastolic, closeTo(85, 0.1));
      expect(result.avgPulse, closeTo(75, 0.1));
      expect(result.readingCount, 3);
    });

    test('computes std dev correctly', () {
      final readings = [
        _reading(sys: 120, dia: 80),
        _reading(sys: 130, dia: 80),
        _reading(sys: 140, dia: 80),
      ];
      final result = service.compute(readings)!;
      // std dev of [120, 130, 140] = sqrt(200/3) ≈ 8.16
      expect(result.stdDevSystolic, closeTo(8.16, 0.1));
      expect(result.stdDevDiastolic, closeTo(0, 0.01));
    });

    test('computes threshold percentage', () {
      final readings = [
        _reading(sys: 120, dia: 80), // normal
        _reading(sys: 145, dia: 92), // above 140/90
        _reading(sys: 160, dia: 100), // above 140/90
        _reading(sys: 130, dia: 85), // normal
      ];
      final result = service.compute(readings)!;
      expect(result.pctAboveThreshold, closeTo(50.0, 0.1));
    });

    test('computes positive trend slope for increasing values', () {
      final base = DateTime(2025, 1, 1);
      final readings = [
        _reading(sys: 120, dia: 80, takenAt: base),
        _reading(
          sys: 130,
          dia: 85,
          takenAt: base.add(const Duration(days: 1)),
        ),
        _reading(
          sys: 140,
          dia: 90,
          takenAt: base.add(const Duration(days: 2)),
        ),
      ];
      final result = service.compute(readings)!;
      expect(result.trendSlopeSystolic, greaterThan(0));
      expect(result.trendSlopeDiastolic, greaterThan(0));
    });

    test('avgPulse is null when no pulse data', () {
      final readings = [
        _reading(sys: 120, dia: 80),
        _reading(sys: 130, dia: 85),
        _reading(sys: 140, dia: 90),
      ];
      final result = service.compute(readings)!;
      expect(result.avgPulse, isNull);
    });
  });
}
