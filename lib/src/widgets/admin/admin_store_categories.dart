import 'package:flutter/material.dart';

class AdminStoreCategories extends StatefulWidget {
  AdminStoreCategories({Key key}) : super(key: key);

  @override
  _AdminStoreCategoriesState createState() => _AdminStoreCategoriesState();
}

class _AdminStoreCategoriesState extends State<AdminStoreCategories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Selet Store Type',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Text('Store Types'),
      ),
    );
  }
}
