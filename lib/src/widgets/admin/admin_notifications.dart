import 'package:flutter/material.dart';

class AdminNotifications extends StatefulWidget {
  AdminNotifications({Key key}) : super(key: key);

  @override
  _AdminNotificationsState createState() => _AdminNotificationsState();
}

class _AdminNotificationsState extends State<AdminNotifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Admin Notifications',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Text('Admin Notifications'),
      ),
    );
  }
}
