import 'package:baqaala/src/models/order.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'user_order_detail.dart';

class UserOrders extends StatefulWidget {
  final bool showOnlyPendingOrders;
  UserOrders({Key key, this.showOnlyPendingOrders}) : super(key: key);

  @override
  _UserOrdersState createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> {
  bool _onlyPending = false;
  @override
  void initState() {
    super.initState();
    _onlyPending = widget.showOnlyPendingOrders ?? false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AuthModel auth = Provider.of<AuthModel>(context);
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'Orders',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: StreamBuilder(
          stream: _onlyPending
              ? Firestore.instance
                  .collection('orders')
                  .where('customerId', isEqualTo: auth.fUser.uid)
                  .where('orderStatus', isEqualTo: 'Pending')
                  .orderBy('createdAt', descending: true)
                  .snapshots()
              : Firestore.instance
                  .collection('orders')
                  .where('customerId', isEqualTo: auth.fUser.uid)
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
        ));
  }

  List<Widget> _orderList(AsyncSnapshot snapshot, BuildContext context,
      {bool showProgress}) {
    return snapshot.data.documents.map<Widget>((document) {
      Order order = Order.fromSnapShot(document);
      var format = DateFormat('MMM d, ' 'yyyy,  hh:mm aaa');
      var dateString = format.format(order.createdAt);
      return GestureDetector(
        onTap: () {
          Get.to(UserOrderDetails(
            order: order,
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
              Text('Order #${order.orderNumber}'),
              Text('Total : ${order.total + 10} QAR'),
              Text('Total Items : ${order.totalItems}'),
              Text('Date : $dateString'),
            ],
          ),
        ),
      );
    }).toList();
  }
}
