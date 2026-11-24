import 'package:flutter/material.dart';

/// Spacing scale (4-pt grid). Use these instead of raw numbers so screens stay proportional.
abstract final class Space {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Horizontal page margin, used by every screen.
  static const page = l;
}

abstract final class Radii {
  static const card = 20.0;
  static const group = 24.0;
}

/// A note color: the stored key (kept from v1 so old notes keep their color) and its display tints.
typedef NoteTint = ({int key, String name, Color light, Color dark});

/// Calm "paper" pastels with a real dark counterpart. Text on every tint is >= 9:1.
const noteTints = <NoteTint>[
  (key: 0xffffffff, name: 'Default color', light: Color(0x00000000), dark: Color(0x00000000)),
  (key: 0xfff28b81, name: 'Rose', light: Color(0xfff9d3cf), dark: Color(0xff5c2b2b)),
  (key: 0xfff7bd02, name: 'Amber', light: Color(0xfffbe2a8), dark: Color(0xff5a4210)),
  (key: 0xfffbf476, name: 'Lemon', light: Color(0xfffaf3b5), dark: Color(0xff4f4a1c)),
  (key: 0xffcdff90, name: 'Lime', light: Color(0xffe3f2c9), dark: Color(0xff354a22)),
  (key: 0xffa7feeb, name: 'Mint', light: Color(0xffcdefe4), dark: Color(0xff1f4a40)),
  (key: 0xffcbf0f8, name: 'Sky', light: Color(0xffd5ecf4), dark: Color(0xff1e4250)),
  (key: 0xffafcbfa, name: 'Blue', light: Color(0xffd3def8), dark: Color(0xff263a5e)),
  (key: 0xffd7aefc, name: 'Lavender', light: Color(0xffe4d5f7), dark: Color(0xff3d2d57)),
  (key: 0xfffbcfe9, name: 'Pink', light: Color(0xfff8d9e8), dark: Color(0xff57304a)),
  (key: 0xffe6c9a9, name: 'Sand', light: Color(0xffecddcb), dark: Color(0xff4a3b2c)),
  (key: 0xffe9eaee, name: 'Grey', light: Color(0xffe6e7eb), dark: Color(0xff3a3c42)),
];

/// Card/page background for a stored note color; null = theme surface (the default "white" note).
Color? noteBackground(int key, Brightness b) {
  if (key == 0xffffffff) return null;
  for (final t in noteTints) {
    if (t.key == key) return b == Brightness.dark ? t.dark : t.light;
  }
  // Unknown value (e.g. from an edited backup): as stored, deepened in dark mode.
  return b == Brightness.dark ? Color.lerp(Color(key), const Color(0xff000000), 0.7) : Color(key);
}

/// Text color on a tinted note; null = theme default.
Color? noteForeground(int key, Brightness b) {
  if (key == 0xffffffff) return null;
  return b == Brightness.dark ? const Color(0xffeeeae6) : const Color(0xff1f1b16);
}

ThemeData buildTheme(Color seed, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  final base = ThemeData(colorScheme: scheme, fontFamily: 'Vazirmatn');
  final t = base.textTheme;
  return base.copyWith(
    // Persian script needs more leading than Latin defaults.
    textTheme: t.copyWith(
      bodyLarge: t.bodyLarge?.copyWith(height: 1.7),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 15, height: 1.65),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w700, height: 1.5),
      titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: t.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      highlightElevation: 4,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Space.l)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Space.m)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(showDragHandle: true),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: Space.l),
      minVerticalPadding: Space.m,
    ),
    searchBarTheme: SearchBarThemeData(
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
      constraints: const BoxConstraints(minHeight: 52),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: Space.xs)),
    ),
  );
}
