import 'package:baqaala/src/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminUserSelect extends StatefulWidget {
  final String role;
  AdminUserSelect({Key key, this.role}) : super(key: key);

  @override
  _AdminUserSelectState createState() => _AdminUserSelectState();
}

class _AdminUserSelectState extends State<AdminUserSelect> {
  bool _isUserFound;
  User _user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Find User',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Container(
          width: Get.width,
          height: Get.height,
          child: Column(
            children: <Widget>[
              TextField(
                onChanged: (val) async {
                  if (val.length == 8) {
                    var mobile = '974$val';
                    print(mobile);
                    try {
                      var doc = await Firestore.instance
                          .collection('users')
                          .where('mobile', isEqualTo: int.parse(mobile))
                          .getDocuments();

                      if (doc.documents.isNotEmpty) {
                        User user = User.fromSnapShot(doc.documents[0]);
                        setState(() {
                          _user = user;
                          _isUserFound = true;
                        });
                      } else {
                        setState(() {
                          _isUserFound = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    prefix: Text('+974 '),
                    border: OutlineInputBorder(),
                    labelText: 'Enter Mobile Number'),
              ),
              _user != null ? _userCard() : SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  Widget _userCard() {
    String userType = 'User';
    final timeFormat = DateFormat("dd-MMM-yy hh:mm a");

    if (_user.roles['manager'] ?? false) {
      userType = 'Manager';
    }
    if (_user.roles['admin'] ?? false) {
      userType = 'Admin';
    }
    if (_user.roles['store_manager'] ?? false) {
      userType = 'Store Manager';
    }
    if (_user.roles['driver'] ?? false) {
      userType = 'Driver';
    }
    if (_user.roles['picker'] ?? false) {
      userType = 'Picker';
    }
    if (_user.roles['qc'] ?? false) {
      userType = 'Quality Controller';
    }
    if (_user.roles['investor'] ?? false) {
      userType = 'Investor';
    }
    if (_user.roles['customer_support'] ?? false) {
      userType = 'Customer Support';
    }

    return Card(
      elevation: 5,
      color: Colors.amber,
      child: ListTile(
        title: Text(_user.name),
        subtitle: Text('${_user.mobile} - ($userType)'),
        onTap: () {
          if (widget.role != null) {
            if (_user.roles[widget.role] ?? false) {
              Get.back(result: _user);
            } else {
              Get.snackbar('User Not Supported',
                  'User Is not a ${widget.role}, Contact Admin for support',
                  backgroundColor: Colors.red[800], colorText: Colors.white);
            }
          } else {
            Get.back(result: _user);
          }
        },
      ),
    );
  }
}
