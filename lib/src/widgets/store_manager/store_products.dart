import 'package:flutter/material.dart';

class StoreProducts extends StatefulWidget {
  StoreProducts({Key key}) : super(key: key);

  @override
  _StoreProductsState createState() => _StoreProductsState();
}

class _StoreProductsState extends State<StoreProducts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Store Products',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Text('Store Products'),
      ),
    );
  }
}
