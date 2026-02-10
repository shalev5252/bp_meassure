import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/widgets.dart';
import 'package:bp_monitor/domain/entities/medication_entity.dart';
import 'package:bp_monitor/domain/entities/reading_entity.dart';
import 'package:bp_monitor/domain/entities/risk_factor_entity.dart';
import 'package:bp_monitor/domain/repositories/ai_repository.dart';
import 'package:bp_monitor/domain/services/analytics_service.dart';
import 'package:bp_monitor/domain/services/safety_service.dart';
import 'package:bp_monitor/infra/connectivity_service.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/locale_provider.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiInsightsScreen extends ConsumerStatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  ConsumerState<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends ConsumerState<AiInsightsScreen> {
  final _questionController = TextEditingController();
  bool _consentGiven = false;
  bool _loading = false;
  bool _loadingData = true;
  String? _error;
  AiAnalyzeResponse? _response;
  bool _hasBpRedFlag = false;
  List<ReadingEntity> _readings = [];
  String? _patientName;
  String? _patientSex;
  int? _patientAge;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final patientResult =
        await ref.read(patientRepositoryProvider).getByUserId(user.uid);
    final patient = switch (patientResult) {
      Success(:final value) => value,
      Err() => null,
    };
    if (patient == null) {
      if (mounted) setState(() => _loadingData = false);
      return;
    }

    _patientName = patient.displayName;
    _patientSex = patient.sex;
    _patientAge = patient.ageYears;

    final readingsResult = await ref
        .read(readingRepositoryProvider)
        .getByPatientId(patient.patientId);

    if (!mounted) return;

    switch (readingsResult) {
      case Success(:final value):
        _readings = value;
        const safety = SafetyService();
        _hasBpRedFlag = safety.hasActiveRedFlag(value);
        setState(() => _loadingData = false);
      case Err():
        setState(() => _loadingData = false);
    }
  }

  Future<void> _analyze() async {
    setState(() {
      _loading = true;
      _error = null;
      _response = null;
    });

    final isOnline = await checkConnectivity();
    if (!isOnline) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context)!.aiOffline;
          _loading = false;
        });
      }
      return;
    }

    const analytics = AnalyticsService();
    final result = analytics.compute(_readings);

    final patientId = _readings.firstOrNull?.patientId ?? '';

    final riskFactorsResult = await ref
        .read(riskFactorRepositoryProvider)
        .getByPatientId(patientId);
    final riskFactors = switch (riskFactorsResult) {
      Success(:final value) => value,
      Err() => <RiskFactorEntity>[],
    };

    final medsResult = await ref
        .read(medicationRepositoryProvider)
        .getByPatientId(patientId);
    final meds = switch (medsResult) {
      Success(:final value) => value,
      Err() => <MedicationEntity>[],
    };

    final locale = ref.read(localeProvider).languageCode;

    final request = AiAnalyzeRequest(
      patientDisplayName: _patientName ?? '',
      sex: _patientSex,
      ageYears: _patientAge,
      riskFactors: {
        for (final rf in riskFactors) rf.riskCode.name: rf.isPresent,
      },
      medications: [
        for (final m in meds)
          {
            'name': m.name,
            'dose': m.doseText,
            'frequency': m.frequencyText,
            'active': m.isActive,
          },
      ],
      readings: _readings.take(30).map((r) => {
            'systolic': r.systolic,
            'diastolic': r.diastolic,
            'pulse': r.pulse,
            'taken_at': r.takenAt.toIso8601String(),
            'category': r.bpCategory.name,
          }).toList(),
      computedMetrics: result != null
          ? {
              'avg_systolic': result.avgSystolic,
              'avg_diastolic': result.avgDiastolic,
              'avg_pulse': result.avgPulse,
              'std_dev_systolic': result.stdDevSystolic,
              'trend_slope_systolic': result.trendSlopeSystolic,
              'pct_above_threshold': result.pctAboveThreshold,
              'reading_count': result.readingCount,
            }
          : {},
      safetyFlags: {
        'has_bp_red_flag': _hasBpRedFlag,
      },
      uiLocale: locale,
      userQuestion: _questionController.text.trim().isEmpty
          ? null
          : _questionController.text.trim(),
    );

    final aiRepo = ref.read(aiRepositoryProvider);
    final aiResult = await aiRepo.analyze(request);

    if (!mounted) return;

    switch (aiResult) {
      case Success(:final value):
        setState(() {
          _response = value;
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
    final isOnline =
        ref.watch(connectivityProvider).valueOrNull ?? false;

    if (_loadingData) {
      return Scaffold(
        appBar: AppBar(title: Text(l.aiInsights)),
        body: LoadingView(message: l.loading),
      );
    }

    if (!isOnline) {
      return Scaffold(
        appBar: AppBar(title: Text(l.aiInsights)),
        body: EmptyView(
          message: l.aiOffline,
          icon: Icons.cloud_off,
        ),
      );
    }

    if (_hasBpRedFlag) {
      return Scaffold(
        appBar: AppBar(title: Text(l.aiInsights)),
        body: EmptyView(
          message: l.aiBlocked,
          icon: Icons.block,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.aiInsights)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.horizontalPadding,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Consent
            if (!_consentGiven) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.aiConsent),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            setState(() => _consentGiven = true),
                        child: Text(l.aiConsentAgree),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Question input
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: l.aiAskQuestion,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loading ? null : _analyze,
                icon: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_loading ? l.aiLoading : l.aiAnalyze),
              ),
              const SizedBox(height: 16),

              if (_error != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!),
                  ),
                ),

              if (_response != null) ...[
                _AiSection(title: l.aiSummary, body: _response!.summary),
                _AiSection(
                    title: l.aiPatternAnalysis,
                    body: _response!.patternAnalysis),
                _AiSection(
                    title: l.aiContributingFactors,
                    body: _response!.contributingFactors),
                _AiSection(
                    title: l.aiLifestyleGuidance,
                    body: _response!.lifestyleGuidance),
                _AiSection(
                    title: l.aiConsultRecommendation,
                    body: _response!.consultRecommendation),
                if (_response!.doctorQuestions.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.aiDoctorQuestions,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall),
                          const SizedBox(height: 8),
                          ...List.generate(
                            _response!.doctorQuestions.length,
                            (i) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                  '${i + 1}. ${_response!.doctorQuestions[i]}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                // Disclaimer
                Card(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _response!.disclaimer.isNotEmpty
                          ? _response!.disclaimer
                          : l.aiDisclaimer,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _AiSection extends StatelessWidget {
  const _AiSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    if (body.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(body),
            ],
          ),
        ),
      ),
    );
  }
}
