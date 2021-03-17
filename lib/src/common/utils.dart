import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert' as convert;

import 'constants.dart';

class Utils {
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static void setStatusBarWhiteForeground(bool active) {
    if (kIsWeb == true) {
      return;
    }

    FlutterStatusbarcolor.setStatusBarWhiteForeground(active);
  }

  static String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  static String getStringFromTime(TimeOfDay time) {
    if (time == null) return null;
    String hour, min;
    if (time.hour < 10)
      hour = '0${time.hour}';
    else
      hour = '${time.hour}';

    if (time.minute < 10)
      min = '0${time.minute}';
    else
      min = '${time.minute}';
    return '$hour:$min';
  }

  static TimeOfDay getTimefromString(String time) {
    if (time == null) return null;
    List<String> t = time.split(':');
    return TimeOfDay(hour: int.parse(t[0]), minute: int.parse(t[1]));
  }

  static String latlngString(List<LatLng> latlanglist) {
    if (latlanglist.length > 1) {
      String path = '';
      latlanglist.forEach((element) {
        path = path + '${element.latitude}_${element.longitude},';
      });
      path = path + '${latlanglist[0].latitude}_${latlanglist[0].longitude}';
      return path;
    } else {
      return null;
    }
  }

  static List<LatLng> stringToLatLngList(String polyPath) {
    List<LatLng> latList = [];
    if (polyPath != null) {
      List<String> list = polyPath.split(',');
      list.forEach((element) {
        List<String> latlng = element.split('_');
        if (latlng.isNotEmpty) {
          // print(latlng);
          latList.add(
              LatLng(double.tryParse(latlng[0]), double.tryParse(latlng[1])));
        }
      });
      return latList;
    } else {
      return null;
    }
  }

  static void setStatusbarColor(Color color,
      [bool foregroundWhite = false]) async {
    await FlutterStatusbarcolor.setStatusBarColor(color);
    if (foregroundWhite == false) {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    } else {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(foregroundWhite);
    }
  }

  static void setStatusbarTransparent([bool foregroundWhite = false]) async {
    await FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(foregroundWhite);
  }

  static String cleanStorageUrl(String url) {
    List<String> urls = url.split('alt=media');
    String finalUrl = urls[0] + 'alt=media';
    return finalUrl;
  }

  static String getImageLinkBySku(String sku) {
    String link =
        "https://firebasestorage.googleapis.com/v0/b/baqaala-new.appspot.com/o/pimages%2F" +
            "$sku.jpg?alt=media";

    print(link);
    return link;
  }

  static String getStorageUrl({String bucket, String filename}) {
    if (bucket == null) bucket = 'baqaala-new.appspot.com';
    return 'https://storage.cloud.google.com/$bucket/$filename';
  }

  static Future<dynamic> parseJsonFromAssets(String assetsPath) async {
    return rootBundle.loadString(assetsPath).then(convert.jsonDecode);
  }

  static Map<String, String> getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'ERROR_WRONG_PASSWORD':
        return {'Wrong Password': 'Please Enter Correct Password.'};
      case 'ERROR_TOO_MANY_REQUESTS':
        return {'Too Many Requests': 'Please Wait sometime and try again.'};
      case 'ERROR_USER_NOT_FOUND':
        return {'User not Found': 'Please check your mobile number again'};
      case 'ERROR_USER_DISABLED':
        return {'User Disabled': 'Please Contact our Customer Support'};
      case 'ERROR_NETWORK_REQUEST_FAILED':
        return {'Network Error': 'Please Check your internet connection'};
      case 'ERROR_OPERATION_NOT_ALLOWED':
        return {'Operation Not Allowed': 'This Operation Not Allowed'};
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        return {'User Already Exists': 'Mobile number Already Exists'};
      case 'ERROR_WEAK_PASSWORD':
        return {'Weak Password': 'Please Enter Strong Password'};
      case 'ERROR_INVALID_EMAIL':
        return {'Invalid Email': 'Invalid Email Address'};
      case 'ERROR_NETWORK_REQUEST_FAILED':
        return {'Network Error': 'Please Check your internet connection'};
      default:
        return {'Unknown Error': 'Please Contact our Customer Support'};
    }
  }
}
