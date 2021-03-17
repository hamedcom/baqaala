import 'package:after_layout/after_layout.dart';
import 'package:baqaala/src/helpers/location_helper.dart';
import 'package:baqaala/src/models/place.dart';
import 'package:baqaala/src/models/store_category.dart';
import 'package:baqaala/src/models/user.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/providers/cart_provider.dart';
import 'package:baqaala/src/providers/location_provider.dart';
import 'package:baqaala/src/widgets/admin/admin_home.dart';
import 'package:baqaala/src/widgets/auth/login.dart';
import 'package:baqaala/src/widgets/customer_support/customer_support_home.dart';
import 'package:baqaala/src/widgets/driver/driver_home.dart';
import 'package:baqaala/src/widgets/investor/investor_home.dart';
import 'package:baqaala/src/widgets/manager/manager_home.dart';
import 'package:baqaala/src/widgets/picker/picker_home.dart';
import 'package:baqaala/src/widgets/quality_controller/quality_controller_home.dart';
import 'package:baqaala/src/widgets/store_manager/store_console.dart';
import 'package:baqaala/src/widgets/user/add_address.dart';
import 'package:baqaala/src/widgets/user/orders.dart';
import 'package:baqaala/src/widgets/user/promotion_widget.dart';
import 'package:baqaala/src/widgets/user/select_category.dart';
import 'package:baqaala/src/widgets/user/user_sidemenu.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final bool autoRedirect;
  Home({Key key, this.autoRedirect}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AfterLayoutMixin {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  Place _place;
  Address _selectedAddress;

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // _getOrders();
    final AuthModel auth = Provider.of<AuthModel>(context, listen: false);

    if (widget.autoRedirect == true) {
      if (auth.checkRole('admin')) {
        changeRoute(AdminHome());
      } else if (auth.checkRole('store_manager')) {
        changeRoute(StoreConsole());
      } else if (auth.checkRole('manager')) {
        changeRoute(ManagerHome());
      } else if (auth.checkRole('picker')) {
        changeRoute(PickerHome());
      } else if (auth.checkRole('driver')) {
        changeRoute(DriverHome());
      } else if (auth.checkRole('customer_support')) {
        changeRoute(CustomerSupportHome());
      } else if (auth.checkRole('qc')) {
        changeRoute(QualityControllerHome());
      } else if (auth.checkRole('investor')) {
        //
        changeRoute(InvestorHome());
      }
    }

    _selectedAddress = auth.fUser.defaultAddress;
    if (_selectedAddress == null) {
      Get.to(AddAddress());
      setState(() {});
    } else {
      setState(() {});
    }

    _getPlace();
  }

  // void _getOrders() {
  //   final CartProvider cart = Provider.of<CartProvider>(context, listen: false);
  //   if (cart.orders.isEmpty) {
  //     cart.getOrders();
  //   }
  // }

  void _getPlace() async {
    final AuthModel auth = Provider.of<AuthModel>(context, listen: false);
    final LocationProvider locProvider =
        Provider.of<LocationProvider>(context, listen: false)
          ..getAllAddresses();

    if (auth.fUser?.defaultAddress != null) {
      _selectedAddress = auth.fUser.defaultAddress;
    } else {
      _place = await LocationHelper.getPlaceByCurrentLocation();
      if (_place != null) {
        _selectedAddress = Address(
          area: _place.name,
          latitude: _place.lat,
          longitude: _place.lng,
        );
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void changeRoute(Widget page) {
    Get.offAll(page);

    // Future.delayed(Duration(milliseconds: 200), () {
    // });
  }

  @override
  Widget build(BuildContext context) {
    final AuthModel auth = Provider.of<AuthModel>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        print('hello');
        return Future.value(false);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: _addressBar(),
          brightness: Brightness.light,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: FlatButton(
            child: Icon(Icons.menu),
            textColor: Colors.grey,
            onPressed: () {
              if (auth.authStatus == Status.Authenticated) {
                _scaffoldKey.currentState.openDrawer();
              } else {
                Get.offAll(Login());
              }
            },
          ),
          // actions: <Widget>[
          //   GestureDetector(
          //     onTap: () {
          //       Get.to(Cart());
          //     },
          //     child: Container(
          //       width: 70,
          //       child: Stack(children: [
          //         FlatButton(
          //           child: Icon(Icons.shopping_cart),
          //           textColor: Colors.green[600],
          //           onPressed: () {
          //             auth.fUser == null ? Get.to(Login()) : Get.to(Cart());
          //           },
          //         ),
          //         Positioned(
          //           top: 5,
          //           right: 10,
          //           child: Container(
          //             width: 20,
          //             height: 20,
          //             decoration: BoxDecoration(
          //               color: Colors.amber,
          //               borderRadius: BorderRadius.circular(50),
          //             ),
          //             child: Center(
          //                 child: Text(
          //               cart.totalItem.toString(),
          //               style: TextStyle(
          //                   color: Colors.black,
          //                   fontSize: cart.totalItem > 99 ? 10 : 12),
          //             )),
          //           ),
          //         )
          //       ]),
          //     ),
          //   ),
          // ],
        ),
        drawer: Drawer(
          child: UserSideMenu(),
        ),
        body: ListView(
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            Container(
              height: 250,
              child: PromotionWidget(),
            ),

            _hadOrders(),
            StreamBuilder(
              stream: Firestore.instance
                  .collection('storeTypes')
                  .orderBy('order')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:

                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    if (snapshot.hasData) {
                      if (snapshot.data.documents.length != 0)
                        return Column(
                            children: storeTypeList(snapshot, context));
                      else
                        return Center(
                          child: Text(
                            'No Store Types.',
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    return null;
                }
              },
            ),
            // _storeItem('Groceries', 'assets/images/top2.jpg', () {
            //   Get.to(UserSelectCategory());
            // }),
            // _storeItem('Fresh Fish', 'assets/images/fish_store.png', () {
            //   Get.to(UserSelectCategory());
            // }),
            // _storeItem('Fresh Meat', 'assets/images/meat.jpg', () {
            //   Get.to(UserSelectCategory());
            // }),
          ],
        ),
      ),
    );
  }

  Widget _hadOrders() {
    final CartProvider cart = Provider.of<CartProvider>(context);
    if (cart.orders.isEmpty) {
      return SizedBox(
        height: 10,
      );
    } else {
      return GestureDetector(
        onTap: () {
          print('Orders');
          Get.to(UserOrders(
            showOnlyPendingOrders: true,
          ));
        },
        child: Container(
          height: 50,
          margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
          padding: EdgeInsets.only(left: 15, right: 15),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.orange[900].withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 2, color: Colors.orange)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                cart.orders.length > 1
                    ? 'You Have ${cart.orders.length} Pending Orders'
                    : 'You Have One Pending Order',
                style:
                    TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
              ),
              Text('View',
                  style: TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
      );
    }
  }

  List<Widget> storeTypeList(AsyncSnapshot snapshot, BuildContext context) {
    return snapshot.data.documents.map<Widget>((document) {
      StoreCategory store = StoreCategory.fromSnapShot(document);

      return _storeTypeCard(store, context);
    }).toList();
  }

  Widget _storeTypeCard(StoreCategory store, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      child: GestureDetector(
        onTap: () {
          if (_selectedAddress == null) {
            Get.to(AddAddress());
            setState(() {});
          } else {
            Get.to(UserSelectCategory(
              storeId: store.titleEn == 'Grocery Store'
                  ? '2n8XBWMyS3PFkuFL24m8'
                  : 'OS2CnCBHTC7UsVuyJXJI',
              storeType: store,
            ));

            // Get.rawSnackbar(
            //     title: 'Sorry',
            //     message: 'Currently we are not serving to your area!');
          }
        },
        child: Card(
          elevation: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 140,
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: store.image.url,
                    height: 140,
                    width: Get.width,
                    fit: BoxFit.cover,
                  ),
                  // VBlurHashImage(
                  //   blurHash: store.image.blurhash,
                  //   image: store.image.url,
                  //   height: 140,
                  //   width: Get.width,
                  //   fit: BoxFit.cover,
                  // ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                        child: Text(
                      store.titleEn,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _storeItem(String name, String image, Function onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 130,
          decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(5)),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(5)),
            child: Center(
                child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            )),
          ),
        ),
      ),
    );
  }

  Widget _addressBar() {
    final LocationProvider _locProvider =
        Provider.of<LocationProvider>(context);
    return GestureDetector(
      child: Container(
        color: Colors.white10,
        // width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Delivery Location ',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: Colors.grey[600],
                ),
              ],
            ),
            Text(
              _locProvider.selectedAddress != null
                  ? _locProvider.selectedAddress.area
                  : _selectedAddress != null
                      ? _selectedAddress.area
                      : 'Searching..',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.green[800]),
            ),
          ],
        ),
      ),
      onTap: () async {
        // Get.bottomSheet(DraggableSheet());
        Get.bottomSheet(_addressBottomSheet());
      },
    );
  }

  Widget _addressBottomSheet() {
    final LocationProvider _locProvider =
        Provider.of<LocationProvider>(context, listen: false);
    return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5), topRight: Radius.circular(5)),
        ),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 10, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Select Delivery Address',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    child: FlatButton(
                      textColor: Colors.white,
                      child: Text(
                        '+ Add Address',
                        style: TextStyle(color: Colors.green[900]),
                      ),
                      color: Colors.green[800].withOpacity(0.2),
                      onPressed: () async {
                        Get.back();

                        Get.to(AddAddress());

                        // context.deleteSaveLocale();
                        // context.locale = Locale('en');
                        // print(context.locale);

                        // Get.changeTheme(ThemeData.dark());
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            (_locProvider.addresses.length > 0)
                ? Column(
                    children: _addressWidgets(_locProvider.addresses),
                  )
                : SizedBox(),
            ListTile(
              leading: Icon(
                Icons.location_searching,
                color: Colors.green[800].withOpacity(0.4),
              ),
              title: Text('Deliver to current location'),
              subtitle: Text('Deliver to present location'),
              onTap: () {
                Get.back(result: 'Hello');
              },
            ),
          ],
        ));
  }

  List<Widget> _addressWidgets(List<Address> addresses) {
    final AuthModel auth = Provider.of<AuthModel>(context, listen: false);
    final LocationProvider _locProvider = Provider.of(context, listen: false);
    Address userAddress = auth.fUser.defaultAddress;
    List<Widget> addressList = addresses.map((address) {
      bool isSelected = false;
      if (address.latitude == userAddress.latitude &&
          address.longitude == address.longitude) isSelected = true;

      var addressString =
          address.streetNumber != null ? 'Street:${address.streetNumber},' : '';
      addressString =
          addressString + (address.zone != null ? 'Zone: ${address.zone}' : '');
      addressString = addressString +
          (address.building != null ? ',Building: ${address.building}' : '.');

      Icon _icon = Icon(
        Icons.home,
        color: Colors.green[800].withOpacity(0.4),
      );
      return InkWell(
        onTap: () {
          _locProvider.setSelectedAddress(address);
          Get.back();
          // print(address);
        },
        child: Container(
          // padding: EdgeInsets.all(8),
          height: 80,
          child: Card(
            // margin: EdgeInsets.symmetric(horizontal: 10),
            elevation: 0.3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _icon,
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          address.area,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        Text(
                          addressString,
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                        )
                      : SizedBox()
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
    return addressList;
  }
}
