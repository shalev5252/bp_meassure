import 'package:bp_monitor/core/constants.dart';

/// Domain representation of a patient's risk factor.
class RiskFactorEntity {
  const RiskFactorEntity({
    required this.patientId,
    required this.riskCode,
    required this.isPresent,
    this.notes,
    required this.updatedAt,
  });

  final String patientId;
  final RiskCode riskCode;
  final bool isPresent;
  final String? notes;
  final DateTime updatedAt;
}
