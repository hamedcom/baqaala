import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:baqaala/providers.dart';
import 'package:baqaala/src/widgets/common/check_connectivity.dart';
import 'package:baqaala/src/widgets/common/splash_screen.dart';
import 'package:baqaala/src/widgets/customer_support/customer_support_order_details.dart';
import 'package:baqaala/src/widgets/firebase/firebase_messaging_wrapper.dart';
import 'package:baqaala/src/widgets/store_manager/store_order_details.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'src/widgets/common/dialogs.dart';
import 'src/widgets/driver/driver_order_details.dart';
import 'src/widgets/firebase/firebase_analytics_wrapper.dart';
import 'src/widgets/picker/picker_order_details.dart';

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> implements FirebaseMessagingDelegate {
  FirebaseAnalyticsAbs firebaseAnalyticsAbs;
  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  void initState() {
    super.initState();
    print('[APP] === Initiated');

    firebaseAnalyticsAbs = FirebaseAnalyticsWrapper()..init();

    Future.delayed(Duration(seconds: 1), () {
      print("[AppState] init mobile modules ..");

      FirebaseMessagingWrapper()
        ..init()
        ..delegate = this;

      // Check Net Connectivity
      // MyConnectivity.instance.initialise();

      // MyConnectivity.instance.myStream.listen((onData) {
      //   print("[App] internet issue change: $onData");

      //   if (MyConnectivity.instance.isIssue(onData)) {
      //     if (MyConnectivity.instance.isShow == false) {
      //       MyConnectivity.instance.isShow = true;

      //       showDialogNotInternet(context).then((onValue) {
      //         MyConnectivity.instance.isShow = false;
      //         print("[showDialogNotInternet] dialog closed $onValue");
      //       });

      //       MyConnectivity.instance.isShow = false;
      //       print("[showDialogNotInternet] dialog closed ");
      //     }
      //   } else {
      //     if (MyConnectivity.instance.isShow == true) {
      //       // Navigator.of(context).pop();
      //       MyConnectivity.instance.isShow = false;
      //     }
      //   }
      // });

      print("[AppState] register modules .. DONE");
    });
  }

  @override
  Widget build(BuildContext context) {
    // Provider as State Manangement
    return MultiProvider(
      providers: providers,
      child:
          // Get Plugin for Systemwide Snackbar and Dailog without context errors and some handy features
          GetMaterialApp(
        debugShowCheckedModeBanner: false,
        // localizationsDelegates: context.localizationDelegates,
        // supportedLocales: context.supportedLocales,
        // locale: context.locale,
        transitionDuration: Duration(milliseconds: 200),
        defaultTransition: Transition.cupertino,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        home: SplashScreen(),
      ),
    );
  }

  // Firebase Notification Handling

  @override
  onLaunch(Map<String, dynamic> message) {
    print('message on launnch received $message');
    processMessage(message);
  }

  @override
  onResume(Map<String, dynamic> message) {
    print('message on resume received $message');
    processMessage(message);
  }

  @override
  onMessage(Map<String, dynamic> message) {
    print('message on message received $message');
    var title, body;

    if (Platform.isIOS) {
      title = message['aps']['alert']['title'];
      body = message['aps']['alert']['body'];
      print('IOS Found');
    } else {
      title = message['notification']['title'];
      body = message['notification']['body'];
    }
    print(title);

    AudioCache player = AudioCache();
    player.play(
      'sounds/oh-finally.mp3',
    );

    Get.snackbar(title, body,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[800],
        colorText: Colors.white,
        mainButton: TextButton(
          child: Text(
            'View',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            processMessage(message);
          },
        ),
        duration: Duration(seconds: 6), onTap: (obj) {
      processMessage(message);
    });
    setState(() {});
  }

  void processMessage(Map<String, dynamic> message) {
    var type, id;
    if (Platform.isIOS) {
      type = message['type'];
      id = message['documentID'];
      print('IOS Found');
    } else {
      type = message['data']['type'];
      id = message['data']['documentID'];
    }
    if (type != null) {
      switch (type) {
        case 'new_order':
          Get.to(StoreOrderDetails(
            orderId: id,
          ));
          break;

        case 'new_order_picker':
          Get.to(PickerOrderDetails(
            orderId: id,
          ));
          break;
        case 'new_order_driver':
          Get.to(DriverOrderDetails(
            orderId: id,
          ));
          break;

        case 'new_order_customer_support':
          Get.to(CustomerSupportOrderDetails(
            orderId: id,
          ));
          break;

        default:
          print(type);
          break;
      }
    }
  }
}
