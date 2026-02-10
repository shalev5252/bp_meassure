import 'dart:async';

import 'package:bp_monitor/core/constants.dart';
import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/widgets.dart';
import 'package:bp_monitor/domain/entities/reading_entity.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:bp_monitor/presentation/theme/app_theme.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ReadingHistoryScreen extends ConsumerStatefulWidget {
  const ReadingHistoryScreen({super.key});

  @override
  ConsumerState<ReadingHistoryScreen> createState() =>
      _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends ConsumerState<ReadingHistoryScreen> {
  List<ReadingEntity>? _readings;
  bool _loading = true;
  String? _error;
  MeasurementQuality? _qualityFilter;

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
          qualityFilter: _qualityFilter,
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.readings),
        actions: [
          PopupMenuButton<MeasurementQuality?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) {
              setState(() => _qualityFilter = v);
              _loadData();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: null, child: Text(l.filterAll)),
              PopupMenuItem(
                value: MeasurementQuality.valid,
                child: Text(l.filterValid),
              ),
              PopupMenuItem(
                value: MeasurementQuality.invalid,
                child: Text(l.filterInvalid),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push<bool>('/new-reading');
          if (result == true) unawaited(_loadData());
        },
        child: const Icon(Icons.add),
      ),
      body: _buildBody(l),
    );
  }

  Widget _buildBody(AppLocalizations l) {
    if (_loading) return LoadingView(message: l.loading);
    if (_error != null) return ErrorView(message: _error!, onRetry: _loadData);

    final readings = _readings ?? [];
    if (readings.isEmpty) {
      return EmptyView(
        message: l.noReadingsYet,
        icon: Icons.monitor_heart_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.horizontalPadding,
          vertical: 8,
        ),
        itemCount: readings.length,
        itemBuilder: (context, index) {
          final r = readings[index];
          return _ReadingTile(
            reading: r,
            onTap: () async {
              final result = await context.push<bool>(
                '/reading/${r.readingId}',
              );
              if (result == true) unawaited(_loadData());
            },
          );
        },
      ),
    );
  }
}

class _ReadingTile extends StatelessWidget {
  const _ReadingTile({required this.reading, required this.onTap});

  final ReadingEntity reading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = reading.bpCategory;
    final color = AppTheme.bpCategoryColor(category);
    final dateStr = DateFormat.yMMMd().add_jm().format(reading.takenAt);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.favorite, color: color, size: 20),
        ),
        title: Text(
          '${reading.systolic}/${reading.diastolic}'
          '${reading.pulse != null ? '  ${reading.pulse} bpm' : ''}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(dateStr),
        trailing: reading.isPulseWarning
            ? const Icon(Icons.info_outline, color: Colors.orange, size: 20)
            : null,
      ),
    );
  }
}
