import 'package:flutter/material.dart';

final theme = ThemeData(
  dividerTheme: DividerThemeData(
    color: Colors.black.withOpacity(0.4)
  ),
  indicatorColor: Colors.yellow,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Color.fromARGB(255, 31, 31, 31),
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700
        )
    ),
    dividerColor: Colors.white24,
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.white,
    ),
    textTheme: TextTheme(
        bodyMedium: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
        bodySmall: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        )
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF428BEB),
      secondary: const Color(0xFFB0B0B0),
      onSurface: Colors.white,
      onPrimary: Colors.white, // Set primary text color to white
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 31, 31, 31),
    brightness: Brightness.dark
);