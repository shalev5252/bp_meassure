import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported locales.
const supportedLocales = [
  Locale('en'),
  Locale('he'),
];

/// Provides the currently selected locale with runtime switching.
final localeProvider = StateProvider<Locale>((ref) {
  return supportedLocales.first; // default English
});
