import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BP Monitor'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @onboardingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get onboardingLanguage;

  /// No description provided for @onboardingProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get onboardingProfile;

  /// No description provided for @onboardingRiskFactors.
  ///
  /// In en, this message translates to:
  /// **'Risk Factors'**
  String get onboardingRiskFactors;

  /// No description provided for @onboardingMedications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get onboardingMedications;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onboardingDone;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get patientName;

  /// No description provided for @patientDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get patientDateOfBirth;

  /// No description provided for @patientSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get patientSex;

  /// No description provided for @patientHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get patientHeight;

  /// No description provided for @patientWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get patientWeight;

  /// No description provided for @sexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get sexMale;

  /// No description provided for @sexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get sexFemale;

  /// No description provided for @sexOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sexOther;

  /// No description provided for @sexUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get sexUnspecified;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @readings.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get readings;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @newReading.
  ///
  /// In en, this message translates to:
  /// **'New Reading'**
  String get newReading;

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic (SYS)'**
  String get systolic;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic (DIA)'**
  String get diastolic;

  /// No description provided for @pulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse (BPM)'**
  String get pulse;

  /// No description provided for @takenAt.
  ///
  /// In en, this message translates to:
  /// **'Taken At'**
  String get takenAt;

  /// No description provided for @contextTags.
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get contextTags;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @qualityValid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get qualityValid;

  /// No description provided for @qualityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get qualityInvalid;

  /// No description provided for @qualityUnsure.
  ///
  /// In en, this message translates to:
  /// **'Unsure'**
  String get qualityUnsure;

  /// No description provided for @tagMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get tagMorning;

  /// No description provided for @tagEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get tagEvening;

  /// No description provided for @tagAfterRest.
  ///
  /// In en, this message translates to:
  /// **'After Rest'**
  String get tagAfterRest;

  /// No description provided for @tagAfterExercise.
  ///
  /// In en, this message translates to:
  /// **'After Exercise'**
  String get tagAfterExercise;

  /// No description provided for @tagAfterMeal.
  ///
  /// In en, this message translates to:
  /// **'After Meal'**
  String get tagAfterMeal;

  /// No description provided for @tagStressed.
  ///
  /// In en, this message translates to:
  /// **'Stressed'**
  String get tagStressed;

  /// No description provided for @tagAtDoctor.
  ///
  /// In en, this message translates to:
  /// **'At Doctor'**
  String get tagAtDoctor;

  /// No description provided for @categoryNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get categoryNormal;

  /// No description provided for @categoryHighNormal.
  ///
  /// In en, this message translates to:
  /// **'High-Normal'**
  String get categoryHighNormal;

  /// No description provided for @categoryGrade1.
  ///
  /// In en, this message translates to:
  /// **'Grade 1'**
  String get categoryGrade1;

  /// No description provided for @categoryGrade2.
  ///
  /// In en, this message translates to:
  /// **'Grade 2'**
  String get categoryGrade2;

  /// No description provided for @categoryGrade3.
  ///
  /// In en, this message translates to:
  /// **'Grade 3'**
  String get categoryGrade3;

  /// No description provided for @categoryCrisis.
  ///
  /// In en, this message translates to:
  /// **'Crisis'**
  String get categoryCrisis;

  /// No description provided for @safetyWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get safetyWarningTitle;

  /// No description provided for @safetyBpRedFlag.
  ///
  /// In en, this message translates to:
  /// **'Your blood pressure reading is critically high. Please seek medical attention immediately.'**
  String get safetyBpRedFlag;

  /// No description provided for @safetyPulseWarning.
  ///
  /// In en, this message translates to:
  /// **'Your pulse reading is outside the normal range. Consider discussing this with your doctor.'**
  String get safetyPulseWarning;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsAddMore.
  ///
  /// In en, this message translates to:
  /// **'Add at least 3 readings to see analytics.'**
  String get analyticsAddMore;

  /// No description provided for @analyticsAvgSys.
  ///
  /// In en, this message translates to:
  /// **'Avg Systolic'**
  String get analyticsAvgSys;

  /// No description provided for @analyticsAvgDia.
  ///
  /// In en, this message translates to:
  /// **'Avg Diastolic'**
  String get analyticsAvgDia;

  /// No description provided for @analyticsAvgPulse.
  ///
  /// In en, this message translates to:
  /// **'Avg Pulse'**
  String get analyticsAvgPulse;

  /// No description provided for @analyticsStdDev.
  ///
  /// In en, this message translates to:
  /// **'Std Dev'**
  String get analyticsStdDev;

  /// No description provided for @analyticsTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get analyticsTrend;

  /// No description provided for @analyticsPctAbove.
  ///
  /// In en, this message translates to:
  /// **'% Above 140/90'**
  String get analyticsPctAbove;

  /// No description provided for @analytics7d.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get analytics7d;

  /// No description provided for @analytics30d.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get analytics30d;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsights;

  /// No description provided for @aiConsent.
  ///
  /// In en, this message translates to:
  /// **'AI analysis sends anonymized data to our server. No data is stored. Do you consent?'**
  String get aiConsent;

  /// No description provided for @aiConsentAgree.
  ///
  /// In en, this message translates to:
  /// **'I Agree'**
  String get aiConsentAgree;

  /// No description provided for @aiBlocked.
  ///
  /// In en, this message translates to:
  /// **'AI insights are unavailable when a critical reading is detected. Please consult your doctor.'**
  String get aiBlocked;

  /// No description provided for @aiOffline.
  ///
  /// In en, this message translates to:
  /// **'AI insights require an internet connection.'**
  String get aiOffline;

  /// No description provided for @aiAskQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a question (optional)'**
  String get aiAskQuestion;

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is not medical advice. Always consult your healthcare provider.'**
  String get aiDisclaimer;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTitle;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF Report'**
  String get exportPdf;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV Data'**
  String get exportCsv;

  /// No description provided for @exportDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get exportDateRange;

  /// No description provided for @exportShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get exportShare;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get medicationName;

  /// No description provided for @medicationDose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get medicationDose;

  /// No description provided for @medicationFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get medicationFrequency;

  /// No description provided for @medicationActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get medicationActive;

  /// No description provided for @medicationInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get medicationInactive;

  /// No description provided for @medicationStartedOn.
  ///
  /// In en, this message translates to:
  /// **'Started On'**
  String get medicationStartedOn;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @riskFactorsChronic.
  ///
  /// In en, this message translates to:
  /// **'Chronic Conditions'**
  String get riskFactorsChronic;

  /// No description provided for @riskFactorsLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get riskFactorsLifestyle;

  /// No description provided for @riskFactorsFamily.
  ///
  /// In en, this message translates to:
  /// **'Family History'**
  String get riskFactorsFamily;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsExportAll.
  ///
  /// In en, this message translates to:
  /// **'Export All Data'**
  String get settingsExportAll;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
