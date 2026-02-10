import 'dart:io';

import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/domain/entities/patient_entity.dart';
import 'package:bp_monitor/domain/entities/reading_entity.dart';
import 'package:bp_monitor/domain/services/export_service.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  DateTime? _from;
  DateTime? _to;
  bool _exporting = false;

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
  }

  Future<(List<ReadingEntity>, PatientEntity)?> _loadReadings() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return null;

    final patientResult =
        await ref.read(patientRepositoryProvider).getByUserId(user.uid);
    final patient = switch (patientResult) {
      Success(:final value) => value,
      Err() => null,
    };
    if (patient == null) return null;

    final result = await ref.read(readingRepositoryProvider).getByPatientId(
          patient.patientId,
          from: _from,
          to: _to,
        );

    return switch (result) {
      Success(:final value) => (value, patient),
      Err() => null,
    };
  }

  Future<void> _exportCsv() async {
    setState(() => _exporting = true);

    final data = await _loadReadings();
    if (data == null || !mounted) {
      setState(() => _exporting = false);
      return;
    }

    final (readings, _) = data;
    const exportService = ExportService();
    final csv = exportService.generateCsv(readings);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/bp_readings.csv');
    await file.writeAsString(csv);

    setState(() => _exporting = false);

    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);

    final data = await _loadReadings();
    if (data == null || !mounted) {
      setState(() => _exporting = false);
      return;
    }

    final (readings, patient) = data;
    const exportService = ExportService();
    final bytes = await exportService.generatePdf(
      patient: patient,
      readings: readings,
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/bp_report.pdf');
    await file.writeAsBytes(bytes);

    setState(() => _exporting = false);

    await Share.shareXFiles([XFile(file.path)]);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.exportTitle)),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.horizontalPadding,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date range
            Card(
              child: ListTile(
                leading: const Icon(Icons.date_range),
                title: Text(l.exportDateRange),
                subtitle: _from != null && _to != null
                    ? Text(
                        '${DateFormat.yMMMd().format(_from!)} – ${DateFormat.yMMMd().format(_to!)}')
                    : Text(l.filterAll),
                trailing: _from != null
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                            setState(() { _from = null; _to = null; }),
                      )
                    : null,
                onTap: _pickDateRange,
              ),
            ),
            const SizedBox(height: 24),

            if (_exporting)
              const Center(child: CircularProgressIndicator())
            else ...[
              FilledButton.icon(
                onPressed: _exportPdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(l.exportPdf),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _exportCsv,
                icon: const Icon(Icons.table_chart),
                label: Text(l.exportCsv),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
