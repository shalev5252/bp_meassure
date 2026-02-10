import 'dart:math';

import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/domain/entities/patient_entity.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String? _sex;
  DateTime? _dateOfBirth;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final now = DateTime.now();
    final patient = PatientEntity(
      patientId: _generateId(),
      userId: user.uid,
      displayName: _nameCtrl.text.trim(),
      dateOfBirth: _dateOfBirth?.toIso8601String().split('T').first,
      sex: _sex,
      heightCm: double.tryParse(_heightCtrl.text),
      weightKg: double.tryParse(_weightCtrl.text),
      createdAt: now,
      updatedAt: now,
    );

    final result = await ref.read(patientRepositoryProvider).upsert(patient);

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case Success():
        if (mounted) context.go('/onboarding/risk-factors');
      case Err(:final failure):
        setState(() => _error = failure.message);
    }
  }

  String _generateId() {
    final rng = Random.secure();
    final bytes = List.generate(16, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.onboardingProfile)),
      body: SafeArea(
        child: AppLayout.formWrapper(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 16),
                if (_error != null) ...[
                  _ErrorBanner(message: _error!),
                  const SizedBox(height: AppLayout.fieldSpacing),
                ],
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(labelText: l.patientName),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l.nameRequired;
                    return null;
                  },
                ),
                const SizedBox(height: AppLayout.fieldSpacing),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.patientDateOfBirth),
                  subtitle: Text(
                    _dateOfBirth != null
                        ? '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}'
                        : '-',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
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
                      value: 'unspecified',
                      child: Text(l.sexUnspecified),
                    ),
                  ],
                  onChanged: (v) => setState(() => _sex = v),
                ),
                const SizedBox(height: AppLayout.fieldSpacing),
                TextFormField(
                  controller: _heightCtrl,
                  decoration: InputDecoration(labelText: l.patientHeight),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppLayout.fieldSpacing),
                TextFormField(
                  controller: _weightCtrl,
                  decoration: InputDecoration(labelText: l.patientWeight),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l.onboardingNext),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
    );
  }
}
