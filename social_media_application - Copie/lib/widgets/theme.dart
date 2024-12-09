import 'package:flutter/material.dart';


final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF673AB7)),
  useMaterial3: true,
  brightness: Brightness.light,
);


final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF673AB7)),
  useMaterial3: true,
  brightness: Brightness.dark,
);
