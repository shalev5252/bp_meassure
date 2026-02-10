import 'package:flutter/material.dart';

/// Common layout constants and responsive helpers.
class AppLayout {
  AppLayout._();

  /// Maximum content width for forms / cards on wide screens.
  static const double maxContentWidth = 480;

  /// Standard horizontal padding.
  static const double horizontalPadding = 24;

  /// Standard vertical gap between form fields.
  static const double fieldSpacing = 16;

  /// Wraps [child] in a centered, width-constrained container suitable
  /// for auth / form screens.
  static Widget formWrapper({required Widget child}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}
