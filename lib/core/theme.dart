import 'package:flutter/material.dart';

class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.canvas,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.line,
    required this.tint,
  });
  final Color canvas, surface, ink, muted, line, tint;
  static const light = Palette(
    canvas: Color(0xFFF5F6F0),
    surface: Colors.white,
    ink: Color(0xFF20382E),
    muted: Color(0xFF5E6F64),
    line: Color(0xFFDEE5D9),
    tint: Color(0xFFE7EEDC),
  );
  static const dark = Palette(
    canvas: Color(0xFF111D18),
    surface: Color(0xFF1D2C24),
    ink: Color(0xFFF0F4E9),
    muted: Color(0xFFADBDAF),
    line: Color(0xFF36473C),
    tint: Color(0xFF2C4031),
  );
  static Palette of(BuildContext context) =>
      Theme.of(context).extension<Palette>()!;
  @override
  Palette copyWith({
    Color? canvas,
    Color? surface,
    Color? ink,
    Color? muted,
    Color? line,
    Color? tint,
  }) => Palette(
    canvas: canvas ?? this.canvas,
    surface: surface ?? this.surface,
    ink: ink ?? this.ink,
    muted: muted ?? this.muted,
    line: line ?? this.line,
    tint: tint ?? this.tint,
  );
  @override
  Palette lerp(covariant Palette? other, double t) => other == null
      ? this
      : Palette(
          canvas: Color.lerp(canvas, other.canvas, t)!,
          surface: Color.lerp(surface, other.surface, t)!,
          ink: Color.lerp(ink, other.ink, t)!,
          muted: Color.lerp(muted, other.muted, t)!,
          line: Color.lerp(line, other.line, t)!,
          tint: Color.lerp(tint, other.tint, t)!,
        );
}

ThemeData novaTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final p = dark ? Palette.dark : Palette.light;
  final primary = dark ? const Color(0xFFD4E6AD) : const Color(0xFF20382E);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Roboto',
    extensions: [p],
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF526D43),
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: dark ? const Color(0xFF20382E) : Colors.white,
          surface: p.surface,
        ),
    scaffoldBackgroundColor: p.canvas,
    textTheme: ThemeData(
      brightness: brightness,
      fontFamily: 'Roboto',
    ).textTheme.apply(bodyColor: p.ink, displayColor: p.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: p.canvas,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: p.ink,
      textColor: p.canvas,
      textStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerTheme: DividerThemeData(color: p.line, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        minimumSize: const Size(0, 56),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: BorderSide(color: p.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      errorMaxLines: 3,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: p.line),
      ),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: p.line),
      backgroundColor: p.surface,
      selectedColor: p.tint,
      labelStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: p.ink,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.ink,
      contentTextStyle: TextStyle(fontFamily: 'Roboto', color: p.canvas),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
