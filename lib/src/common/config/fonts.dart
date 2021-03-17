import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Google fonts constant setting: https://fonts.google.com/
///  This File Contains Text Themes for English and Arabic Languages
///
TextTheme kTextTheme(TextTheme theme, String language) {
  switch (language) {
    case 'en':
      return GoogleFonts.ralewayTextTheme(theme);
    case 'ar':
      return GoogleFonts.ralewayTextTheme(theme);
    default:
      return GoogleFonts.ralewayTextTheme(theme);
  }
}

TextTheme kHeadlineTheme(TextTheme theme, [language = 'en']) {
  switch (language) {
    case 'en':
      return GoogleFonts.ralewayTextTheme(theme);
    case 'ar':
      return GoogleFonts.ralewayTextTheme(theme);
    default:
      return GoogleFonts.ralewayTextTheme(theme);
  }
}
