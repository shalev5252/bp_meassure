// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'מד לחץ דם';

  @override
  String get login => 'התחברות';

  @override
  String get signUp => 'הרשמה';

  @override
  String get email => 'אימייל';

  @override
  String get password => 'סיסמה';

  @override
  String get forgotPassword => 'שכחת סיסמה?';

  @override
  String get resetPassword => 'איפוס סיסמה';

  @override
  String get logout => 'התנתקות';

  @override
  String get logoutConfirm => 'האם אתה בטוח שברצונך להתנתק?';

  @override
  String get cancel => 'ביטול';

  @override
  String get confirm => 'אישור';

  @override
  String get save => 'שמירה';

  @override
  String get delete => 'מחיקה';

  @override
  String get edit => 'עריכה';

  @override
  String get retry => 'נסה שוב';

  @override
  String get loading => 'טוען...';

  @override
  String get error => 'שגיאה';

  @override
  String get noData => 'אין נתונים זמינים';

  @override
  String get onboardingLanguage => 'בחר שפה';

  @override
  String get onboardingProfile => 'יצירת פרופיל';

  @override
  String get onboardingRiskFactors => 'גורמי סיכון';

  @override
  String get onboardingMedications => 'תרופות';

  @override
  String get onboardingSkip => 'דלג';

  @override
  String get onboardingNext => 'הבא';

  @override
  String get onboardingDone => 'סיום';

  @override
  String get patientName => 'שם';

  @override
  String get patientDateOfBirth => 'תאריך לידה';

  @override
  String get patientSex => 'מין';

  @override
  String get patientHeight => 'גובה (ס\"מ)';

  @override
  String get patientWeight => 'משקל (ק\"ג)';

  @override
  String get sexMale => 'זכר';

  @override
  String get sexFemale => 'נקבה';

  @override
  String get sexOther => 'אחר';

  @override
  String get sexUnspecified => 'מעדיף לא לציין';

  @override
  String get home => 'בית';

  @override
  String get readings => 'מדידות';

  @override
  String get analytics => 'ניתוח';

  @override
  String get profile => 'פרופיל';

  @override
  String get settings => 'הגדרות';

  @override
  String get newReading => 'מדידה חדשה';

  @override
  String get systolic => 'סיסטולי (SYS)';

  @override
  String get diastolic => 'דיאסטולי (DIA)';

  @override
  String get pulse => 'דופק (BPM)';

  @override
  String get takenAt => 'זמן מדידה';

  @override
  String get contextTags => 'הקשר';

  @override
  String get notes => 'הערות';

  @override
  String get quality => 'איכות';

  @override
  String get qualityValid => 'תקין';

  @override
  String get qualityInvalid => 'לא תקין';

  @override
  String get qualityUnsure => 'לא בטוח';

  @override
  String get tagMorning => 'בוקר';

  @override
  String get tagEvening => 'ערב';

  @override
  String get tagAfterRest => 'אחרי מנוחה';

  @override
  String get tagAfterExercise => 'אחרי פעילות גופנית';

  @override
  String get tagAfterMeal => 'אחרי ארוחה';

  @override
  String get tagStressed => 'במתח';

  @override
  String get tagAtDoctor => 'אצל הרופא';

  @override
  String get categoryNormal => 'תקין';

  @override
  String get categoryHighNormal => 'תקין-גבוה';

  @override
  String get categoryGrade1 => 'דרגה 1';

  @override
  String get categoryGrade2 => 'דרגה 2';

  @override
  String get categoryGrade3 => 'דרגה 3';

  @override
  String get categoryCrisis => 'משבר';

  @override
  String get safetyWarningTitle => 'אזהרה';

  @override
  String get safetyBpRedFlag =>
      'מדידת לחץ הדם שלך גבוהה באופן קריטי. אנא פנה לטיפול רפואי מיידי.';

  @override
  String get safetyPulseWarning =>
      'מדידת הדופק שלך מחוץ לטווח התקין. שקול לדון בכך עם הרופא שלך.';

  @override
  String get analyticsTitle => 'ניתוח';

  @override
  String get analyticsAddMore => 'הוסף לפחות 3 מדידות כדי לראות ניתוח.';

  @override
  String get analyticsAvgSys => 'ממוצע סיסטולי';

  @override
  String get analyticsAvgDia => 'ממוצע דיאסטולי';

  @override
  String get analyticsAvgPulse => 'ממוצע דופק';

  @override
  String get analyticsStdDev => 'סטיית תקן';

  @override
  String get analyticsTrend => 'מגמה';

  @override
  String get analyticsPctAbove => '% מעל 140/90';

  @override
  String get analytics7d => '7 ימים';

  @override
  String get analytics30d => '30 ימים';

  @override
  String get aiInsights => 'תובנות AI';

  @override
  String get aiConsent =>
      'ניתוח AI שולח נתונים אנונימיים לשרת שלנו. לא נשמרים נתונים. האם אתה מסכים?';

  @override
  String get aiConsentAgree => 'אני מסכים';

  @override
  String get aiBlocked =>
      'תובנות AI אינן זמינות כאשר מזוהה מדידה קריטית. אנא התייעץ עם הרופא שלך.';

  @override
  String get aiOffline => 'תובנות AI דורשות חיבור לאינטרנט.';

  @override
  String get aiAskQuestion => 'שאל שאלה (אופציונלי)';

  @override
  String get aiDisclaimer =>
      'זו אינה ייעוץ רפואי. תמיד התייעץ עם ספק שירותי הבריאות שלך.';

  @override
  String get exportTitle => 'ייצוא';

  @override
  String get exportPdf => 'דוח PDF';

  @override
  String get exportCsv => 'נתוני CSV';

  @override
  String get exportDateRange => 'טווח תאריכים';

  @override
  String get exportShare => 'שתף';

  @override
  String get medications => 'תרופות';

  @override
  String get medicationName => 'שם התרופה';

  @override
  String get medicationDose => 'מינון';

  @override
  String get medicationFrequency => 'תדירות';

  @override
  String get medicationActive => 'פעיל';

  @override
  String get medicationInactive => 'לא פעיל';

  @override
  String get medicationStartedOn => 'התחיל ב';

  @override
  String get addMedication => 'הוסף תרופה';

  @override
  String get riskFactorsChronic => 'מצבים כרוניים';

  @override
  String get riskFactorsLifestyle => 'אורח חיים';

  @override
  String get riskFactorsFamily => 'היסטוריה משפחתית';

  @override
  String get settingsLanguage => 'שפה';

  @override
  String get settingsAbout => 'אודות';

  @override
  String get settingsExportAll => 'ייצוא כל הנתונים';
}
