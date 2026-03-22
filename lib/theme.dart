import 'package:flutter/material.dart';

final Color primarySeedColor = Color.fromARGB(255, 104, 162, 255);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primarySeedColor,
    brightness: Brightness.light,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primarySeedColor,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: Color(0xFF1A1F26),
);
