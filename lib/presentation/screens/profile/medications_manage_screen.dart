import 'dart:async';

import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/widgets.dart';
import 'package:bp_monitor/domain/entities/medication_entity.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicationsManageScreen extends ConsumerStatefulWidget {
  const MedicationsManageScreen({super.key});

  @override
  ConsumerState<MedicationsManageScreen> createState() =>
      _MedicationsManageScreenState();
}

class _MedicationsManageScreenState
    extends ConsumerState<MedicationsManageScreen> {
  List<MedicationEntity>? _medications;
  bool _loading = true;
  String? _error;
  String? _patientId;

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

    _patientId = patient.patientId;

    final result = await ref
        .read(medicationRepositoryProvider)
        .getByPatientId(patient.patientId);

    if (!mounted) return;

    switch (result) {
      case Success(:final value):
        setState(() {
          _medications = value;
          _loading = false;
        });
      case Err(:final failure):
        setState(() {
          _error = failure.message;
          _loading = false;
        });
    }
  }

  Future<void> _deleteMedication(String id) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.delete),
        content: Text(l.confirm),
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

    if (confirmed != true) return;

    await ref.read(medicationRepositoryProvider).delete(id);
    unawaited(_loadData());
  }

  void _showMedicationForm([MedicationEntity? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _MedicationFormSheet(
        patientId: _patientId!,
        existing: existing,
        onSaved: () {
          Navigator.of(ctx).pop();
          _loadData();
        },
        repo: ref.read(medicationRepositoryProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.medications)),
        body: LoadingView(message: l.loading),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.medications)),
        body: ErrorView(message: _error!, onRetry: _loadData),
      );
    }

    final meds = _medications ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(l.medications)),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMedicationForm,
        child: const Icon(Icons.add),
      ),
      body: meds.isEmpty
          ? EmptyView(
              message: l.medications,
              icon: Icons.medication_outlined,
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.horizontalPadding,
                  vertical: 8,
                ),
                itemCount: meds.length,
                itemBuilder: (context, index) {
                  final m = meds[index];
                  return Card(
                    child: ListTile(
                      title: Text(m.name),
                      subtitle: Text([
                        if (m.doseText != null) m.doseText!,
                        if (m.frequencyText != null) m.frequencyText!,
                      ].join(' · ')),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(
                              m.isActive
                                  ? l.medicationActive
                                  : l.medicationInactive,
                            ),
                            backgroundColor: m.isActive
                                ? Colors.green.shade50
                                : Colors.grey.shade200,
                          ),
                          PopupMenuButton(
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(l.edit),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(l.delete),
                              ),
                            ],
                            onSelected: (v) {
                              if (v == 'edit') _showMedicationForm(m);
                              if (v == 'delete') {
                                _deleteMedication(m.medicationId);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _MedicationFormSheet extends StatefulWidget {
  const _MedicationFormSheet({
    required this.patientId,
    this.existing,
    required this.onSaved,
    required this.repo,
  });

  final String patientId;
  final MedicationEntity? existing;
  final VoidCallback onSaved;
  final dynamic repo;

  @override
  State<_MedicationFormSheet> createState() => _MedicationFormSheetState();
}

class _MedicationFormSheetState extends State<_MedicationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _freqController = TextEditingController();
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    if (m != null) {
      _nameController.text = m.name;
      _doseController.text = m.doseText ?? '';
      _freqController.text = m.frequencyText ?? '';
      _isActive = m.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _freqController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final now = DateTime.now();
    final med = MedicationEntity(
      medicationId: widget.existing?.medicationId ??
          '${widget.patientId}_med_${now.millisecondsSinceEpoch}',
      patientId: widget.patientId,
      name: _nameController.text.trim(),
      doseText: _doseController.text.trim().isEmpty
          ? null
          : _doseController.text.trim(),
      frequencyText: _freqController.text.trim().isEmpty
          ? null
          : _freqController.text.trim(),
      isActive: _isActive,
      startedOn: widget.existing?.startedOn,
      updatedAt: now,
    );

    await widget.repo.upsert(med);

    if (!mounted) return;

    setState(() => _saving = false);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: AppLayout.horizontalPadding,
        right: AppLayout.horizontalPadding,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing != null ? l.edit : l.addMedication,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l.medicationName),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l.nameRequired : null,
            ),
            const SizedBox(height: AppLayout.fieldSpacing),
            TextFormField(
              controller: _doseController,
              decoration: InputDecoration(labelText: l.medicationDose),
            ),
            const SizedBox(height: AppLayout.fieldSpacing),
            TextFormField(
              controller: _freqController,
              decoration: InputDecoration(labelText: l.medicationFrequency),
            ),
            const SizedBox(height: AppLayout.fieldSpacing),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.medicationActive),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}
