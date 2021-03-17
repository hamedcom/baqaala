import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/widgets/customer_support/customer_support_orders.dart';
import 'package:baqaala/src/widgets/user/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CustomerSupportHome extends StatefulWidget {
  CustomerSupportHome({Key key}) : super(key: key);

  @override
  _CustomerSupportHomeState createState() => _CustomerSupportHomeState();
}

class _CustomerSupportHomeState extends State<CustomerSupportHome> {
  int _pendingOrders = 0;
  @override
  Widget build(BuildContext context) {
    final AuthModel _auth = Provider.of<AuthModel>(context);
    if (!_auth.checkRole('customer_support')) {
      Future.delayed(Duration(milliseconds: 200), () {
        Get.off(Home(
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
          appBar: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              'Customer Support',
              style: TextStyle(color: Colors.black),
            ),
            iconTheme: IconThemeData(color: Colors.black),
            elevation: 0,
          ),
          body: ListView(
            padding: EdgeInsets.all(15),
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              _gotoStore(),
              SizedBox(
                height: 20,
              ),
              _firstRow(),
            ],
          )),
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
        Get.off(Home(
          autoRedirect: false,
        ));
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
            title: 'Orders',
            subTitle:
                _pendingOrders > 0 ? '($_pendingOrders) Orders Waiting' : null,
            size: size,
            icon: Icons.receipt,
            page: CustomerSupportOrders()),
        _tile(
            color: Colors.amber[900],
            title: 'Messages',
            subTitle: null,
            size: size,
            icon: Icons.notifications,
            page: null
            // page: AdminSelectStoreCategory(),
            ),
      ],
    );
  }
}
