import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/widgets/user/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class QualityControllerHome extends StatefulWidget {
  QualityControllerHome({Key key}) : super(key: key);

  @override
  _QualityControllerHomeState createState() => _QualityControllerHomeState();
}

class _QualityControllerHomeState extends State<QualityControllerHome> {
  @override
  Widget build(BuildContext context) {
    final AuthModel _auth = Provider.of<AuthModel>(context);
    if (!_auth.checkRole('qc')) {
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
          'QC Home',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Text('QC Home'),
      ),
    );
  }
}
