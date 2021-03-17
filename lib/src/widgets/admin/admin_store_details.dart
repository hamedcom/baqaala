import 'package:flutter/material.dart';

class AdminStoreDetails extends StatefulWidget {
  AdminStoreDetails({Key key}) : super(key: key);

  @override
  _AdminStoreDetailsState createState() => _AdminStoreDetailsState();
}

class _AdminStoreDetailsState extends State<AdminStoreDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Admin Store Details',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Text('Store Details'),
      ),
    );
  }
}
