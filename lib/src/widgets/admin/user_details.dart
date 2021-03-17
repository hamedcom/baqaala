import 'package:baqaala/src/models/user.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class UserDetails extends StatefulWidget {
  final String uid;

  UserDetails({Key key, this.uid}) : super(key: key);

  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final _db = Firestore.instance;
  User _fuser;
  bool _isLoading = true;

  List<String> urls = [];

  @override
  void initState() {
    super.initState();

    _getProviderDetails();
  }

  void _getProviderDetails() {
    _db.collection('users').document(widget.uid).snapshots().listen((data) {
      setState(() {
        _fuser = User.fromSnapShot(data);
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue[900]),
        title: Text('User Details',
            style: TextStyle(
              color: Colors.black,
            )),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _detailsCard(),
    );
  }

  Widget _detailsCard() {
    final auth = Provider.of<AuthModel>(context);
    return Card(
        elevation: 2,
        margin: EdgeInsets.all(10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Name : ${_fuser.name}',
                  style: TextStyle(color: Colors.grey[800], fontSize: 22),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Mobile : ${_fuser.mobile.toString()}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // FlatButton(
                    //   color: Colors.green,
                    //   child: Row(
                    //     children: <Widget>[
                    //       Icon(
                    //         Icons.call,
                    //         color: Colors.white,
                    //       ),
                    //       SizedBox(
                    //         width: 10,
                    //       ),
                    //       Text(
                    //         'CALL',
                    //         style: TextStyle(color: Colors.white),
                    //       ),
                    //     ],
                    //   ),
                    //   onPressed: () {
                    //     // launch('tel:+${_truckProvider.mobile.toString()}');
                    //   },
                    // )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Status : ${_fuser.status}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                (auth.checkRole('admin') && auth.fUser.uid != _fuser.uid)
                    ? ListTile(
                        title: Text('Assign Role'),
                        subtitle: Text(
                            'Current Role : ${auth.getRole(_fuser.roles)}'),
                        onTap: () async {
                          Get.bottomSheet(_rolesBottomSheet(_fuser));
                        },
                      )
                    : SizedBox()
              ],
            ),
          ),
        ));
  }

  Widget _rolesBottomSheet(User user) {
    final AuthModel _auth = Provider.of<AuthModel>(context, listen: false);
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5), topRight: Radius.circular(5)),
      ),
      child: ListView(
        padding: const EdgeInsets.only(left: 15, right: 10, top: 5),
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Text(
            'Select Role',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Divider(),
          ListTile(
            title: Text('Admin'),
            // trailing: _auth.checkRole('admin')
            //     ? Icon(
            //         Icons.check_circle,
            //         color: Colors.green[600],
            //       )
            //     : SizedBox(),
            onTap: () {
              _auth.assignRole(user, 'admin');
              Get.back();
            },
          ),
          Divider(),
          ListTile(
            title: Text('Manager'),
            // trailing: _auth.checkRole('manager')
            //     ? Icon(
            //         Icons.check_circle,
            //         color: Colors.green[600],
            //       )
            //     : SizedBox(),
            onTap: () {
              _auth.assignRole(user, 'manager');
              Get.back();
            },
          ),
          Divider(),
          ListTile(
            title: Text('Store Manager'),
            // trailing: _auth.checkRole('store_manager')
            //     ? Icon(
            //         Icons.check_circle,
            //         color: Colors.green[600],
            //       )
            //     : SizedBox(),
            onTap: () {
              print('store_manager');
              _auth.assignRole(user, 'store_manager');
              Get.back();
            },
          ),
          Divider(),
          ListTile(
            title: Text('Picker'),
            // trailing: _auth.checkRole('picker')
            //     ? Icon(
            //         Icons.check_circle,
            //         color: Colors.green[600],
            //       )
            //     : SizedBox(),
            onTap: () {
              print('picker');
              _auth.assignRole(user, 'picker');
              Get.back();
            },
          ),
          Divider(),
          ListTile(
            title: Text('Driver'),
            // trailing: _auth.checkRole('driver')
            //     ? Icon(
            //         Icons.check_circle,
            //         color: Colors.green[600],
            //       )
            //     : SizedBox(),
            onTap: () {
              print('driver');
              _auth.assignRole(user, 'driver');
              Get.back();
            },
          ),
          Divider(),
          ListTile(
            title: Text('Quality Controller'),
            // trailing: _auth.checkRole('qc')
            //     ? Icon(
            //         Icons.check_circle,
            //         color: Colors.green[600],
            //       )
            //     : SizedBox(),
            onTap: () {
              print('qc');
              _auth.assignRole(user, 'qc');
              Get.back();
            },
          ),
          Divider(),
          ListTile(
            title: Text('Customer Support'),
            // trailing: _auth.checkRole('customer_support')
            //     ? Icon(
            //         Icons.check_circle,
            //         color: Colors.green[600],
            //       )
            //     : SizedBox(),
            onTap: () {
              print('customer_support');
              _auth.assignRole(user, 'customer_support');
              Get.back();
            },
          ),
          Divider(),
          ListTile(
            title: Text('Investor'),
            // trailing: _auth.checkRole('investor')
            //     ? Icon(
            //         Icons.check_circle,
            //         color: Colors.green[600],
            //       )
            //     : SizedBox(),
            onTap: () {
              print('investor');
              _auth.assignRole(user, 'investor');
              Get.back();
            },
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
