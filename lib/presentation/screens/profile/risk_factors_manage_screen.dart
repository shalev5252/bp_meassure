import 'package:bp_monitor/core/constants.dart';
import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/widgets.dart';
import 'package:bp_monitor/domain/entities/risk_factor_entity.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RiskFactorsManageScreen extends ConsumerStatefulWidget {
  const RiskFactorsManageScreen({super.key});

  @override
  ConsumerState<RiskFactorsManageScreen> createState() =>
      _RiskFactorsManageScreenState();
}

class _RiskFactorsManageScreenState
    extends ConsumerState<RiskFactorsManageScreen> {
  final Map<RiskCode, bool> _selected = {};
  final Map<RiskCode, TextEditingController> _notesControllers = {};
  bool _loading = true;
  bool _saving = false;
  String? _patientId;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final code in RiskCode.values) {
      _selected[code] = false;
      _notesControllers[code] = TextEditingController();
    }
    _loadData();
  }

  @override
  void dispose() {
    for (final c in _notesControllers.values) {
      c.dispose();
    }
    super.dispose();
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
        .read(riskFactorRepositoryProvider)
        .getByPatientId(patient.patientId);

    if (!mounted) return;

    switch (result) {
      case Success(:final value):
        for (final rf in value) {
          _selected[rf.riskCode] = rf.isPresent;
          _notesControllers[rf.riskCode]?.text = rf.notes ?? '';
        }
        setState(() => _loading = false);
      case Err(:final failure):
        setState(() {
          _error = failure.message;
          _loading = false;
        });
    }
  }

  Future<void> _save() async {
    if (_patientId == null) return;
    setState(() => _saving = true);

    final repo = ref.read(riskFactorRepositoryProvider);
    final now = DateTime.now();

    for (final code in RiskCode.values) {
      final entity = RiskFactorEntity(
        patientId: _patientId!,
        riskCode: code,
        isPresent: _selected[code] ?? false,
        notes: _notesControllers[code]?.text.trim().isEmpty ?? true
            ? null
            : _notesControllers[code]!.text.trim(),
        updatedAt: now,
      );
      await repo.upsert(entity);
    }

    if (!mounted) return;

    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.save)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.onboardingRiskFactors)),
        body: LoadingView(message: l.loading),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.onboardingRiskFactors)),
        body: ErrorView(message: _error!, onRetry: _loadData),
      );
    }

    final chronic = RiskCode.values.where((c) =>
        c.index <= RiskCode.atrialFibrillation.index).toList();
    final lifestyle = RiskCode.values.where((c) =>
        c.index >= RiskCode.smokerCurrent.index &&
        c.index <= RiskCode.excessAlcohol.index).toList();
    final family = RiskCode.values.where((c) =>
        c.index >= RiskCode.familyHypertension.index).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.onboardingRiskFactors),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.horizontalPadding,
          vertical: 8,
        ),
        children: [
          _buildSection(l.riskFactorsChronic, chronic, l),
          _buildSection(l.riskFactorsLifestyle, lifestyle, l),
          _buildSection(l.riskFactorsFamily, family, l),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, List<RiskCode> codes, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        ...codes.map((code) => ExpansionTile(
              title: Text(_riskCodeLabel(code, l)),
              leading: Checkbox(
                value: _selected[code] ?? false,
                onChanged: (v) =>
                    setState(() => _selected[code] = v ?? false),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: TextFormField(
                    controller: _notesControllers[code],
                    decoration:
                        InputDecoration(labelText: l.riskFactorNotes),
                    maxLines: 2,
                  ),
                ),
              ],
            )),
      ],
    );
  }
}

String _riskCodeLabel(RiskCode code, AppLocalizations l) => switch (code) {
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
