import 'dart:io';

import 'package:baqaala/src/services/shared_pref.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

abstract class FirebaseMessagingDelegate {
  onMessage(Map<String, dynamic> message);
  onResume(Map<String, dynamic> message);
  onLaunch(Map<String, dynamic> message);
}

abstract class FirebaseMessagingAbs {
  init();
  FirebaseMessagingDelegate delegate;
}

class FirebaseMessagingWrapper extends FirebaseMessagingAbs {
  FirebaseMessaging _firebaseMessaging;

  @override
  @override
  init() {
    _firebaseMessaging = FirebaseMessaging();
    firebaseMessagingListeners();
    _firebaseMessaging.getToken().then((value) {
      print(value);
      SharedPrefs pref = SharedPrefs.instance;
      pref.setToken(value);

      // Get.snackbar('token', value);
    });
  }

  void firebaseMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) => delegate?.onMessage(message),
      onResume: (Map<String, dynamic> message) => delegate?.onResume(message),
      onLaunch: (Map<String, dynamic> message) => delegate?.onLaunch(message),
    );
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, alert: true, badge: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }
}
