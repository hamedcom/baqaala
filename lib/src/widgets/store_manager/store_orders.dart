import 'package:flutter/material.dart';

class StoreOrders extends StatefulWidget {
  StoreOrders({Key key}) : super(key: key);

  @override
  _StoreOrdersState createState() => _StoreOrdersState();
}

class _StoreOrdersState extends State<StoreOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Admin Console',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Text('Admin Console'),
      ),
    );
  }
}
