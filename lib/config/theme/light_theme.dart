import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';

final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: kPrimaryColor,
  fontFamily: AppFonts.URBANIST,
  appBarTheme: AppBarTheme(elevation: 0, backgroundColor: kPrimaryColor),
  splashColor: kPrimaryColor.withValues(alpha: 0.1),
  highlightColor: kPrimaryColor.withValues(alpha: 0.1),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: kSecondaryColor.withValues(alpha: 0.1),
  ),
  useMaterial3: false,
  textSelectionTheme: TextSelectionThemeData(cursorColor: kTertiaryColor),
);
