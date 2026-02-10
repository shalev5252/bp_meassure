import 'package:bp_monitor/core/constants.dart';
import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/domain/entities/reading_entity.dart';
import 'package:bp_monitor/domain/services/safety_service.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ReadingFormScreen extends ConsumerStatefulWidget {
  const ReadingFormScreen({super.key, this.existingReading});

  final ReadingEntity? existingReading;

  @override
  ConsumerState<ReadingFormScreen> createState() => _ReadingFormScreenState();
}

class _ReadingFormScreenState extends ConsumerState<ReadingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sysController = TextEditingController();
  final _diaController = TextEditingController();
  final _pulseController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _takenAt;
  MeasurementQuality? _quality;
  final Set<ContextTag> _selectedTags = {};
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.existingReading != null;

  @override
  void initState() {
    super.initState();
    final r = widget.existingReading;
    if (r != null) {
      _sysController.text = r.systolic.toString();
      _diaController.text = r.diastolic.toString();
      if (r.pulse != null) _pulseController.text = r.pulse.toString();
      _notesController.text = r.notes ?? '';
      _takenAt = r.takenAt;
      _quality = r.measurementQuality;
      _selectedTags.addAll(r.contextTags);
    } else {
      _takenAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _sysController.dispose();
    _diaController.dispose();
    _pulseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _takenAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_takenAt),
    );
    if (time == null || !mounted) return;

    setState(() {
      _takenAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
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
      if (mounted) setState(() { _saving = false; _error = 'Patient not found'; });
      return;
    }

    final now = DateTime.now();
    final reading = ReadingEntity(
      readingId: widget.existingReading?.readingId ??
          '${patient.patientId}_${now.millisecondsSinceEpoch}',
      patientId: patient.patientId,
      systolic: int.parse(_sysController.text.trim()),
      diastolic: int.parse(_diaController.text.trim()),
      pulse: _pulseController.text.trim().isEmpty
          ? null
          : int.parse(_pulseController.text.trim()),
      takenAt: _takenAt,
      contextTags: _selectedTags.toList(),
      measurementQuality: _quality,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.existingReading?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref.read(readingRepositoryProvider).upsert(reading);

    if (!mounted) return;

    switch (result) {
      case Success():
        // Check safety
        const safety = SafetyService();
        final check = safety.check(reading);
        if (check.hasBpRedFlag) {
          _showSafetyWarning(reading, isBpRedFlag: true);
        } else if (check.hasPulseWarning) {
          _showPulseWarning();
          context.pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.readingSaved)),
          );
          context.pop(true);
        }
      case Err(:final failure):
        setState(() {
          _error = failure.message;
          _saving = false;
        });
    }
  }

  void _showSafetyWarning(ReadingEntity reading, {required bool isBpRedFlag}) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber, color: Colors.red, size: 48),
        title: Text(l.safetyWarningTitle),
        content: Text(l.safetyBpRedFlag),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop(true);
            },
            child: Text(l.confirm),
          ),
        ],
      ),
    );
  }

  void _showPulseWarning() {
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.safetyPulseWarning),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.readingEditTitle : l.newReading),
      ),
      body: SingleChildScrollView(
        child: AppLayout.formWrapper(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                if (_error != null) ...[
                  MaterialBanner(
                    content: Text(_error!),
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    actions: [
                      TextButton(
                        onPressed: () => setState(() => _error = null),
                        child: Text(l.confirm),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppLayout.fieldSpacing),
                ],

                // Systolic
                TextFormField(
                  controller: _sysController,
                  decoration: InputDecoration(labelText: l.systolic),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l.systolicRequired;
                    final n = int.tryParse(v.trim());
                    if (n == null || n < ReadingRanges.sysMin || n > ReadingRanges.sysMax) {
                      return l.invalidSystolic;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppLayout.fieldSpacing),

                // Diastolic
                TextFormField(
                  controller: _diaController,
                  decoration: InputDecoration(labelText: l.diastolic),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l.diastolicRequired;
                    final n = int.tryParse(v.trim());
                    if (n == null || n < ReadingRanges.diaMin || n > ReadingRanges.diaMax) {
                      return l.invalidDiastolic;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppLayout.fieldSpacing),

                // Pulse
                TextFormField(
                  controller: _pulseController,
                  decoration: InputDecoration(labelText: l.pulse),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = int.tryParse(v.trim());
                    if (n == null || n < ReadingRanges.pulseMin || n > ReadingRanges.pulseMax) {
                      return l.invalidPulse;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppLayout.fieldSpacing),

                // Taken At (with backdating)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.takenAt),
                  subtitle: Text(
                    DateFormat.yMMMd().add_jm().format(_takenAt),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDateTime,
                ),
                const SizedBox(height: AppLayout.fieldSpacing),

                // Context Tags
                Text(l.contextTags, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: ContextTag.values.map((tag) {
                    final selected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(_tagLabel(tag, l)),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppLayout.fieldSpacing),

                // Quality
                Text(l.quality, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<MeasurementQuality?>(
                  segments: [
                    ButtonSegment(value: MeasurementQuality.valid, label: Text(l.qualityValid)),
                    ButtonSegment(value: MeasurementQuality.invalid, label: Text(l.qualityInvalid)),
                    ButtonSegment(value: MeasurementQuality.unsure, label: Text(l.qualityUnsure)),
                  ],
                  selected: {_quality},
                  onSelectionChanged: (v) => setState(() => _quality = v.first),
                  emptySelectionAllowed: true,
                ),
                const SizedBox(height: AppLayout.fieldSpacing),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: l.notes),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Save button
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _tagLabel(ContextTag tag, AppLocalizations l) => switch (tag) {
      ContextTag.morning => l.tagMorning,
      ContextTag.evening => l.tagEvening,
      ContextTag.afterRest => l.tagAfterRest,
      ContextTag.afterExercise => l.tagAfterExercise,
      ContextTag.afterMeal => l.tagAfterMeal,
      ContextTag.stressed => l.tagStressed,
      ContextTag.atDoctor => l.tagAtDoctor,
    };
