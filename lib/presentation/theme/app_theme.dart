import 'package:bp_monitor/domain/entities/bp_category.dart';
import 'package:bp_monitor/domain/entities/pulse_status.dart';
import 'package:flutter/material.dart';

/// Application theme configuration (light mode, Material 3).
class AppTheme {
  AppTheme._();

  static const _seed = Colors.teal;

  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seed),
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
    ),
  );

  /// Color for a [BpCategory].
  static Color bpCategoryColor(BpCategory category) => switch (category) {
        BpCategory.normal => const Color(0xFF4CAF50),
        BpCategory.highNormal => const Color(0xFFFFC107),
        BpCategory.grade1 => const Color(0xFFFF9800),
        BpCategory.grade2 => const Color(0xFFFF5722),
        BpCategory.grade3 => const Color(0xFFF44336),
        BpCategory.crisis => const Color(0xFFD32F2F),
      };

  /// Color for a [PulseStatus].
  static Color pulseStatusColor(PulseStatus status) => switch (status) {
        PulseStatus.low => const Color(0xFFFF9800),
        PulseStatus.normal => const Color(0xFF4CAF50),
        PulseStatus.high => const Color(0xFFFF5722),
      };
}
