import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/widgets.dart';
import 'package:bp_monitor/domain/entities/bp_category.dart';
import 'package:bp_monitor/domain/entities/reading_entity.dart';
import 'package:bp_monitor/domain/services/analytics_service.dart';
import 'package:bp_monitor/infra/connectivity_service.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:bp_monitor/presentation/theme/app_theme.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<ReadingEntity>? _readings;
  bool _loading = true;
  String? _error;

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

    final readingsResult =
        await ref.read(readingRepositoryProvider).getByPatientId(
              patient.patientId,
            );

    if (!mounted) return;

    switch (readingsResult) {
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.home)),
        body: LoadingView(message: l.loading),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.home)),
        body: ErrorView(message: _error!, onRetry: _loadData),
      );
    }

    final readings = _readings ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(l.home)),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.horizontalPadding,
            vertical: 16,
          ),
          children: [
            if (readings.isEmpty)
              EmptyView(
                message: l.noReadingsYet,
                icon: Icons.monitor_heart_outlined,
                action: FilledButton.icon(
                  onPressed: () => context.push('/new-reading'),
                  icon: const Icon(Icons.add),
                  label: Text(l.newReading),
                ),
              )
            else ...[
              _LatestReadingCard(reading: readings.first, l: l),
              const SizedBox(height: 16),
              _SevenDaySummary(readings: readings, l: l),
            ],
            const SizedBox(height: 24),
            _QuickActions(l: l),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Latest reading card
// ---------------------------------------------------------------------------

class _LatestReadingCard extends StatelessWidget {
  const _LatestReadingCard({required this.reading, required this.l});

  final ReadingEntity reading;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final category = reading.bpCategory;
    final color = AppTheme.bpCategoryColor(category);
    final dateStr = DateFormat.yMMMd().add_jm().format(reading.takenAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.latestReading,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _BpValue(
                  label: 'SYS',
                  value: reading.systolic.toString(),
                ),
                const SizedBox(width: 8),
                Text('/', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(width: 8),
                _BpValue(
                  label: 'DIA',
                  value: reading.diastolic.toString(),
                ),
                if (reading.pulse != null) ...[
                  const SizedBox(width: 16),
                  _BpValue(
                    label: 'BPM',
                    value: reading.pulse.toString(),
                  ),
                ],
                const Spacer(),
                _CategoryBadge(category: category, color: color, l: l),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _BpValue extends StatelessWidget {
  const _BpValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({
    required this.category,
    required this.color,
    required this.l,
  });

  final BpCategory category;
  final Color color;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        _categoryLabel(category, l),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

String _categoryLabel(BpCategory c, AppLocalizations l) => switch (c) {
      BpCategory.normal => l.categoryNormal,
      BpCategory.highNormal => l.categoryHighNormal,
      BpCategory.grade1 => l.categoryGrade1,
      BpCategory.grade2 => l.categoryGrade2,
      BpCategory.grade3 => l.categoryGrade3,
      BpCategory.crisis => l.categoryCrisis,
    };

// ---------------------------------------------------------------------------
// 7-day summary
// ---------------------------------------------------------------------------

class _SevenDaySummary extends StatelessWidget {
  const _SevenDaySummary({required this.readings, required this.l});

  final List<ReadingEntity> readings;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final recent =
        readings.where((r) => r.takenAt.isAfter(sevenDaysAgo)).toList();

    const analytics = AnalyticsService();

    if (!analytics.hasEnoughReadings(recent)) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.sevenDaySummary,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l.analyticsAddMore,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final result = analytics.compute(recent)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.sevenDaySummary,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            _MetricRow(
              label: l.analyticsAvgSys,
              value: result.avgSystolic.round().toString(),
            ),
            _MetricRow(
              label: l.analyticsAvgDia,
              value: result.avgDiastolic.round().toString(),
            ),
            if (result.avgPulse != null)
              _MetricRow(
                label: l.analyticsAvgPulse,
                value: result.avgPulse!.round().toString(),
              ),
            _MetricRow(
              label: l.analyticsPctAbove,
              value: '${result.pctAboveThreshold.round()}%',
            ),
            _MetricRow(
              label: l.readings,
              value: result.readingCount.toString(),
            ),
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
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions
// ---------------------------------------------------------------------------

class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline =
        ref.watch(connectivityProvider).valueOrNull ?? false;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ActionChip(
          avatar: const Icon(Icons.add),
          label: Text(l.newReading),
          onPressed: () => context.push('/new-reading'),
        ),
        ActionChip(
          avatar: const Icon(Icons.history),
          label: Text(l.viewHistory),
          onPressed: () => context.push('/readings'),
        ),
        ActionChip(
          avatar: const Icon(Icons.bar_chart),
          label: Text(l.analytics),
          onPressed: () => context.push('/analytics'),
        ),
        if (isOnline)
          ActionChip(
            avatar: const Icon(Icons.auto_awesome),
            label: Text(l.aiInsights),
            onPressed: () => context.push('/ai'),
          ),
        ActionChip(
          avatar: const Icon(Icons.person),
          label: Text(l.profile),
          onPressed: () => context.push('/profile'),
        ),
        ActionChip(
          avatar: const Icon(Icons.download),
          label: Text(l.exportTitle),
          onPressed: () => context.push('/export'),
        ),
        ActionChip(
          avatar: const Icon(Icons.settings),
          label: Text(l.settings),
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }
}
