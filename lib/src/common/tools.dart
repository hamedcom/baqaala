import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'constants.dart';

enum kSize { small, medium, large }

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class Tools {
  static double formatDouble(dynamic value) => value * 1.0;

  // Like 2 Hour ago
  static formatDateString(String date) {
    DateTime timeFormat = DateTime.parse(date);
    final timeDif = DateTime.now().difference(timeFormat);
    return timeago.format(DateTime.now().subtract(timeDif), locale: 'en');
  }

  static bool isTablet(MediaQueryData query) {
    if (kIsWeb) {
      return true;
    }

    if (Platform.isWindows || Platform.isMacOS) {
      return false;
    }

    var size = query.size;
    var diagonal =
        sqrt((size.width * size.width) + (size.height * size.height));
    var isTablet = diagonal > 1100.0;
    return isTablet;
  }
}
