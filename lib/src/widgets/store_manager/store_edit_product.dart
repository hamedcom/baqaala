import 'package:flutter/material.dart';

class StoreEditProduct extends StatefulWidget {
  StoreEditProduct({Key key}) : super(key: key);

  @override
  _StoreEditProductState createState() => _StoreEditProductState();
}

class _StoreEditProductState extends State<StoreEditProduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Edit Product',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Text('Edit Product'),
      ),
    );
  }
}
