import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'src/common/constants.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Provider.debugCheckInvalidValueType = null;

  print('[MAIN] ===== STARTED.');

  if (!kIsWeb) {
    // Set Orientation to Only Portrait
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    // Setting Status Bar as transparent
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
  }

  runApp(
      // Using Easy Localization plugin for Translation using JSON Files.
      EasyLocalization(
          supportedLocales: [Locale('en'), Locale('ar')],
          path: 'assets/lang',
          fallbackLocale: Locale('en'),
          useOnlyLangCode: true,
          saveLocale: true,
          child: App()));
}
