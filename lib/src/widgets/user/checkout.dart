import 'dart:typed_data';

import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/providers/cart_provider.dart';
import 'package:baqaala/src/widgets/user/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CheckOutPage extends StatefulWidget {
  CheckOutPage({Key key}) : super(key: key);

  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  @override
  Widget build(BuildContext context) {
    final CartProvider cart = Provider.of<CartProvider>(context);
    final AuthModel auth = Provider.of<AuthModel>(context);
    return Scaffold(
        bottomNavigationBar: _bottomNavigation(),
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Checkout',
            style: TextStyle(color: Colors.green[600]),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.green[800]),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: <Widget>[
              auth.selectedAddress != null ? _address() : Text('No Address'),
              _timeSlot(),
              SizedBox(
                height: 10,
              ),
              _paymentMode(),
            ],
          ),
        ));
  }

  Widget _address() {
    final AuthModel auth = Provider.of<AuthModel>(context);
    Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

    MarkerId mId = MarkerId('address');
    Marker marker = Marker(
      alpha: 0.6,
      markerId: mId,
      position: LatLng(
        auth.selectedAddress.latitude,
        auth.selectedAddress.longitude,
      ),
      draggable: true,
      icon: BitmapDescriptor.defaultMarker,
    );
    markers[mId] = marker;

    return Container(
      width: double.infinity,
      // height: 200,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.grey[300]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 150,
            color: Colors.red,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                  zoom: 14,
                  target: LatLng(
                    auth.selectedAddress.latitude,
                    auth.selectedAddress.longitude,
                  )),
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              myLocationEnabled: false,
              markers: Set<Marker>.of(markers.values),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            height: 20,
            child: Text(
              'Street : ${auth.selectedAddress.streetNumber}, Building : ${auth.selectedAddress.building}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeSlot() {
    final CartProvider cart = Provider.of<CartProvider>(context);

    return Card(
      child: ListTile(
        title: Text('Delivery Time Slot'),
        subtitle: Text(cart.selectedSlot == null
            ? 'Select Delivery Time Slot'
            : cart.selectedSlot.title),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          Get.bottomSheet(
            Container(
              height: 300,
              width: double.infinity,
              // decoration: BoxDecoration(),
              // color: Colors.red,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ...cart.slots
                        .map((e) => Card(
                              elevation: 0,
                              child: ListTile(
                                title: Text(e.title),
                                onTap: () {
                                  cart.setSelectedSlot(e);
                                  Get.back();
                                },
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
          );
        },
      ),
    );
  }

  Widget _paymentMode() {
    final CartProvider cart = Provider.of<CartProvider>(context);

    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Payment Method',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Card(
            child: ListTile(
          title: Text('Cash on Delivery'),
          trailing: cart.paymentMode == 'Cash On Delivery'
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green[700],
                )
              : null,
          onTap: () {
            cart.setPaymentMode('Cash On Delivery');
          },
        )),
        Card(
            child: ListTile(
          title: Text('Card On Delivery'),
          trailing: cart.paymentMode == 'Card On Delivery'
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green[700],
                )
              : null,
          onTap: () {
            cart.setPaymentMode('Card On Delivery');
          },
        )),
        Card(
            child: ListTile(
          title: Text('Credit Card'),
          trailing: cart.paymentMode == 'Credit Card'
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green[700],
                )
              : null,
          onTap: () {
            cart.setPaymentMode('Credit Card');
          },
        )),
        cart.paymentMode == 'Credit Card'
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                    'Note: You will get notification for payment once confirmed by Store \nFinal price may varied as per exact weight, you will get notified before delivery'),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                    'Note: Final price may varied as per exact weight, you will get notified before delivery'),
              )
      ],
    );
  }

  Widget _bottomNavigation() {
    final CartProvider cart = Provider.of<CartProvider>(context);
    final AuthModel auth = Provider.of<AuthModel>(context);
    return Container(
      padding: EdgeInsets.all(10),
      height: 150,
      decoration: BoxDecoration(
          color: Colors.grey[200], shape: BoxShape.rectangle
          // RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)));
          ),
      // color: Colors.green,
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total : ${cart.totalAmount} QAR',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              )),
          Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Convenience Fee : 10.0 QAR',
                style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.bold,
                    fontSize: 16),
              )),
          Align(
              alignment: Alignment.centerRight,
              child: Text(
                'SubTotal : ${cart.totalAmount + 10} QAR',
                style: TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              )),
          SizedBox(
            height: 10,
          ),
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: Get.width * 0.95,
                height: 55,
                child: FlatButton(
                  color: Colors.green[800],
                  textColor: Colors.white,
                  child: Text(
                    'Confirm Order',
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: cart.paymentMode != null &&
                          cart.selectedSlot != null &&
                          !cart.busy
                      ? () async {
                          var res = await cart.saveOrder(auth.fUser);

                          if (res) {
                            Get.offAll(Home());
                            // Get.offUntil(Home(), '');
                            // Get.off(Home());
                          }

                          print('hello');
                        }
                      : null,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
