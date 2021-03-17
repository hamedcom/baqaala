import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/widgets/user/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ManagerHome extends StatefulWidget {
  ManagerHome({Key key}) : super(key: key);

  @override
  _ManagerHomeState createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  @override
  Widget build(BuildContext context) {
    final AuthModel _auth = Provider.of<AuthModel>(context);
    if (!_auth.checkRole('manager')) {
      Future.delayed(Duration(milliseconds: 200), () {
        Get.off(Home(
          autoRedirect: true,
        ));
      });
    }
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Manager Home',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Text('Manager Home'),
      ),
    );
  }
}
