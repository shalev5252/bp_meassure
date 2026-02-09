import 'package:bp_monitor/core/constants.dart';

/// Blood pressure classification per Israel-aligned standard.
enum BpCategory {
  normal,
  highNormal,
  grade1,
  grade2,
  grade3,
  crisis;

  /// Classify a reading based on systolic and diastolic values.
  ///
  /// Uses the higher category when systolic and diastolic fall in
  /// different ranges.
  static BpCategory classify(int systolic, int diastolic) {
    if (systolic >= BpThresholds.crisisSysMin ||
        diastolic >= BpThresholds.crisisDiaMin) {
      return crisis;
    }
    if (systolic >= BpThresholds.grade3SysMin ||
        diastolic >= BpThresholds.grade3DiaMin) {
      return grade3;
    }
    if (systolic > BpThresholds.grade1SysMax ||
        diastolic > BpThresholds.grade1DiaMax) {
      return grade2;
    }
    if (systolic > BpThresholds.highNormalSysMax ||
        diastolic > BpThresholds.highNormalDiaMax) {
      return grade1;
    }
    if (systolic > BpThresholds.normalSysMax ||
        diastolic > BpThresholds.normalDiaMax) {
      return highNormal;
    }
    return normal;
  }
}
