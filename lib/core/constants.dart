/// Blood pressure classification thresholds (Israel-aligned, ≥140/90).
class BpThresholds {
  BpThresholds._();

  // Normal: SYS ≤130, DIA ≤85
  static const int normalSysMax = 130;
  static const int normalDiaMax = 85;

  // High-Normal: SYS 130-139, DIA 85-89
  static const int highNormalSysMax = 139;
  static const int highNormalDiaMax = 89;

  // Grade 1: SYS 140-159, DIA 90-99
  static const int grade1SysMax = 159;
  static const int grade1DiaMax = 99;

  // Grade 2: SYS 160-179, DIA 100-109
  static const int grade2SysMax = 179;
  static const int grade2DiaMax = 109;

  // Grade 3: SYS ≥180, DIA ≥110
  static const int grade3SysMin = 180;
  static const int grade3DiaMin = 110;

  // Crisis / Red flag: SYS ≥180 OR DIA ≥120
  static const int crisisSysMin = 180;
  static const int crisisDiaMin = 120;
}

/// Pulse thresholds.
class PulseThresholds {
  PulseThresholds._();

  static const int lowMin = 50;
  static const int highMax = 100;
}

/// Valid input ranges for readings.
class ReadingRanges {
  ReadingRanges._();

  static const int sysMin = 50;
  static const int sysMax = 300;
  static const int diaMin = 20;
  static const int diaMax = 200;
  static const int pulseMin = 20;
  static const int pulseMax = 250;
}

/// Minimum readings required before analytics are shown.
const int kMinReadingsForAnalytics = 3;

/// Predefined context tags for readings.
enum ContextTag {
  morning,
  evening,
  afterRest,
  afterExercise,
  afterMeal,
  stressed,
  atDoctor,
}

/// Risk factor categories and codes.
enum RiskCode {
  // Chronic
  diabetesType2,
  diabetesType1,
  ckd,
  heartFailure,
  priorStroke,
  priorMi,
  atrialFibrillation,

  // Lifestyle
  smokerCurrent,
  smokerFormer,
  obesityBmi30,
  sedentaryLifestyle,
  highSaltDiet,
  excessAlcohol,

  // Family
  familyHypertension,
  familyHeartDisease,
  familyDiabetes,
}

/// Measurement quality marking.
enum MeasurementQuality {
  valid,
  invalid,
  unsure,
}
