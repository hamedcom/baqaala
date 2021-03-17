import 'package:flutter/material.dart';

class StoreAddProduct extends StatefulWidget {
  StoreAddProduct({Key key}) : super(key: key);

  @override
  _StoreAddProductState createState() => _StoreAddProductState();
}

class _StoreAddProductState extends State<StoreAddProduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Add Product',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Text('Add Product'),
      ),
    );
  }
}
