import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/widgets/common/insta_item.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AdminAppSettings extends StatefulWidget {
  AdminAppSettings({Key key}) : super(key: key);

  @override
  _AdminAppSettingsState createState() => _AdminAppSettingsState();
}

class _AdminAppSettingsState extends State<AdminAppSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'App Settings',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[InstantItem(), InstantItem()],
        ),
      ),
    );
  }
}
