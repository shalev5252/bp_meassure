/// Domain representation of a patient profile.
class PatientEntity {
  PatientEntity({
    required this.patientId,
    required this.userId,
    required this.displayName,
    this.dateOfBirth,
    this.sex,
    this.heightCm,
    this.weightKg,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(displayName.isNotEmpty, 'displayName must not be empty');

  final String patientId;
  final String userId;
  final String displayName;
  final String? dateOfBirth;
  final String? sex;
  final double? heightCm;
  final double? weightKg;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Age in years based on [dateOfBirth], or null if not set.
  int? get ageYears {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final parsed = DateTime.tryParse(dob);
    if (parsed == null) return null;
    final now = DateTime.now();
    var age = now.year - parsed.year;
    if (now.month < parsed.month ||
        (now.month == parsed.month && now.day < parsed.day)) {
      age--;
    }
    return age;
  }
}
