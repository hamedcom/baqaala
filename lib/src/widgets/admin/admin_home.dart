import 'package:baqaala/src/models/app_settings.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/widgets/admin/admin_complaints.dart';
import 'package:baqaala/src/widgets/admin/admin_notifications.dart';
import 'package:baqaala/src/widgets/admin/admin_orders.dart';
import 'package:baqaala/src/widgets/admin/admin_products.dart';
import 'package:baqaala/src/widgets/admin/admin_promotions.dart';
import 'package:baqaala/src/widgets/admin/admin_reports.dart';
import 'package:baqaala/src/widgets/admin/admin_select_store_category.dart';
import 'package:baqaala/src/widgets/admin/admin_store_orders.dart';
import 'package:baqaala/src/widgets/admin/admin_stores.dart';
import 'package:baqaala/src/widgets/admin/admin_suggestions.dart';
import 'package:baqaala/src/widgets/admin/admin_users.dart';
import 'package:baqaala/src/widgets/admin/app_settings.dart';
import 'package:baqaala/src/widgets/auth/login.dart';
import 'package:baqaala/src/widgets/common/product_search.dart';
import 'package:baqaala/src/widgets/user/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AdminHome extends StatefulWidget {
  AdminHome({Key key}) : super(key: key);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    final AuthModel _auth = Provider.of<AuthModel>(context);
    if (!_auth.checkRole('admin')) {
      Future.delayed(Duration(milliseconds: 200), () {
        Get.offAll(Home(
          autoRedirect: true,
        ));
      });
    }
    return WillPopScope(
      onWillPop: () async {
        print('hello');
        return Future.value(false);
      },
      child: Scaffold(
        // appBar: AppBar(
        //   brightness: Brightness.light,
        //   backgroundColor: Colors.transparent,
        //   centerTitle: true,
        //   title: Text(
        //     'Admin',
        //     style: TextStyle(color: Colors.black),
        //   ),
        //   iconTheme: IconThemeData(color: Colors.black),
        //   elevation: 0,
        // ),
        body: ListView(
          padding: EdgeInsets.all(15),
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Text('Hello, ${_auth.fUser?.name}',
                softWrap: true,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
            SizedBox(
              height: 20,
            ),
            _gotoStore(),
            SizedBox(
              height: 20,
            ),
            _todayOrders(),
            SizedBox(
              height: 20,
            ),
            _firstRow(),
            SizedBox(
              height: 20,
            ),
            _secondRow(),
            SizedBox(
              height: 20,
            ),
            _thirdRow(),
            SizedBox(
              height: 20,
            ),
            _fifthRow(),
            SizedBox(
              height: 20,
            ),
            _fourthRow(),
            SizedBox(
              height: 20,
            ),
            _logout(),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _gotoStore() {
    return GestureDetector(
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[350],
                offset: Offset(0, 0),
                blurRadius: 5,
              ),
            ],
            gradient: LinearGradient(colors: [
              Colors.orange,
              Colors.pink,
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(
          child: Text(
            'Go To Online Store',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
      ),
      onTap: () {
        Get.offAll(Home(
          autoRedirect: false,
        ));
      },
    );
  }

  Widget _logout() {
    final AuthModel _auth = Provider.of<AuthModel>(context, listen: false);

    return GestureDetector(
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[350],
                offset: Offset(0, 0),
                blurRadius: 5,
              ),
            ],
            gradient: LinearGradient(colors: [
              Colors.red,
              Colors.purple,
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(
          child: Text(
            'Log Out',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
      ),
      onTap: () async {
        await _auth.signOut();
        Get.offAll(Login());
      },
    );
  }

  Widget _tile(
      {double size,
      IconData icon,
      String title,
      String subTitle,
      bool replaceRoute = false,
      Color color,
      Widget page}) {
    final AuthModel auth = Provider.of<AuthModel>(context);
    return Container(
      height: size,
      width: size,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[350],
            offset: Offset(0, 0),
            blurRadius: 25,
          ),
        ],
        color: Colors.white,
      ),
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: color,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 17, color: color),
            ),
            SizedBox(
              height: subTitle != null ? 5 : 0,
            ),
            subTitle != null
                ? Text(
                    subTitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  )
                : SizedBox()
          ],
        ),
        onTap: () {
          if (replaceRoute) {
            Get.off(Home(
              autoRedirect: false,
            ));
            // auth.signOut();
          } else {
            Get.to(page);
          }
        },
      ),
    );
  }

  Widget _firstRow() {
    double size = MediaQuery.of(context).size.width * .43;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _tile(
            color: Colors.blue[800],
            title: 'Users',
            subTitle: '( 29000 )',
            size: size,
            icon: Icons.supervisor_account,
            page: AdminUsers()),
        _tile(
          color: Colors.amber[900],
          title: 'Stores',
          subTitle: '3 Stores',
          size: size,
          icon: Icons.store,
          page: AdminStores(),
          // page: AdminSelectStoreCategory(),
        ),
      ],
    );
  }

  Widget _secondRow() {
    double size = MediaQuery.of(context).size.width * .43;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _tile(
            color: Colors.cyan[800],
            title: 'Products',
            subTitle: '( 32100 )',
            size: size,
            icon: Icons.image,
            page: AdminProducts()),
        _tile(
            color: Colors.purple[800],
            title: 'Orders',
            subTitle: '( 1565523 )',
            size: size,
            icon: Icons.receipt,
            page: AdminOrders()),
        // page: AdminOrders()),
      ],
    );
  }

  Widget _thirdRow() {
    double size = MediaQuery.of(context).size.width * .43;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _tile(
            color: Colors.orange[800],
            title: 'Suggestions',
            subTitle: '',
            size: size,
            icon: Icons.info,
            page: AdminSuggestions()),
        // page: AdminComplaints()),
        _tile(
            color: Colors.teal[800],
            title: 'App Settings',
            size: size,
            icon: Icons.settings,
            page: AdminAppSettings()),
      ],
    );
  }

  Widget _fifthRow() {
    double size = MediaQuery.of(context).size.width * .43;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _tile(
            color: Colors.deepPurple,
            title: 'Promotions',
            size: size,
            icon: Icons.bookmark,
            page: AdminPromotions()),
        _tile(
            color: Colors.pink,
            title: 'Notifications',
            size: size,
            icon: Icons.notifications,
            page: AdminNotifications()),
      ],
    );
  }

  Widget _fourthRow() {
    double size = MediaQuery.of(context).size.width * .43;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _tile(
            color: Colors.brown[800],
            title: 'Reports',
            size: size,
            icon: Icons.table_chart,
            page: AdminReports()),
        _tile(
            color: Colors.blue[800],
            title: 'Exit',
            size: size,
            replaceRoute: true,
            icon: Icons.exit_to_app,
            page: Home(
              autoRedirect: false,
            )),
      ],
    );
  }

  Widget _todayOrders() {
    return Container(
      height: 225,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //     colors: [Colors.green[100], Colors.blue[100]],
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[350],
            offset: Offset(0, 0),
            blurRadius: 25,
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Today',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[800]),
              ),
              Text(
                '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    '15',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                        color: Colors.green[900]),
                  ),
                  Text(
                    'Total Orders',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text(
                    '4,505',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                        color: Colors.green[900]),
                  ),
                  Text(
                    'Total Value (QAR)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            thickness: 1,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text('8',
                        style: TextStyle(
                            color: Colors.green[800],
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(
                      'Delivered',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ],
                ),
                VerticalDivider(
                  // color: Colors.red,
                  thickness: 1,
                ),
                Column(
                  children: <Widget>[
                    Text('1',
                        style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text('Cancelled', style: TextStyle(color: Colors.red[700])),
                  ],
                ),
                VerticalDivider(
                  // color: Colors.red,
                  thickness: 1,
                ),
                Column(
                  children: <Widget>[
                    Text(
                      '6',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text('Pending'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
