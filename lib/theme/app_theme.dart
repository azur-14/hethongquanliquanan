import 'package:flutter/material.dart';
import 'color.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true, // ✅ Material3 cho hiệu ứng mượt hơn
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Roboto',

  textTheme: TextTheme(
    bodyMedium: TextStyle(color: AppColors.text),
    bodySmall: TextStyle(color: AppColors.textSecondary),
    labelLarge: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) {
          if (states.contains(MaterialState.pressed)) return AppColors.primaryDark;
          return AppColors.primary;
        },
      ),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      elevation: MaterialStateProperty.all(4),
      padding: MaterialStateProperty.all(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
);
