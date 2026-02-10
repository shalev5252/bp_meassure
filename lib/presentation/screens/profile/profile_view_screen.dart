import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/widgets.dart';
import 'package:bp_monitor/domain/entities/patient_entity.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileViewScreen extends ConsumerStatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  ConsumerState<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends ConsumerState<ProfileViewScreen> {
  PatientEntity? _patient;
  bool _loading = true;
  String? _error;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _dob;
  String? _sex;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final result =
        await ref.read(patientRepositoryProvider).getByUserId(user.uid);

    if (!mounted) return;

    switch (result) {
      case Success(:final value):
        setState(() {
          _patient = value;
          if (value != null) _populateFields(value);
          _loading = false;
        });
      case Err(:final failure):
        setState(() {
          _error = failure.message;
          _loading = false;
        });
    }
  }

  void _populateFields(PatientEntity p) {
    _nameController.text = p.displayName;
    _dob = p.dateOfBirth;
    _sex = p.sex;
    _heightController.text = p.heightCm?.toString() ?? '';
    _weightController.text = p.weightKg?.toString() ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final p = _patient!;
    final updated = PatientEntity(
      patientId: p.patientId,
      userId: p.userId,
      displayName: _nameController.text.trim(),
      dateOfBirth: _dob,
      sex: _sex,
      heightCm: _heightController.text.trim().isEmpty
          ? null
          : double.tryParse(_heightController.text.trim()),
      weightKg: _weightController.text.trim().isEmpty
          ? null
          : double.tryParse(_weightController.text.trim()),
      createdAt: p.createdAt,
      updatedAt: DateTime.now(),
    );

    final result = await ref.read(patientRepositoryProvider).upsert(updated);

    if (!mounted) return;

    switch (result) {
      case Success():
        setState(() {
          _patient = updated;
          _editing = false;
          _saving = false;
        });
      case Err(:final failure):
        setState(() => _saving = false);
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
        appBar: AppBar(title: Text(l.profile)),
        body: LoadingView(message: l.loading),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.profile)),
        body: ErrorView(message: _error!, onRetry: _loadData),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profile),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
            ),
          IconButton(
            icon: const Icon(Icons.medical_information),
            onPressed: () => context.push('/profile/risk-factors'),
          ),
          IconButton(
            icon: const Icon(Icons.medication),
            onPressed: () => context.push('/profile/medications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: AppLayout.formWrapper(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l.patientName),
                  enabled: _editing,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l.nameRequired : null,
                ),
                const SizedBox(height: AppLayout.fieldSpacing),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.patientDateOfBirth),
                  subtitle: Text(_dob ?? '-'),
                  trailing: _editing
                      ? const Icon(Icons.calendar_today)
                      : null,
                  onTap: _editing ? _pickDob : null,
                ),
                const SizedBox(height: AppLayout.fieldSpacing),
                DropdownButtonFormField<String>(
                  initialValue: _sex,
                  decoration: InputDecoration(labelText: l.patientSex),
                  items: [
                    DropdownMenuItem(value: 'male', child: Text(l.sexMale)),
                    DropdownMenuItem(value: 'female', child: Text(l.sexFemale)),
                    DropdownMenuItem(value: 'other', child: Text(l.sexOther)),
                    DropdownMenuItem(
                        value: 'unspecified', child: Text(l.sexUnspecified)),
                  ],
                  onChanged: _editing
                      ? (v) => setState(() => _sex = v)
                      : null,
                ),
                const SizedBox(height: AppLayout.fieldSpacing),
                TextFormField(
                  controller: _heightController,
                  decoration: InputDecoration(labelText: l.patientHeight),
                  keyboardType: TextInputType.number,
                  enabled: _editing,
                ),
                const SizedBox(height: AppLayout.fieldSpacing),
                TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(labelText: l.patientWeight),
                  keyboardType: TextInputType.number,
                  enabled: _editing,
                ),
                if (_editing) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _populateFields(_patient!);
                            setState(() => _editing = false);
                          },
                          child: Text(l.cancel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : Text(l.save),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDob() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dob != null ? DateTime.tryParse(_dob!) : null,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _dob = date.toIso8601String().split('T').first);
    }
  }
}
