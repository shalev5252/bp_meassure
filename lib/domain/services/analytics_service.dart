import 'dart:math';

import 'package:bp_monitor/core/constants.dart';
import 'package:bp_monitor/domain/entities/reading_entity.dart';

/// Computed analytics for a set of readings.
class AnalyticsResult {
  const AnalyticsResult({
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.avgPulse,
    required this.stdDevSystolic,
    required this.stdDevDiastolic,
    required this.trendSlopeSystolic,
    required this.trendSlopeDiastolic,
    required this.pctAboveThreshold,
    required this.readingCount,
  });

  final double avgSystolic;
  final double avgDiastolic;
  final double? avgPulse;
  final double stdDevSystolic;
  final double stdDevDiastolic;
  final double trendSlopeSystolic;
  final double trendSlopeDiastolic;
  /// Percentage of readings above 140/90 threshold.
  final double pctAboveThreshold;
  final int readingCount;
}

/// Computes analytics from a list of readings.
class AnalyticsService {
  const AnalyticsService();

  /// Whether the reading list has enough data for analytics.
  bool hasEnoughReadings(List<ReadingEntity> readings) =>
      readings.length >= kMinReadingsForAnalytics;

  /// Compute analytics for the given readings.
  ///
  /// Returns null if there are fewer than [kMinReadingsForAnalytics] readings.
  AnalyticsResult? compute(List<ReadingEntity> readings) {
    if (!hasEnoughReadings(readings)) return null;

    final sysList = readings.map((r) => r.systolic.toDouble()).toList();
    final diaList = readings.map((r) => r.diastolic.toDouble()).toList();
    final pulseList = readings
        .where((r) => r.pulse != null)
        .map((r) => r.pulse!.toDouble())
        .toList();

    final avgSys = _mean(sysList);
    final avgDia = _mean(diaList);
    final avgPulse = pulseList.isNotEmpty ? _mean(pulseList) : null;

    final aboveCount = readings
        .where((r) => r.systolic >= 140 || r.diastolic >= 90)
        .length;
    final pctAbove = (aboveCount / readings.length) * 100;

    // Sort by time for trend calculation.
    final sorted = List<ReadingEntity>.from(readings)
      ..sort((a, b) => a.takenAt.compareTo(b.takenAt));
    final sortedSys = sorted.map((r) => r.systolic.toDouble()).toList();
    final sortedDia = sorted.map((r) => r.diastolic.toDouble()).toList();

    return AnalyticsResult(
      avgSystolic: avgSys,
      avgDiastolic: avgDia,
      avgPulse: avgPulse,
      stdDevSystolic: _stdDev(sysList, avgSys),
      stdDevDiastolic: _stdDev(diaList, avgDia),
      trendSlopeSystolic: _linearSlope(sortedSys),
      trendSlopeDiastolic: _linearSlope(sortedDia),
      pctAboveThreshold: pctAbove,
      readingCount: readings.length,
    );
  }

  double _mean(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;

  double _stdDev(List<double> values, double mean) {
    final sumSqDiff =
        values.fold<double>(0, (sum, v) => sum + (v - mean) * (v - mean));
    return sqrt(sumSqDiff / values.length);
  }

  /// Simple linear regression slope (index-based x-axis).
  double _linearSlope(List<double> values) {
    if (values.length < 2) return 0;
    final n = values.length;
    final xMean = (n - 1) / 2.0;
    final yMean = _mean(values);

    var numerator = 0.0;
    var denominator = 0.0;
    for (var i = 0; i < n; i++) {
      final dx = i - xMean;
      numerator += dx * (values[i] - yMean);
      denominator += dx * dx;
    }
    if (denominator == 0) return 0;
    return numerator / denominator;
  }
}
