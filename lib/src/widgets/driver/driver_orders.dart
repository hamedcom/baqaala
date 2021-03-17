import 'package:baqaala/src/models/order.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/widgets/admin/admin_store_order_details.dart';
import 'package:baqaala/src/widgets/customer_support/customer_support_order_details.dart';
import 'package:baqaala/src/widgets/driver/driver_order_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DriverOrders extends StatefulWidget {
  final String driverId;
  DriverOrders({
    Key key,
    this.driverId,
  }) : super(key: key);

  @override
  _DriverOrdersState createState() => _DriverOrdersState();
}

class _DriverOrdersState extends State<DriverOrders>
    with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    // SetStatusbarTransparent(true);

    super.initState();
    controller = new TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Orders',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          brightness: Brightness.light,
          bottom: TabBar(
            labelPadding: EdgeInsets.only(bottom: 10, top: 10),
            labelColor: Colors.indigo[600],
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelColor: Colors.black,
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            indicatorWeight: 2,
            // indicatorColor: Colors.tealAccent,
            controller: controller,
            tabs: <Widget>[
              Text(
                'Active',
              ),
              Text(
                'Completed',
              ),
              Text(
                'All Orders',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: controller,
          children: <Widget>[
            PendingBookings(),
            CompletedBookings(),
            AllBookings(),
          ],
        ));
  }
}

class PendingBookings extends StatefulWidget {
  @override
  _PendingBookingsState createState() => _PendingBookingsState();
}

class _PendingBookingsState extends State<PendingBookings> {
  @override
  Widget build(BuildContext context) {
    final AuthModel auth = Provider.of<AuthModel>(context);

    return StreamBuilder(
      stream: Firestore.instance
          .collection('orders')
          .where('driverId', isEqualTo: auth.fUser.uid)
          .where('orderStatus', isEqualTo: 'Pending')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        switch (snap.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:

          case ConnectionState.done:
            if (snap.data.documents.length > 0) {
              return ListView(
                children: _orderList(snap, context, showProgress: false),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/images/not-found.svg',
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.6,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Text(
                      "No Orders In Pending",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                  ],
                ),
              );
            }
        }

        return SizedBox();
      },
    );
  }
}

List<Widget> _orderList(AsyncSnapshot snapshot, BuildContext context,
    {bool showProgress}) {
  return snapshot.data.documents.map<Widget>((document) {
    Order order = Order.fromSnapShot(document);
    var format = DateFormat('MMM d, ' 'yyyy,  hh:mm aaa');
    var dateString = format.format(order.createdAt);
    Color textColor;
    switch (order.statusMessage) {
      case 'Pending Confirmation':
        textColor = Colors.pink[900];
        break;
      case 'Order Confirmed':
        textColor = Colors.green[800];
    }
    return GestureDetector(
      onTap: () {
        Get.to(DriverOrderDetails(
          orderId: order.id,
        ));
        // print('hello');
      },
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        padding: EdgeInsets.all(10),
        width: double.infinity,
        // height: 100,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300], width: 2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('No:# ${order.orderNumber}'),
                Text('Date: $dateString'),
              ],
            ),
            Text('Total : ${order.total + 10} QAR'),
            Text('Total Items : ${order.totalItems}'),
            Text(
                'Customer : ${order.customer.name} (${order.customer.mobile.toString().substring(3)})'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(''),
                Text(
                  'Status : ${order.statusMessage}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }).toList();
}

class CompletedBookings extends StatefulWidget {
  @override
  _CompletedBookingsState createState() => _CompletedBookingsState();
}

class _CompletedBookingsState extends State<CompletedBookings> {
  @override
  Widget build(BuildContext context) {
    final AuthModel auth = Provider.of<AuthModel>(context);

    return StreamBuilder(
      stream: Firestore.instance
          .collection('orders')
          .where('driverId', isEqualTo: auth.fUser.uid)
          .where('orderStatus', isEqualTo: 'Completed')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        switch (snap.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:

          case ConnectionState.done:
            if (snap.data.documents.length > 0) {
              return ListView(
                children: _orderList(snap, context, showProgress: false),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/images/not-found.svg',
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.6,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Text(
                      "No Completed Orders",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                  ],
                ),
              );
            }
          // print(snap.data.documents[0]['userID']);
          // return ListView(
          //   children: _bookingList(snap, context, showProgress: false),
          // );
        }

        return SizedBox();
      },
    );
  }
}

class AllBookings extends StatefulWidget {
  @override
  _AllBookingsState createState() => _AllBookingsState();
}

class _AllBookingsState extends State<AllBookings> {
  @override
  Widget build(BuildContext context) {
    final AuthModel auth = Provider.of<AuthModel>(context);

    return StreamBuilder(
      stream: Firestore.instance
          .collection('orders')
          .where('driverId', isEqualTo: auth.fUser.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        switch (snap.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:

          case ConnectionState.done:
            if (snap.data.documents.length > 0) {
              return ListView(
                children: _orderList(snap, context, showProgress: false),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/images/not-found.svg',
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.6,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Text(
                      "No Orders",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                  ],
                ),
              );
            }
          // print(snap.data.documents[0]['userID']);
          // return ListView(
          //   children: _bookingList(snap, context, showProgress: false),
          // );
        }

        return SizedBox();
      },
    );
  }
}
