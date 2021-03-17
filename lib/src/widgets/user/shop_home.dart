import 'package:baqaala/src/helpers/location_helper.dart';
import 'package:baqaala/src/models/place.dart';
import 'package:baqaala/src/models/user.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/providers/location_provider.dart';
import 'package:baqaala/src/widgets/admin/admin_home.dart';
import 'package:baqaala/src/widgets/auth/login.dart';
import 'package:baqaala/src/widgets/common/select_location.dart';
import 'package:baqaala/src/widgets/customer_support/customer_support_home.dart';
import 'package:baqaala/src/widgets/driver/driver_home.dart';
import 'package:baqaala/src/widgets/investor/investor_home.dart';
import 'package:baqaala/src/widgets/manager/manager_home.dart';
import 'package:baqaala/src/widgets/picker/picker_home.dart';
import 'package:baqaala/src/widgets/quality_controller/quality_controller_home.dart';
import 'package:baqaala/src/widgets/user/add_address.dart';
import 'package:baqaala/src/widgets/user/cart.dart';
import 'package:baqaala/src/widgets/user/promotion_widget.dart';
import 'package:baqaala/src/widgets/user/select_category.dart';
import 'package:baqaala/src/widgets/user/user_sidemenu.dart';
import 'package:baqaala/src/widgets/vivek/draggable_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class ShopHome extends StatefulWidget {
  ShopHome({Key key}) : super(key: key);

  @override
  _ShopHomeState createState() => _ShopHomeState();
}

class _ShopHomeState extends State<ShopHome> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  Place _place;
  Address _selectedAddress;

  @override
  void initState() {
    super.initState();
    _getPlace();
  }

  void _getPlace() async {
    final AuthModel auth = Provider.of<AuthModel>(context, listen: false);
    final LocationProvider locProvider =
        Provider.of<LocationProvider>(context, listen: false)
          ..getAllAddresses();

    if (auth.fUser.defaultAddress != null) {
      _selectedAddress = auth.fUser.defaultAddress;
    } else {
      _place = await LocationHelper.getPlaceByCurrentLocation();
      _selectedAddress = Address(
        area: _place.name,
        latitude: _place.lat,
        longitude: _place.lng,
      );
    }
    setState(() {});
  }

  void changeRoute(Widget page) {
    Future.delayed(Duration(milliseconds: 200), () {
      Get.off(page);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthModel auth = Provider.of<AuthModel>(context);

    return Scaffold(
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
              Get.off(Login());
            }
          },
        ),
        actions: <Widget>[
          Container(
            width: 70,
            child: FlatButton(
              child: Icon(Icons.shopping_cart),
              textColor: Colors.green[600],
              onPressed: () {
                auth.fUser == null ? Get.to(Login()) : Get.to(Cart());
              },
            ),
          ),
        ],
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
          SizedBox(
            height: 10,
          ),
          _storeItem('Groceries', 'assets/images/top2.jpg', () {
            Get.to(UserSelectCategory());
          }),
          _storeItem('Fresh Fish', 'assets/images/fish_store.png', () {
            Get.to(UserSelectCategory());
          }),
          _storeItem('Fresh Meat', 'assets/images/meat.jpg', () {
            Get.to(UserSelectCategory());
          }),
        ],
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
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
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
