import 'dart:async';

import 'package:bp_monitor/core/constants.dart';
import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/widgets.dart';
import 'package:bp_monitor/domain/entities/reading_entity.dart';
import 'package:bp_monitor/domain/services/analytics_service.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  List<ReadingEntity>? _readings;
  bool _loading = true;
  String? _error;
  bool _is7Days = true;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final patientResult =
        await ref.read(patientRepositoryProvider).getByUserId(user.uid);
    final patient = switch (patientResult) {
      Success(:final value) => value,
      Err() => null,
    };
    if (patient == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final result = await ref.read(readingRepositoryProvider).getByPatientId(
          patient.patientId,
          from: _from,
          to: _to,
        );

    if (!mounted) return;

    switch (result) {
      case Success(:final value):
        setState(() {
          _readings = value;
          _loading = false;
        });
      case Err(:final failure):
        setState(() {
          _error = failure.message;
          _loading = false;
        });
    }
  }

  List<ReadingEntity> _filteredReadings() {
    final all = _readings ?? [];
    if (_from != null || _to != null) return all;
    final now = DateTime.now();
    final cutoff =
        now.subtract(Duration(days: _is7Days ? 7 : 30));
    return all.where((r) => r.takenAt.isAfter(cutoff)).toList();
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _from != null && _to != null
          ? DateTimeRange(start: _from!, end: _to!)
          : null,
    );
    if (range == null) return;
    setState(() {
      _from = range.start;
      _to = range.end.add(const Duration(days: 1));
    });
    unawaited(_loadData());
  }

  void _clearDateRange() {
    setState(() {
      _from = null;
      _to = null;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.analyticsTitle)),
        body: LoadingView(message: l.loading),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.analyticsTitle)),
        body: ErrorView(message: _error!, onRetry: _loadData),
      );
    }

    final filtered = _filteredReadings();
    const analytics = AnalyticsService();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.analyticsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.horizontalPadding,
            vertical: 16,
          ),
          children: [
            // Date range controls
            if (_from != null && _to != null) ...[
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${DateFormat.yMMMd().format(_from!)} – ${DateFormat.yMMMd().format(_to!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _clearDateRange,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ] else ...[
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: true, label: Text(l.analytics7d)),
                  ButtonSegment(value: false, label: Text(l.analytics30d)),
                ],
                selected: {_is7Days},
                onSelectionChanged: (v) =>
                    setState(() => _is7Days = v.first),
              ),
              const SizedBox(height: 16),
            ],

            if (!analytics.hasEnoughReadings(filtered))
              EmptyView(
                message: l.analyticsAddMore,
                icon: Icons.bar_chart_outlined,
              )
            else ...[
              _buildMetrics(analytics.compute(filtered)!, l),
              const SizedBox(height: 16),
              _buildChart(filtered, l),
              const SizedBox(height: 16),
              _buildMorningEvening(filtered, l),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetrics(AnalyticsResult result, AppLocalizations l) {
    final trendLabel = result.trendSlopeSystolic > 0.5
        ? l.trendUp
        : result.trendSlopeSystolic < -0.5
            ? l.trendDown
            : l.trendStable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MetricRow(label: l.analyticsAvgSys,
                value: result.avgSystolic.round().toString()),
            _MetricRow(label: l.analyticsAvgDia,
                value: result.avgDiastolic.round().toString()),
            if (result.avgPulse != null)
              _MetricRow(label: l.analyticsAvgPulse,
                  value: result.avgPulse!.round().toString()),
            _MetricRow(label: l.analyticsStdDev,
                value:
                    '${result.stdDevSystolic.toStringAsFixed(1)}/${result.stdDevDiastolic.toStringAsFixed(1)}'),
            _MetricRow(label: l.analyticsTrend, value: trendLabel),
            _MetricRow(
                label: l.analyticsPctAbove,
                value: '${result.pctAboveThreshold.round()}%'),
            _MetricRow(label: l.readings,
                value: result.readingCount.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<ReadingEntity> readings, AppLocalizations l) {
    final sorted = List<ReadingEntity>.from(readings)
      ..sort((a, b) => a.takenAt.compareTo(b.takenAt));

    if (sorted.isEmpty) return const SizedBox.shrink();

    // Find min/max for scaling
    int minVal = sorted.first.diastolic;
    int maxVal = sorted.first.systolic;
    for (final r in sorted) {
      if (r.diastolic < minVal) minVal = r.diastolic;
      if (r.systolic > maxVal) maxVal = r.systolic;
    }
    minVal = (minVal - 10).clamp(0, 300);
    maxVal = (maxVal + 10).clamp(0, 300);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.analyticsTrend,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: CustomPaint(
                size: Size.infinite,
                painter: _BpChartPainter(
                  readings: sorted,
                  minVal: minVal,
                  maxVal: maxVal,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: Colors.red.shade400, label: 'SYS'),
                const SizedBox(width: 16),
                _LegendDot(color: Colors.blue.shade400, label: 'DIA'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMorningEvening(
      List<ReadingEntity> readings, AppLocalizations l) {
    final morning = readings
        .where((r) => r.contextTags.contains(ContextTag.morning))
        .toList();
    final evening = readings
        .where((r) => r.contextTags.contains(ContextTag.evening))
        .toList();

    if (morning.isEmpty && evening.isEmpty) return const SizedBox.shrink();

    const svc = AnalyticsService();

    Widget todRow(List<ReadingEntity> data, String label) {
      if (data.isEmpty) return const SizedBox.shrink();
      if (data.length >= kMinReadingsForAnalytics) {
        final result = svc.compute(data)!;
        return _MetricRow(
          label: label,
          value:
              '${result.avgSystolic.round()}/${result.avgDiastolic.round()}',
        );
      }
      return _MetricRow(label: label, value: '< 3 readings');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l.tagMorning} vs ${l.tagEvening}',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            todRow(morning, l.morningAvg),
            todRow(evening, l.eveningAvg),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _BpChartPainter extends CustomPainter {
  _BpChartPainter({
    required this.readings,
    required this.minVal,
    required this.maxVal,
  });

  final List<ReadingEntity> readings;
  final int minVal;
  final int maxVal;

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    final sysPaint = Paint()
      ..color = Colors.red.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final diaPaint = Paint()
      ..color = Colors.blue.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final range = (maxVal - minVal).toDouble();
    if (range == 0) return;

    final sysPath = Path();
    final diaPath = Path();

    for (var i = 0; i < readings.length; i++) {
      final x = readings.length == 1
          ? size.width / 2
          : (i / (readings.length - 1)) * size.width;
      final sysY = size.height -
          ((readings[i].systolic - minVal) / range) * size.height;
      final diaY = size.height -
          ((readings[i].diastolic - minVal) / range) * size.height;

      if (i == 0) {
        sysPath.moveTo(x, sysY);
        diaPath.moveTo(x, diaY);
      } else {
        sysPath.lineTo(x, sysY);
        diaPath.lineTo(x, diaY);
      }

      // Draw dots
      canvas.drawCircle(
          Offset(x, sysY), 3, sysPaint..style = PaintingStyle.fill);
      canvas.drawCircle(
          Offset(x, diaY), 3, diaPaint..style = PaintingStyle.fill);
    }

    sysPaint.style = PaintingStyle.stroke;
    diaPaint.style = PaintingStyle.stroke;
    canvas.drawPath(sysPath, sysPaint);
    canvas.drawPath(diaPath, diaPaint);

    // Draw 140/90 threshold line
    final thresholdPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final y140 = size.height - ((140 - minVal) / range) * size.height;
    if (y140 >= 0 && y140 <= size.height) {
      canvas.drawLine(Offset(0, y140), Offset(size.width, y140), thresholdPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BpChartPainter oldDelegate) => true;
}
