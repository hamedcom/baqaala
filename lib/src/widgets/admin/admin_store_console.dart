import 'package:baqaala/src/models/store.dart';
import 'package:baqaala/src/models/user.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/widgets/admin/admin_notifications.dart';
import 'package:baqaala/src/widgets/admin/admin_promotions.dart';
import 'package:baqaala/src/widgets/admin/admin_reports.dart';
import 'package:baqaala/src/widgets/admin/admin_store_areas.dart';
import 'package:baqaala/src/widgets/admin/admin_store_drivers.dart';
import 'package:baqaala/src/widgets/admin/admin_store_orders.dart';
import 'package:baqaala/src/widgets/admin/admin_store_pickers.dart';
import 'package:baqaala/src/widgets/admin/admin_store_products.dart';
import 'package:baqaala/src/widgets/admin/admin_store_slots.dart';
import 'package:baqaala/src/widgets/admin/admin_user_select.dart';
import 'package:baqaala/src/widgets/admin/app_settings.dart';
import 'package:baqaala/src/widgets/common/product_search.dart';
import 'package:baqaala/src/widgets/common/v_blurhash_image.dart';
import 'package:baqaala/src/widgets/user/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AdminStoreConsole extends StatefulWidget {
  final String storeId;
  final Store store;
  AdminStoreConsole({Key key, this.storeId, this.store}) : super(key: key);

  @override
  _AdminStoreConsoleState createState() => _AdminStoreConsoleState();
}

class _AdminStoreConsoleState extends State<AdminStoreConsole> {
  Store _store;

  @override
  void initState() {
    super.initState();
    setState(() {
      _store = widget.store;
    });
    getStore();
  }

  void getStore() async {
    Firestore.instance
        .collection('stores')
        .document(widget.store.id)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        setState(() {
          _store = Store.fromSnapShot(doc);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthModel _auth = Provider.of<AuthModel>(context);
    if (!_auth.checkRole('admin')) {
      Future.delayed(Duration(milliseconds: 200), () {
        Get.off(Home(
          autoRedirect: true,
        ));
      });
    }
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Store Console',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: <Widget>[
          _storeCard(_store),
          SizedBox(
            height: 10,
          ),
          _storeManager(),
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
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _storeManager() {
    return _store.storeManager != null
        ? Text('Store Manager : ${_store.storeManager.name}')
        : GestureDetector(
            onTap: () async {
              User user = await Get.to(AdminUserSelect());
              if (user != null) {
                print(user.name);
                await Firestore.instance
                    .collection('stores')
                    .document(_store.id)
                    .updateData(
                        {'storeManager': user.toJSON(), 'managerId': user.uid});
                await Firestore.instance
                    .collection('users')
                    .document(user.uid)
                    .updateData({
                  'storeId': _store.id,
                  'roles': {'store_manager': true}
                });

                Get.snackbar('Success', 'Store Manager Assigned');
              }

              // Get.to(AdminAddStoreCategory());
            },
            child: Container(
              // margin: EdgeInsets.all(8),
              height: 60,
              width: Get.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(colors: [
                    Colors.red[50],
                    Colors.red[50],
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: Center(
                child: Text(
                  'Assign Store Manager',
                  style: TextStyle(
                      color: Colors.red[900],
                      fontSize: 19,
                      fontWeight: FontWeight.w600),
                ),
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
            subTitle: null,
            size: size,
            icon: Icons.receipt,
            page: AdminStoreOrders(
              storeId: widget.storeId,
            )),
        _tile(
          color: Colors.amber[900],
          title: 'Products',
          subTitle: null,
          size: size,
          icon: Icons.image_aspect_ratio,
          page: AdminStoreProducts(
            store: _store,
          ),
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
            title: 'Areas',
            subTitle: null,
            size: size,
            icon: Icons.location_on,
            page: AdminStoreAreas(
              storeId: _store.id,
              storeTypeId: _store.categoryId,
              store: _store,
            )),
        _tile(
            color: Colors.purple[800],
            title: 'Slots',
            // subTitle   : '( 15)',
            size: size,
            icon: Icons.check_box,
            page: AdminStoreSlots(
              store: _store,
            )),
      ],
    );
  }

  Widget _thirdRow() {
    double size = MediaQuery.of(context).size.width * .43;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _tile(
          color: Colors.red[800],
          title: 'Pickers',
          subTitle: null,
          size: size,
          icon: Icons.list,
          page: AdminStorePickers(
            storeId: _store.id,
          ),
          // page: ProductSearch(),
        ),
        // page: AdminComplaints()),
        _tile(
          color: Colors.teal[800],
          title: 'Drivers',
          subTitle: null,
          size: size,
          icon: Icons.airport_shuttle,
          page: AdminStoreDrivers(
            storeId: _store.id,
          ),
        ),
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
            title: 'QC',
            size: size,
            icon: Icons.check_box,
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

  Widget _storeCard(Store store) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: () {
          // Get.to(AdminStoreConsole(
          //   store: store,
          // ));
        },
        // onLongPress: () {
        //   Get.to(AdminEditStoreCategory(
        //     storetype: store,
        //   ));
        // },
        child: Container(
          height: 120,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          child: Stack(
            children: <Widget>[
              VBlurHashImage(
                blurHash: store.category.image.blurhash,
                image: store.category.image.url,
                height: 120,
                width: Get.width,
                fit: BoxFit.cover,
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        store.storeName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        '(${store.category.titleEn})',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ]),
              ),
              // Container(
              //   padding: EdgeInsets.all(10),
              //   child: Align(
              //       alignment: Alignment.bottomRight,
              //       child: Text(
              //         "Long Press to Edit",
              //         style: TextStyle(
              //           color: Colors.white38,
              //           fontSize: 14,
              //         ),
              //       )),
              // ),
            ],
          ),
        ),
      ),
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
                    '10',
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
                    '654',
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
                    Text('4',
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
                      '5',
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
