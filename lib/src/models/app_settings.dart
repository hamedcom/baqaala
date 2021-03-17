import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettings {
  String appName;
  int iosBuildNumber;
  int adroidBuildNumber;
  String updatePriority; // low, high
  String updateMessage;
  String updateMessageImagePath;
  bool isInMaintananceMode;
  bool acceptNewRegistrations;
  bool acceptLogins;
  bool acceptNewOrders;
  bool isLoginNeeded;
  bool isVerifyNeeded;
  String defaultLanguage;
  bool isDarkModeEnabled;
  bool codEnabled;
  bool cardPaymentEnabled;
  String googleMapsApiKey;
  DateTime serverTime;

  AppSettings({
    this.appName,
    this.iosBuildNumber,
    this.adroidBuildNumber,
    this.updatePriority,
    this.updateMessage,
    this.updateMessageImagePath,
    this.isInMaintananceMode,
    this.acceptLogins,
    this.acceptNewRegistrations,
    this.acceptNewOrders,
    this.isLoginNeeded,
    this.isVerifyNeeded,
    this.defaultLanguage,
    this.isDarkModeEnabled,
    this.codEnabled,
    this.cardPaymentEnabled,
    this.googleMapsApiKey,
    this.serverTime,
  });

  factory AppSettings.fromFirestore(DocumentSnapshot doc) {
    return AppSettings(
      appName: doc['appName'],
      iosBuildNumber: doc['iosBuildNumber'],
      adroidBuildNumber: doc['adroidBuildNumber'],
      updateMessage: doc['updateMessage'],
      updateMessageImagePath: doc['updateMessageImagePath'],
      isInMaintananceMode: doc['isInMaintananceMode'],
      acceptLogins: doc['acceptLogins'],
      acceptNewRegistrations: doc['acceptNewRegistrations'],
      updatePriority: doc['updatePriority'],
      acceptNewOrders: doc['acceptNewOrders'] ?? true,
      isLoginNeeded: doc['isLoginNeeded'] ?? false,
      isVerifyNeeded: doc['isVerifyNeeded'] ?? true,
      defaultLanguage: doc['defaultLanguage'] ?? 'en',
      isDarkModeEnabled: doc['isDarkModeEnabled'] ?? false,
      codEnabled: doc['codEnabled'] ?? true,
      cardPaymentEnabled: doc['cardPaymentEnabled'] ?? false,
      googleMapsApiKey: doc['googleMapsApiKey'],
      serverTime: doc['serverTime']?.toDate(),
    );
  }

  AppSettings.fromJson(Map<String, dynamic> doc) {
    appName = doc['appName'];
    iosBuildNumber = doc['iosBuildNumber'];
    adroidBuildNumber = doc['adroidBuildNumber'];
    updateMessage = doc['updateMessage'];
    updateMessageImagePath = doc['updateMessageImagePath'];
    isInMaintananceMode = doc['isInMaintananceMode'];
    acceptLogins = doc['acceptLogins'];
    acceptNewRegistrations = doc['acceptNewRegistrations'];
    updatePriority = doc['updatePriority'];
    acceptNewOrders = doc['acceptNewOrders'] ?? true;
    isLoginNeeded = doc['isLoginNeeded'] ?? false;
    isVerifyNeeded = doc['isVerifyNeeded'] ?? true;
    defaultLanguage = doc['defaultLanguage'] ?? 'en';
    isDarkModeEnabled = doc['isDarkModeEnabled'] ?? false;
    codEnabled = doc['codEnabled'] ?? true;
    cardPaymentEnabled = doc['cardPaymentEnabled'] ?? true;
    googleMapsApiKey = doc['googleMapsApiKey'];
    serverTime = doc['serverTime']?.toDate();
  }

  Map<String, dynamic> toJSON() => {
        'appName': appName,
        'iosBuildNumber': iosBuildNumber,
        'adroidBuildNumber': adroidBuildNumber,
        'updateMessage': updateMessage,
        'updatePriority': updatePriority,
        'updateMessageImagePath': updateMessageImagePath,
        'isInMaintananceMode': isInMaintananceMode,
        'acceptLogins': acceptLogins,
        'acceptNewRegistrations': acceptNewRegistrations,
        'acceptNewOrders': acceptNewOrders,
        'isLoginNeeded': isLoginNeeded,
        'isVerifyNeeded': isVerifyNeeded,
        'defaultLanguage': defaultLanguage,
        'isDarkModeEnabled': isDarkModeEnabled,
        'codEnabled': codEnabled,
        'cardPaymentEnabled': cardPaymentEnabled,
        'googleMapsApiKey': googleMapsApiKey,
        'serverTime': serverTime,
      };
}
