import 'package:bp_monitor/core/constants.dart';
import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/domain/entities/risk_factor_entity.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RiskFactorsScreen extends ConsumerStatefulWidget {
  const RiskFactorsScreen({super.key});

  @override
  ConsumerState<RiskFactorsScreen> createState() => _RiskFactorsScreenState();
}

class _RiskFactorsScreenState extends ConsumerState<RiskFactorsScreen> {
  final _selected = <RiskCode>{};
  bool _loading = false;

  Future<void> _submit() async {
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

    final repo = ref.read(riskFactorRepositoryProvider);
    final now = DateTime.now();
    for (final code in RiskCode.values) {
      await repo.upsert(RiskFactorEntity(
        patientId: patient.patientId,
        riskCode: code,
        isPresent: _selected.contains(code),
        updatedAt: now,
      ));
    }

    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/onboarding/medications');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.onboardingRiskFactors)),
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
                  _SectionHeader(l.riskFactorsChronic),
                  ..._chronic.map((c) => _RiskTile(
                        code: c,
                        checked: _selected.contains(c),
                        onChanged: (v) => setState(() {
                          v ? _selected.add(c) : _selected.remove(c);
                        }),
                      )),
                  _SectionHeader(l.riskFactorsLifestyle),
                  ..._lifestyle.map((c) => _RiskTile(
                        code: c,
                        checked: _selected.contains(c),
                        onChanged: (v) => setState(() {
                          v ? _selected.add(c) : _selected.remove(c);
                        }),
                      )),
                  _SectionHeader(l.riskFactorsFamily),
                  ..._family.map((c) => _RiskTile(
                        code: c,
                        checked: _selected.contains(c),
                        onChanged: (v) => setState(() {
                          v ? _selected.add(c) : _selected.remove(c);
                        }),
                      )),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppLayout.horizontalPadding),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l.onboardingNext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _chronic = [
    RiskCode.diabetesType2,
    RiskCode.diabetesType1,
    RiskCode.ckd,
    RiskCode.heartFailure,
    RiskCode.priorStroke,
    RiskCode.priorMi,
    RiskCode.atrialFibrillation,
  ];

  static const _lifestyle = [
    RiskCode.smokerCurrent,
    RiskCode.smokerFormer,
    RiskCode.obesityBmi30,
    RiskCode.sedentaryLifestyle,
    RiskCode.highSaltDiet,
    RiskCode.excessAlcohol,
  ];

  static const _family = [
    RiskCode.familyHypertension,
    RiskCode.familyHeartDisease,
    RiskCode.familyDiabetes,
  ];
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _RiskTile extends StatelessWidget {
  const _RiskTile({
    required this.code,
    required this.checked,
    required this.onChanged,
  });

  final RiskCode code;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: checked,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(riskCodeLabel(code, AppLocalizations.of(context)!)),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Map [RiskCode] to a localized label.
String riskCodeLabel(RiskCode code, AppLocalizations l) => switch (code) {
      RiskCode.diabetesType2 => l.riskDiabetesType2,
      RiskCode.diabetesType1 => l.riskDiabetesType1,
      RiskCode.ckd => l.riskCkd,
      RiskCode.heartFailure => l.riskHeartFailure,
      RiskCode.priorStroke => l.riskPriorStroke,
      RiskCode.priorMi => l.riskPriorMi,
      RiskCode.atrialFibrillation => l.riskAtrialFibrillation,
      RiskCode.smokerCurrent => l.riskSmokerCurrent,
      RiskCode.smokerFormer => l.riskSmokerFormer,
      RiskCode.obesityBmi30 => l.riskObesityBmi30,
      RiskCode.sedentaryLifestyle => l.riskSedentaryLifestyle,
      RiskCode.highSaltDiet => l.riskHighSaltDiet,
      RiskCode.excessAlcohol => l.riskExcessAlcohol,
      RiskCode.familyHypertension => l.riskFamilyHypertension,
      RiskCode.familyHeartDisease => l.riskFamilyHeartDisease,
      RiskCode.familyDiabetes => l.riskFamilyDiabetes,
    };
