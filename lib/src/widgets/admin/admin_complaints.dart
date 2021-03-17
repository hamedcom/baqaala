import 'package:flutter/material.dart';

class AdminComplaints extends StatefulWidget {
  AdminComplaints({Key key}) : super(key: key);

  @override
  _AdminComplaintsState createState() => _AdminComplaintsState();
}

class _AdminComplaintsState extends State<AdminComplaints> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Admin Complaints',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Text('Admin Complaints'),
      ),
    );
  }
}
