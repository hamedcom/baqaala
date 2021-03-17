import 'package:flutter/material.dart';

class NavigationService {
  GlobalKey<NavigatorState> navigatorKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigatorKey = GlobalKey<NavigatorState>();
    print('Navigator Key Set $navigatorKey');
  }

  Future<dynamic> navigateTo(String routeName, {dynamic args}) {
    return navigatorKey.currentState.pushNamed(routeName, arguments: args);
  }

  Future<dynamic> navigateToReplacement(String _routeName, {dynamic args}) {
    return navigatorKey.currentState
        .pushReplacementNamed(_routeName, arguments: args);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute _route) {
    return navigatorKey.currentState.push(_route);
  }

  void goBack() {
    return navigatorKey.currentState.pop();
  }
}
