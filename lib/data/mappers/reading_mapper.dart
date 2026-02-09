import 'dart:convert';

import 'package:bp_monitor/core/constants.dart';
import 'package:bp_monitor/data/database.dart';
import 'package:bp_monitor/domain/entities/reading_entity.dart';
import 'package:drift/drift.dart';

/// Maps between [Reading] (Drift row) and [ReadingEntity] (domain).
class ReadingMapper {
  const ReadingMapper();

  ReadingEntity fromRow(Reading row) => ReadingEntity(
        readingId: row.readingId,
        patientId: row.patientId,
        systolic: row.systolic,
        diastolic: row.diastolic,
        pulse: row.pulse,
        takenAt: row.takenAt,
        contextTags: _decodeContextTags(row.contextTags),
        measurementQuality: _decodeQuality(row.measurementQuality),
        notes: row.notes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  ReadingsCompanion toCompanion(ReadingEntity entity) => ReadingsCompanion(
        readingId: Value(entity.readingId),
        patientId: Value(entity.patientId),
        systolic: Value(entity.systolic),
        diastolic: Value(entity.diastolic),
        pulse: Value(entity.pulse),
        takenAt: Value(entity.takenAt),
        contextTags: Value(_encodeContextTags(entity.contextTags)),
        measurementQuality: Value(entity.measurementQuality?.name),
        notes: Value(entity.notes),
        createdAt: Value(entity.createdAt),
        updatedAt: Value(entity.updatedAt),
      );

  List<ContextTag> _decodeContextTags(String? json) {
    if (json == null || json.isEmpty) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) {
          try {
            return ContextTag.values.byName(e as String);
          } catch (_) {
            return null;
          }
        })
        .whereType<ContextTag>()
        .toList();
  }

  String? _encodeContextTags(List<ContextTag> tags) {
    if (tags.isEmpty) return null;
    return jsonEncode(tags.map((t) => t.name).toList());
  }

  MeasurementQuality? _decodeQuality(String? value) {
    if (value == null) return null;
    try {
      return MeasurementQuality.values.byName(value);
    } catch (_) {
      return null;
    }
  }
}
