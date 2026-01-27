import 'package:flutter/material.dart';

class AccessibilityState {
  static final ValueNotifier<int> contrast = ValueNotifier(1);
  static final ValueNotifier<int> textSize = ValueNotifier(1);
  static final ValueNotifier<int> spacing = ValueNotifier(1);
  static final ValueNotifier<bool> dyslexiaFont = ValueNotifier(false);

  static void cycle(ValueNotifier<int> notifier, int max) {
    notifier.value = notifier.value % max + 1;
  }

  static void reset() {
    contrast.value = 1;
    textSize.value = 1;
    spacing.value = 1;
    dyslexiaFont.value = false;
  }

  // =========================
  // 🔹 SPACING HELPERS
  // =========================

  static double spacingScale() {
    switch (spacing.value) {
      case 2:
        return 1.25; // comfortable
      case 3:
        return 1.5; // spacious
      default:
        return 1.0; // normal
    }
  }

  static EdgeInsets padding(double base) {
    return EdgeInsets.all(base * spacingScale());
  }

  static double gap(double base) {
    return base * spacingScale();
  }

  static final Listenable rebuild = Listenable.merge([
    contrast,
    spacing,
    dyslexiaFont,
  ]);
}
