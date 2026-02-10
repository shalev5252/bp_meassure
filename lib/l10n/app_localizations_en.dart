// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BP Monitor';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get noData => 'No data available';

  @override
  String get onboardingLanguage => 'Choose Language';

  @override
  String get onboardingProfile => 'Create Profile';

  @override
  String get onboardingRiskFactors => 'Risk Factors';

  @override
  String get onboardingMedications => 'Medications';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingDone => 'Done';

  @override
  String get patientName => 'Name';

  @override
  String get patientDateOfBirth => 'Date of Birth';

  @override
  String get patientSex => 'Sex';

  @override
  String get patientHeight => 'Height (cm)';

  @override
  String get patientWeight => 'Weight (kg)';

  @override
  String get sexMale => 'Male';

  @override
  String get sexFemale => 'Female';

  @override
  String get sexOther => 'Other';

  @override
  String get sexUnspecified => 'Prefer not to say';

  @override
  String get home => 'Home';

  @override
  String get readings => 'Readings';

  @override
  String get analytics => 'Analytics';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get newReading => 'New Reading';

  @override
  String get systolic => 'Systolic (SYS)';

  @override
  String get diastolic => 'Diastolic (DIA)';

  @override
  String get pulse => 'Pulse (BPM)';

  @override
  String get takenAt => 'Taken At';

  @override
  String get contextTags => 'Context';

  @override
  String get notes => 'Notes';

  @override
  String get quality => 'Quality';

  @override
  String get qualityValid => 'Valid';

  @override
  String get qualityInvalid => 'Invalid';

  @override
  String get qualityUnsure => 'Unsure';

  @override
  String get tagMorning => 'Morning';

  @override
  String get tagEvening => 'Evening';

  @override
  String get tagAfterRest => 'After Rest';

  @override
  String get tagAfterExercise => 'After Exercise';

  @override
  String get tagAfterMeal => 'After Meal';

  @override
  String get tagStressed => 'Stressed';

  @override
  String get tagAtDoctor => 'At Doctor';

  @override
  String get categoryNormal => 'Normal';

  @override
  String get categoryHighNormal => 'High-Normal';

  @override
  String get categoryGrade1 => 'Grade 1';

  @override
  String get categoryGrade2 => 'Grade 2';

  @override
  String get categoryGrade3 => 'Grade 3';

  @override
  String get categoryCrisis => 'Crisis';

  @override
  String get safetyWarningTitle => 'Warning';

  @override
  String get safetyBpRedFlag =>
      'Your blood pressure reading is critically high. Please seek medical attention immediately.';

  @override
  String get safetyPulseWarning =>
      'Your pulse reading is outside the normal range. Consider discussing this with your doctor.';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsAddMore => 'Add at least 3 readings to see analytics.';

  @override
  String get analyticsAvgSys => 'Avg Systolic';

  @override
  String get analyticsAvgDia => 'Avg Diastolic';

  @override
  String get analyticsAvgPulse => 'Avg Pulse';

  @override
  String get analyticsStdDev => 'Std Dev';

  @override
  String get analyticsTrend => 'Trend';

  @override
  String get analyticsPctAbove => '% Above 140/90';

  @override
  String get analytics7d => '7 Days';

  @override
  String get analytics30d => '30 Days';

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get aiConsent =>
      'AI analysis sends anonymized data to our server. No data is stored. Do you consent?';

  @override
  String get aiConsentAgree => 'I Agree';

  @override
  String get aiBlocked =>
      'AI insights are unavailable when a critical reading is detected. Please consult your doctor.';

  @override
  String get aiOffline => 'AI insights require an internet connection.';

  @override
  String get aiAskQuestion => 'Ask a question (optional)';

  @override
  String get aiDisclaimer =>
      'This is not medical advice. Always consult your healthcare provider.';

  @override
  String get exportTitle => 'Export';

  @override
  String get exportPdf => 'PDF Report';

  @override
  String get exportCsv => 'CSV Data';

  @override
  String get exportDateRange => 'Date Range';

  @override
  String get exportShare => 'Share';

  @override
  String get medications => 'Medications';

  @override
  String get medicationName => 'Medication Name';

  @override
  String get medicationDose => 'Dose';

  @override
  String get medicationFrequency => 'Frequency';

  @override
  String get medicationActive => 'Active';

  @override
  String get medicationInactive => 'Inactive';

  @override
  String get medicationStartedOn => 'Started On';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get riskFactorsChronic => 'Chronic Conditions';

  @override
  String get riskFactorsLifestyle => 'Lifestyle';

  @override
  String get riskFactorsFamily => 'Family History';

  @override
  String get riskDiabetesType2 => 'Diabetes Type 2';

  @override
  String get riskDiabetesType1 => 'Diabetes Type 1';

  @override
  String get riskCkd => 'Chronic Kidney Disease';

  @override
  String get riskHeartFailure => 'Heart Failure';

  @override
  String get riskPriorStroke => 'Prior Stroke';

  @override
  String get riskPriorMi => 'Prior Heart Attack';

  @override
  String get riskAtrialFibrillation => 'Atrial Fibrillation';

  @override
  String get riskSmokerCurrent => 'Current Smoker';

  @override
  String get riskSmokerFormer => 'Former Smoker';

  @override
  String get riskObesityBmi30 => 'Obesity (BMI ≥ 30)';

  @override
  String get riskSedentaryLifestyle => 'Sedentary Lifestyle';

  @override
  String get riskHighSaltDiet => 'High Salt Diet';

  @override
  String get riskExcessAlcohol => 'Excess Alcohol';

  @override
  String get riskFamilyHypertension => 'Family History of Hypertension';

  @override
  String get riskFamilyHeartDisease => 'Family History of Heart Disease';

  @override
  String get riskFamilyDiabetes => 'Family History of Diabetes';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsExportAll => 'Export All Data';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get resetPasswordSent =>
      'Password reset email sent. Check your inbox.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get passwordHint => 'At least 6 characters';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get latestReading => 'Latest Reading';

  @override
  String get sevenDaySummary => '7-Day Summary';

  @override
  String get noReadingsYet => 'No readings yet. Add your first reading!';

  @override
  String get viewHistory => 'History';
}
