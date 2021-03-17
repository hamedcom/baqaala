import 'package:cloud_firestore/cloud_firestore.dart';

import 'base_provider.dart';
import '../../src/models/app_settings.dart';

/// With This file we can get App Settigs from firestore realtime
/// Like App Version Check for Updates
/// Server Time
///
///

class AppSettingsProvider extends BaseProvider {
  static AppSettingsProvider instance = AppSettingsProvider();

  AppSettings _appSettings;

  AppSettings get appSettings => _appSettings;

  AppSettingsProvider() {
    getSettingsStream().listen((doc) {
      if (doc.exists) {
        _appSettings = AppSettings.fromFirestore(doc);
        print(
            'ServerTime ${_appSettings.serverTime.hour}:${_appSettings.serverTime.minute}');
        notifyListeners();
      } else {
        _appSettings = AppSettings(
          appName: 'Baqaala',
          isInMaintananceMode: false,
          isDarkModeEnabled: false,
          isLoginNeeded: false,
          isVerifyNeeded: true,
          defaultLanguage: 'en',
          acceptNewOrders: true,
          acceptLogins: true,
          acceptNewRegistrations: true,
          codEnabled: true,
          cardPaymentEnabled: false,
        );
        notifyListeners();
        saveSettings(_appSettings);
      }
    });
  }

  Stream<DocumentSnapshot> getSettingsStream() {
    String field = 'app_settings';
    return db.collection('settings').document(field).snapshots();
  }

  void saveSettings(AppSettings settings) {
    String field = 'app_settings';
    db
        .collection('settings')
        .document(field)
        .setData(settings.toJSON(), merge: true);
  }
}
