import 'package:baqaala/src/providers/app_provider.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/widgets/admin/admin_home.dart';
import 'package:baqaala/src/widgets/auth/login.dart';
import 'package:baqaala/src/widgets/customer_support/customer_support_home.dart';
import 'package:baqaala/src/widgets/driver/driver_home.dart';
import 'package:baqaala/src/widgets/investor/investor_home.dart';
import 'package:baqaala/src/widgets/manager/manager_home.dart';
import 'package:baqaala/src/widgets/picker/picker_home.dart';
import 'package:baqaala/src/widgets/quality_controller/quality_controller_home.dart';
import 'package:baqaala/src/widgets/store_manager/store_console.dart';
import 'package:baqaala/src/widgets/user/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:after_layout/after_layout.dart';

/* 
  This File Handles All The functionalities like Showing Onboarding Screen if Not Seen
  And Later Login Screen
  If Login Check the role of user and send to preffered screen acordingly

*/

class AppInit extends StatefulWidget {
  AppInit({Key key}) : super(key: key);

  @override
  _AppInitState createState() => _AppInitState();
}

class _AppInitState extends State<AppInit> with AfterLayoutMixin<AppInit> {
  bool isFirstSeen = false;
  String _nextScreen = 'login';

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = prefs.getBool('seen') ?? false;
    return _seen;
  }

  @override
  Widget build(BuildContext context) {
    return onNextScreen();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    await initApp();
  }

  Widget onNextScreen() {
    switch (_nextScreen) {
      case 'admin_console':
        return AdminHome();

      case 'store_console':
        return StoreConsole();

      case 'manager_console':
        return ManagerHome();

      case 'qc_console':
        return QualityControllerHome();

      case 'picker_console':
        return PickerHome();

      case 'driver_console':
        return DriverHome();

      case 'customer_support_console':
        return CustomerSupportHome();

      case 'investor_console':
        return InvestorHome();

      case 'home':
        return Home(
          autoRedirect: true,
        );
      // return HomePage();
      // return THomePage();
      case 'login':
        return Login();

      default:
        return Login();
    }
  }

  Future<void> initApp() async {
    final _settings = Provider.of<AppSettingsProvider>(context, listen: false);
    final _auth = Provider.of<AuthModel>(context, listen: false);
    // final _auth = Provider.of<AuthProvider>(context, listen: false);
    if (_auth.authStatus == Status.Authenticated) {
      if (_auth.checkRole('admin')) {
        _nextScreen = 'admin_console';
      } else if (_auth.checkRole('store_manager')) {
        _nextScreen = 'store_console';
      } else if (_auth.checkRole('manager')) {
        _nextScreen = 'manager_console';
      } else if (_auth.checkRole('qc')) {
        _nextScreen = 'qc_console';
      } else if (_auth.checkRole('investor')) {
        _nextScreen = 'investor_console';
      } else if (_auth.checkRole('picker')) {
        _nextScreen = 'picker_console';
      } else if (_auth.checkRole('driver')) {
        _nextScreen = 'driver_console';
      } else if (_auth.checkRole('customer_support')) {
        _nextScreen = 'customer_support_console';
      } else {
        _nextScreen = 'home';
      }

      setState(() {});
    } else if (_settings.appSettings.isLoginNeeded) {
      setState(() {
        _nextScreen = 'login';
      });
      print('Login Needed');
    } else {
      setState(() {
        _nextScreen = 'login';
      });
      print('Login Not Required');
    }
    print(_settings.appSettings.appName);
  }
}
