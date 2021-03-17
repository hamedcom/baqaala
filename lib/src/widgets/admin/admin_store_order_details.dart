import 'package:baqaala/src/models/order.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/widgets/user/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminStoreOrderDetails extends StatefulWidget {
  final Order order;
  final String orderId;
  AdminStoreOrderDetails({Key key, this.order, this.orderId}) : super(key: key);

  @override
  _AdminStoreOrderDetailsState createState() => _AdminStoreOrderDetailsState();
}

class _AdminStoreOrderDetailsState extends State<AdminStoreOrderDetails> {
  Order _order;

  @override
  void initState() {
    super.initState();
    getOrder();
  }

  void getOrder() async {
    if (widget.orderId != null) {
      var doc = await Firestore.instance
          .collection('orders')
          .document(widget.orderId)
          .get();
      if (doc.exists) {
        _order = Order.fromSnapShot(doc);
        setState(() {});
      }
    } else if (widget.order != null) {
      _order = widget.order;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthModel auth = Provider.of<AuthModel>(context);
    if (!auth.checkRole('admin') && !auth.checkRole('store_manager')) {
      Get.offAll(Home());
    }

    return Scaffold(
        bottomNavigationBar: _bottomNavigation(),
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            _order != null ? 'Order # ${_order?.orderNumber}' : 'Order',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: _order != null
              ? Column(
                  children: <Widget>[
                    _order?.customer?.defaultAddress != null
                        ? _address()
                        : Text('No Address'),
                    // _timeSlot(),
                    SizedBox(
                      height: 5,
                    ),

                    Card(
                      child: ListTile(
                        title: Text('Time Slot'),
                        subtitle: Text(_order?.slot?.title),
                      ),
                    ),

                    SizedBox(
                      height: 5,
                    ),
                    _userCard(),

                    _itemList(),
                    SizedBox(
                      height: 10,
                    ),

                    // _paymentMode(),
                  ],
                )
              : Container(
                  height: Get.height,
                  child: Center(child: CircularProgressIndicator())),
        ));
  }

  Widget _bottomNavigation() {
    // final CartProvider cart = Provider.of<CartProvider>(context);

    return Container(
      padding: EdgeInsets.all(10),

      height: 70,
      decoration: BoxDecoration(
          color: Colors.grey[200], shape: BoxShape.rectangle
          // RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)));
          ),
      // color: Colors.green,
      child: Column(
        children: <Widget>[
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: Get.width * 0.45,
                height: 50,
                child: OutlineButton(
                  borderSide: BorderSide(color: Colors.orange),
                  textColor: Colors.orange[800],
                  child: Text('Cancel'),
                  onPressed: () {
                    if (widget.orderId != null) {
                      Get.to(Home(
                        autoRedirect: true,
                      ));
                    } else {
                      Get.back();
                      Get.back();
                    }
                  },
                ),
              ),
              Container(
                width: Get.width * 0.45,
                height: 50,
                child: FlatButton(
                  color: Colors.green[800],
                  textColor: Colors.white,
                  child: Text('Confirm'),
                  onPressed: () {
                    // Get.to(CheckOutPage());
                  },
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _itemList() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Text(
          'Items',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10,
        ),
        ..._order?.items?.map((e) => Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: Get.width,
              height: Get.width * 0.2,
              child: Row(
                children: <Widget>[
                  Container(
                    width: Get.width * 0.15,
                    height: Get.width * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 2,
                            offset: Offset(1, 1))
                      ],
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                        image:
                            new CachedNetworkImageProvider(e.item.image.thumb),
                      ),
                    ),
                    // child: CachedNetworkImage(
                    //   imageUrl: item.item.image.thumb,
                    //   width: 150,
                    //   height: 150,
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: Get.width * 0.4,
                    // color: Colors.green,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          e.item.titleEn,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          e.item.volume,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          '${e.item.defaultPrice} QAR',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: Get.width * 0.3,
                    // color: Colors.green,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '${e.total} QAR',
                          style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'x${e.quantity}',
                          style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ))
      ],
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
                  _order?.customer?.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text('+${_order?.customer?.mobile}'),
              ],
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                launch('tel:+${_order?.customer?.mobile}');
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
