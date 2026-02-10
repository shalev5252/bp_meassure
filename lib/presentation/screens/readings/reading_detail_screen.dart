import 'dart:async';

import 'package:bp_monitor/core/constants.dart';
import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/widgets.dart';
import 'package:bp_monitor/domain/entities/bp_category.dart';
import 'package:bp_monitor/domain/entities/reading_entity.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:bp_monitor/presentation/theme/app_theme.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ReadingDetailScreen extends ConsumerStatefulWidget {
  const ReadingDetailScreen({super.key, required this.readingId});

  final String readingId;

  @override
  ConsumerState<ReadingDetailScreen> createState() =>
      _ReadingDetailScreenState();
}

class _ReadingDetailScreenState extends ConsumerState<ReadingDetailScreen> {
  ReadingEntity? _reading;
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

    final result =
        await ref.read(readingRepositoryProvider).getById(widget.readingId);

    if (!mounted) return;

    switch (result) {
      case Success(:final value):
        setState(() {
          _reading = value;
          _loading = false;
        });
      case Err(:final failure):
        setState(() {
          _error = failure.message;
          _loading = false;
        });
    }
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.delete),
        content: Text(l.readingDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result =
        await ref.read(readingRepositoryProvider).delete(widget.readingId);

    if (!mounted) return;

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.readingDeleted)),
        );
        context.pop(true);
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.readings)),
        body: LoadingView(message: l.loading),
      );
    }

    if (_error != null || _reading == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.readings)),
        body: ErrorView(message: _error ?? 'Not found', onRetry: _loadData),
      );
    }

    final r = _reading!;
    final category = r.bpCategory;
    final color = AppTheme.bpCategoryColor(category);
    final dateStr = DateFormat.yMMMd().add_jm().format(r.takenAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.readings),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await context.push<bool>(
                '/reading/${r.readingId}/edit',
                extra: r,
              );
              if (result == true) unawaited(_loadData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.horizontalPadding,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BP values card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ValueColumn(label: 'SYS', value: r.systolic.toString()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('/',
                              style: Theme.of(context).textTheme.headlineMedium),
                        ),
                        _ValueColumn(label: 'DIA', value: r.diastolic.toString()),
                        if (r.pulse != null) ...[
                          const SizedBox(width: 24),
                          _ValueColumn(label: 'BPM', value: r.pulse.toString()),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color),
                      ),
                      child: Text(
                        _categoryLabel(category, l),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Safety warnings
            if (r.isBpRedFlag) ...[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l.safetyBpRedFlag)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (r.isPulseWarning) ...[
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l.safetyPulseWarning)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(label: l.takenAt, value: dateStr),
                    if (r.measurementQuality != null)
                      _DetailRow(
                        label: l.quality,
                        value: _qualityLabel(r.measurementQuality!, l),
                      ),
                    if (r.contextTags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(l.contextTags,
                          style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: r.contextTags
                            .map((t) => Chip(label: Text(_tagLabel(t, l))))
                            .toList(),
                      ),
                    ],
                    if (r.notes != null && r.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(l.notes,
                          style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Text(r.notes!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueColumn extends StatelessWidget {
  const _ValueColumn({required this.label, required this.value});

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
              .headlineLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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

String _categoryLabel(BpCategory c, AppLocalizations l) => switch (c) {
      BpCategory.normal => l.categoryNormal,
      BpCategory.highNormal => l.categoryHighNormal,
      BpCategory.grade1 => l.categoryGrade1,
      BpCategory.grade2 => l.categoryGrade2,
      BpCategory.grade3 => l.categoryGrade3,
      BpCategory.crisis => l.categoryCrisis,
    };

String _qualityLabel(MeasurementQuality q, AppLocalizations l) => switch (q) {
      MeasurementQuality.valid => l.qualityValid,
      MeasurementQuality.invalid => l.qualityInvalid,
      MeasurementQuality.unsure => l.qualityUnsure,
    };

String _tagLabel(ContextTag tag, AppLocalizations l) => switch (tag) {
      ContextTag.morning => l.tagMorning,
      ContextTag.evening => l.tagEvening,
      ContextTag.afterRest => l.tagAfterRest,
      ContextTag.afterExercise => l.tagAfterExercise,
      ContextTag.afterMeal => l.tagAfterMeal,
      ContextTag.stressed => l.tagStressed,
      ContextTag.atDoctor => l.tagAtDoctor,
    };
