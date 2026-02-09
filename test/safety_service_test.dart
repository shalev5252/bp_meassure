import 'package:bp_monitor/domain/entities/reading_entity.dart';
import 'package:bp_monitor/domain/services/safety_service.dart';
import 'package:flutter_test/flutter_test.dart';

ReadingEntity _reading({
  required int sys,
  required int dia,
  int? pulse,
}) {
  final now = DateTime.now();
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
  const service = SafetyService();

  group('SafetyService - BP red flags', () {
    test('no red flag for normal reading', () {
      final result = service.check(_reading(sys: 120, dia: 80));
      expect(result.hasBpRedFlag, false);
    });

    test('red flag when SYS >= 180', () {
      final result = service.check(_reading(sys: 180, dia: 90));
      expect(result.hasBpRedFlag, true);
    });

    test('red flag when DIA >= 120', () {
      final result = service.check(_reading(sys: 150, dia: 120));
      expect(result.hasBpRedFlag, true);
    });

    test('red flag when both SYS >= 180 and DIA >= 120', () {
      final result = service.check(_reading(sys: 200, dia: 130));
      expect(result.hasBpRedFlag, true);
    });

    test('no red flag at 179/119 (just below threshold)', () {
      final result = service.check(_reading(sys: 179, dia: 119));
      expect(result.hasBpRedFlag, false);
    });
  });

  group('SafetyService - Pulse warnings', () {
    test('no warning for normal pulse', () {
      final result = service.check(_reading(sys: 120, dia: 80, pulse: 72));
      expect(result.hasPulseWarning, false);
    });

    test('warning when pulse < 50', () {
      final result = service.check(_reading(sys: 120, dia: 80, pulse: 45));
      expect(result.hasPulseWarning, true);
    });

    test('warning when pulse > 100', () {
      final result = service.check(_reading(sys: 120, dia: 80, pulse: 110));
      expect(result.hasPulseWarning, true);
    });

    test('no warning at boundary pulse 50', () {
      final result = service.check(_reading(sys: 120, dia: 80, pulse: 50));
      expect(result.hasPulseWarning, false);
    });

    test('no warning at boundary pulse 100', () {
      final result = service.check(_reading(sys: 120, dia: 80, pulse: 100));
      expect(result.hasPulseWarning, false);
    });

    test('no pulse warning when pulse is null', () {
      final result = service.check(_reading(sys: 120, dia: 80));
      expect(result.hasPulseWarning, false);
    });
  });

  group('SafetyService - hasActiveRedFlag', () {
    test('returns true when any reading has red flag', () {
      final readings = [
        _reading(sys: 120, dia: 80),
        _reading(sys: 185, dia: 90),
        _reading(sys: 130, dia: 85),
      ];
      expect(service.hasActiveRedFlag(readings), true);
    });

    test('returns false when no reading has red flag', () {
      final readings = [
        _reading(sys: 120, dia: 80),
        _reading(sys: 145, dia: 95),
      ];
      expect(service.hasActiveRedFlag(readings), false);
    });
  });

  group('SafetyService - combined alerts', () {
    test('both BP red flag and pulse warning', () {
      final result =
          service.check(_reading(sys: 190, dia: 125, pulse: 110));
      expect(result.hasBpRedFlag, true);
      expect(result.hasPulseWarning, true);
      expect(result.hasAnyAlert, true);
    });

    test('no alerts', () {
      final result = service.check(_reading(sys: 120, dia: 80, pulse: 72));
      expect(result.hasAnyAlert, false);
    });
  });
}
