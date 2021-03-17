import 'package:baqaala/src/models/order.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/widgets/user/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverOrderDetails extends StatefulWidget {
  final String orderId;
  DriverOrderDetails({Key key, this.orderId}) : super(key: key);

  @override
  _DriverOrderDetailsState createState() => _DriverOrderDetailsState();
}

class _DriverOrderDetailsState extends State<DriverOrderDetails> {
  Order _order;
  bool isStarted = false;

  @override
  void initState() {
    super.initState();
    getOrder();
  }

  void getOrder() {
    Firestore.instance
        .collection('orders')
        .document(widget.orderId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _order = Order.fromSnapShot(doc);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthModel auth = Provider.of<AuthModel>(context);
    if (!auth.checkRole('admin') && !auth.checkRole('driver')) {
      Get.offAll(Home());
    }

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          _order != null ? 'Order #${_order.orderNumber}' : 'Order',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: _order == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: EdgeInsets.all(15),
              children: <Widget>[
                _order?.customer?.defaultAddress != null
                    ? _address()
                    : Text('No Address'),
                SizedBox(
                  height: 5,
                ),
                _userCard(),
                SizedBox(
                  height: 5,
                ),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    child: Text(
                        _order.isDriverStarted ? 'Started' : 'Start Delivery'),
                    color: Colors.green[300],
                    onPressed: _order.isDriverStarted
                        ? null
                        : () async {
                            Firestore.instance
                                .collection('orders')
                                .document(widget.orderId)
                                .updateData({
                              'isDriverStarted': true,
                            });
                          },
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                _order.isDriverStarted
                    ? Container(
                        width: double.infinity,
                        height: 50,
                        child: RaisedButton(
                          child: Text('Delivery Completed'),
                          color: Colors.blue[300],
                          onPressed: () async {
                            await Firestore.instance
                                .collection('orders')
                                .document(widget.orderId)
                                .updateData({
                              'orderStatus': 'Completed',
                              'statusMessage': 'Delivered'
                            });
                            Get.back();
                            // locationService.startBackgroundLocationUpdates();
                          },
                        ),
                      )
                    : SizedBox(),
              ],
            ),
    );
  }

  Widget _userCard() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Customer : ' + _order?.customer?.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text('+${_order?.customer?.mobile}'),
              ],
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                launch(
                    'tel:${_order?.customer?.mobile.toString().substring(3)}');
              },
              icon: Icon(
                FontAwesomeIcons.phone,
                color: Colors.green[800],
                size: 26,
              ),
            ),
            IconButton(
              onPressed: () {
                launch(
                    'https://api.whatsapp.com/send?phone=+${_order?.customer?.mobile}&text=Order%20%23${_order?.orderNumber}%20:');
              },
              icon: Icon(
                FontAwesomeIcons.whatsapp,
                color: Colors.green[800],
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _address() {
    Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

    MarkerId mId = MarkerId('address');
    Marker marker = Marker(
      alpha: 0.6,
      markerId: mId,
      position: LatLng(
        _order?.customer?.defaultAddress?.latitude,
        _order?.customer?.defaultAddress?.longitude,
      ),
      draggable: true,
      icon: BitmapDescriptor.defaultMarker,
    );
    markers[mId] = marker;

    return GestureDetector(
      onTap: () async {
        print('hello');
        String url =
            // "https://www.google.com/maps/search/?api=1&query=$lat,$lng,17";
            "https://maps.google.com/?daddr=${_order?.customer?.defaultAddress?.latitude},${_order?.customer?.defaultAddress?.longitude}&directionsmode=driving";
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          print('Could not launch Maps');
          // throw 'Could not launch Maps';
        }
      },
      child: Container(
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
              color: Colors.grey[300],
              child: GoogleMap(
                onTap: (l) async {
                  print('hello');
                  String url =
                      // "https://www.google.com/maps/search/?api=1&query=$lat,$lng,17";
                      "https://maps.google.com/?daddr=${_order?.customer?.defaultAddress?.latitude},${_order?.customer?.defaultAddress?.longitude}&directionsmode=driving";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    print('Could not launch Maps');
                    // throw 'Could not launch Maps';
                  }
                },
                initialCameraPosition: CameraPosition(
                    zoom: 14,
                    target: LatLng(
                      _order?.customer?.defaultAddress?.latitude,
                      _order?.customer?.defaultAddress?.longitude,
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
                'Street : ${_order?.customer?.defaultAddress?.streetNumber}, Building : ${_order?.customer?.defaultAddress?.building}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
