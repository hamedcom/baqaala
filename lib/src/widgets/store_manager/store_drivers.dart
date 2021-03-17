import 'package:flutter/material.dart';

class StoreDrivers extends StatefulWidget {
  StoreDrivers({Key key}) : super(key: key);

  @override
  _StoreDriversState createState() => _StoreDriversState();
}

class _StoreDriversState extends State<StoreDrivers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Drivers',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Text('Drivers'),
      ),
    );
  }
}
