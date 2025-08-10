import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff35618e),
      surfaceTint: Color(0xff35618e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd1e4ff),
      onPrimaryContainer: Color(0xff184974),
      secondary: Color(0xff535f70),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd6e4f7),
      onSecondaryContainer: Color(0xff3b4858),
      tertiary: Color(0xff6a5778),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfff2daff),
      onTertiaryContainer: Color(0xff524060),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff8f9ff),
      onSurface: Color(0xff191c20),
      onSurfaceVariant: Color(0xff42474e),
      outline: Color(0xff73777f),
      outlineVariant: Color(0xffc3c7cf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3135),
      inversePrimary: Color(0xff9fcafd),
      primaryFixed: Color(0xffd1e4ff),
      onPrimaryFixed: Color(0xff001d35),
      primaryFixedDim: Color(0xff9fcafd),
      onPrimaryFixedVariant: Color(0xff184974),
      secondaryFixed: Color(0xffd6e4f7),
      onSecondaryFixed: Color(0xff0f1c2b),
      secondaryFixedDim: Color(0xffbac8db),
      onSecondaryFixedVariant: Color(0xff3b4858),
      tertiaryFixed: Color(0xfff2daff),
      onTertiaryFixed: Color(0xff251432),
      tertiaryFixedDim: Color(0xffd6bee5),
      onTertiaryFixedVariant: Color(0xff524060),
      surfaceDim: Color(0xffd8dae0),
      surfaceBright: Color(0xfff8f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff2f3f9),
      surfaceContainer: Color(0xffeceef4),
      surfaceContainerHigh: Color(0xffe6e8ee),
      surfaceContainerHighest: Color(0xffe1e2e8),
    );
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff9fcafd),
      surfaceTint: Color(0xff9fcafd),
      onPrimary: Color(0xff003257),
      primaryContainer: Color(0xff184974),
      onPrimaryContainer: Color(0xffd1e4ff),
      secondary: Color(0xffbac8db),
      onSecondary: Color(0xff253140),
      secondaryContainer: Color(0xff3b4858),
      onSecondaryContainer: Color(0xffd6e4f7),
      tertiary: Color(0xffd6bee5),
      onTertiary: Color(0xff3a2948),
      tertiaryContainer: Color(0xff524060),
      onTertiaryContainer: Color(0xfff2daff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff101418),
      onSurface: Color(0xffe1e2e8),
      onSurfaceVariant: Color(0xffc3c7cf),
      outline: Color(0xff8d9199),
      outlineVariant: Color(0xff42474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe1e2e8),
      inversePrimary: Color(0xff35618e),
      primaryFixed: Color(0xffd1e4ff),
      onPrimaryFixed: Color(0xff001d35),
      primaryFixedDim: Color(0xff9fcafd),
      onPrimaryFixedVariant: Color(0xff184974),
      secondaryFixed: Color(0xffd6e4f7),
      onSecondaryFixed: Color(0xff0f1c2b),
      secondaryFixedDim: Color(0xffbac8db),
      onSecondaryFixedVariant: Color(0xff3b4858),
      tertiaryFixed: Color(0xfff2daff),
      onTertiaryFixed: Color(0xff251432),
      tertiaryFixedDim: Color(0xffd6bee5),
      onTertiaryFixedVariant: Color(0xff524060),
      surfaceDim: Color(0xff101418),
      surfaceBright: Color(0xff36393e),
      surfaceContainerLowest: Color(0xff0b0e13),
      surfaceContainerLow: Color(0xff191c20),
      surfaceContainer: Color(0xff1d2024),
      surfaceContainerHigh: Color(0xff272a2f),
      surfaceContainerHighest: Color(0xff32353a),
    );
  }

  /// Custom Color 1
  static const customColor1 = ExtendedColor(
    seed: Color(0xff166ea6),
    value: Color(0xff166ea6),
    light: ColorFamily(
      color: Color(0xff2e628c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffcde5ff),
      onColorContainer: Color(0xff0b4a72),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff2e628c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffcde5ff),
      onColorContainer: Color(0xff0b4a72),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff2e628c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffcde5ff),
      onColorContainer: Color(0xff0b4a72),
    ),
    dark: ColorFamily(
      color: Color(0xff9acbfa),
      onColor: Color(0xff003352),
      colorContainer: Color(0xff0b4a72),
      onColorContainer: Color(0xffcde5ff),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff9acbfa),
      onColor: Color(0xff003352),
      colorContainer: Color(0xff0b4a72),
      onColorContainer: Color(0xffcde5ff),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff9acbfa),
      onColor: Color(0xff003352),
      colorContainer: Color(0xff0b4a72),
      onColorContainer: Color(0xffcde5ff),
    ),
  );


  List<ExtendedColor> get extendedColors => [
    customColor1,
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
