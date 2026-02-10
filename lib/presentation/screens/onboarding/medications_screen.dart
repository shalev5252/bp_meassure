import 'dart:math';

import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/domain/entities/medication_entity.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  final _medications = <_MedEntry>[];
  bool _loading = false;

  void _addMedication() {
    setState(() => _medications.add(_MedEntry()));
  }

  void _removeMedication(int index) {
    setState(() => _medications.removeAt(index));
  }

  Future<void> _finish() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() => _loading = true);

    final patientResult =
        await ref.read(patientRepositoryProvider).getByUserId(user.uid);
    final patient = switch (patientResult) {
      Success(:final value) => value,
      Err() => null,
    };
    if (patient == null || !mounted) {
      setState(() => _loading = false);
      return;
    }

    final repo = ref.read(medicationRepositoryProvider);
    final now = DateTime.now();
    for (final med in _medications) {
      final name = med.nameCtrl.text.trim();
      if (name.isEmpty) continue;
      await repo.upsert(MedicationEntity(
        medicationId: _generateId(),
        patientId: patient.patientId,
        name: name,
        doseText: med.doseCtrl.text.trim().isNotEmpty
            ? med.doseCtrl.text.trim()
            : null,
        frequencyText: med.freqCtrl.text.trim().isNotEmpty
            ? med.freqCtrl.text.trim()
            : null,
        isActive: true,
        updatedAt: now,
      ));
    }

    if (!mounted) return;
    // Invalidate the onboarding check so the router redirect picks up the new state.
    ref.invalidate(onboardingCompleteProvider);
    context.go('/home');
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
      appBar: AppBar(title: Text(l.onboardingMedications)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.horizontalPadding,
                ),
                children: [
                  const SizedBox(height: 8),
                  for (var i = 0; i < _medications.length; i++)
                    _MedCard(
                      entry: _medications[i],
                      onRemove: () => _removeMedication(i),
                      l: l,
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _addMedication,
                    icon: const Icon(Icons.add),
                    label: Text(l.addMedication),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppLayout.horizontalPadding),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading
                          ? null
                          : () {
                              ref.invalidate(onboardingCompleteProvider);
                              context.go('/home');
                            },
                      child: Text(l.onboardingSkip),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _loading ? null : _finish,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l.onboardingDone),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedEntry {
  final nameCtrl = TextEditingController();
  final doseCtrl = TextEditingController();
  final freqCtrl = TextEditingController();
}

class _MedCard extends StatelessWidget {
  const _MedCard({
    required this.entry,
    required this.onRemove,
    required this.l,
  });

  final _MedEntry entry;
  final VoidCallback onRemove;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.nameCtrl,
                    decoration: InputDecoration(labelText: l.medicationName),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.doseCtrl,
                    decoration: InputDecoration(labelText: l.medicationDose),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: entry.freqCtrl,
                    decoration:
                        InputDecoration(labelText: l.medicationFrequency),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
