import 'package:flutter/material.dart';

class PickerSelectProduct extends StatefulWidget {
  PickerSelectProduct({Key key}) : super(key: key);

  @override
  _PickerSelectProductState createState() => _PickerSelectProductState();
}

class _PickerSelectProductState extends State<PickerSelectProduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Select Product',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Text('Select Product'),
      ),
    );
  }
}
