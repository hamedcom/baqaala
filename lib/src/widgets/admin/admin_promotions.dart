import 'package:flutter/material.dart';

class AdminPromotions extends StatefulWidget {
  AdminPromotions({Key key}) : super(key: key);

  @override
  _AdminPromotionsState createState() => _AdminPromotionsState();
}

class _AdminPromotionsState extends State<AdminPromotions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Admin Promotions',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Text('Admin Promotions'),
      ),
    );
  }
}
