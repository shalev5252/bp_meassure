import 'package:bp_monitor/core/errors.dart';

/// Payload sent to the AI analyze endpoint.
class AiAnalyzeRequest {
  const AiAnalyzeRequest({
    required this.patientDisplayName,
    this.sex,
    this.ageYears,
    required this.riskFactors,
    required this.medications,
    required this.readings,
    required this.computedMetrics,
    required this.safetyFlags,
    required this.uiLocale,
    this.userQuestion,
  });

  final String patientDisplayName;
  final String? sex;
  final int? ageYears;
  final Map<String, bool> riskFactors;
  final List<Map<String, dynamic>> medications;
  final List<Map<String, dynamic>> readings;
  final Map<String, dynamic> computedMetrics;
  final Map<String, dynamic> safetyFlags;
  final String uiLocale;
  final String? userQuestion;

  Map<String, dynamic> toJson() => {
        'patient': {
          'display_name': patientDisplayName,
          if (sex != null) 'sex': sex,
          if (ageYears != null) 'age_years': ageYears,
        },
        'risk_factors': riskFactors,
        'medications': medications,
        'readings': readings,
        'computed_metrics': computedMetrics,
        'safety_flags': safetyFlags,
        'ui_locale': uiLocale,
        if (userQuestion != null) 'user_question': userQuestion,
      };
}

/// Response from the AI analyze endpoint.
class AiAnalyzeResponse {
  const AiAnalyzeResponse({
    required this.summary,
    required this.patternAnalysis,
    required this.contributingFactors,
    required this.lifestyleGuidance,
    required this.consultRecommendation,
    required this.doctorQuestions,
    required this.disclaimer,
    required this.safetyOverrideApplied,
    required this.requestId,
  });

  final String summary;
  final String patternAnalysis;
  final String contributingFactors;
  final String lifestyleGuidance;
  final String consultRecommendation;
  final List<String> doctorQuestions;
  final String disclaimer;
  final bool safetyOverrideApplied;
  final String requestId;

  factory AiAnalyzeResponse.fromJson(Map<String, dynamic> json) {
    return AiAnalyzeResponse(
      summary: json['summary'] as String? ?? '',
      patternAnalysis: json['pattern_analysis'] as String? ?? '',
      contributingFactors: json['contributing_factors'] as String? ?? '',
      lifestyleGuidance: json['lifestyle_guidance'] as String? ?? '',
      consultRecommendation: json['consult_recommendation'] as String? ?? '',
      doctorQuestions: (json['doctor_questions'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      disclaimer: json['disclaimer'] as String? ?? '',
      safetyOverrideApplied:
          json['safety_override_applied'] as bool? ?? false,
      requestId: json['request_id'] as String? ?? '',
    );
  }
}

/// Contract for remote AI analysis API calls.
abstract class AiRepository {
  Future<Result<AiAnalyzeResponse>> analyze(AiAnalyzeRequest request);
}
