/// Domain representation of a patient medication.
class MedicationEntity {
  const MedicationEntity({
    required this.medicationId,
    required this.patientId,
    required this.name,
    this.doseText,
    this.frequencyText,
    required this.isActive,
    this.startedOn,
    required this.updatedAt,
  });

  final String medicationId;
  final String patientId;
  final String name;
  final String? doseText;
  final String? frequencyText;
  final bool isActive;
  final String? startedOn;
  final DateTime updatedAt;
}
