import 'package:baqaala/src/models/order.dart';
import 'package:baqaala/src/providers/app_provider.dart';
import 'package:baqaala/src/services/order_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UserOrderDetails extends StatefulWidget {
  final Order order;
  UserOrderDetails({Key key, this.order}) : super(key: key);

  @override
  _UserOrderDetailsState createState() => _UserOrderDetailsState();
}

class _UserOrderDetailsState extends State<UserOrderDetails> {
  Order _order;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final OrderService _orderService = OrderService.instance;

  bool isDriverTracking = false;
  LatLng driverLocation;
  GoogleMapController _mapController;
  List<LatLng> latlngList = [null, null];
  bool _canEdit = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    setState(() {});
    getOrder();
  }

  void getOrder() {
    Firestore.instance
        .collection('orders')
        .document(widget.order.id)
        .snapshots()
        .listen((doc) {
      _order = Order.fromSnapShot(doc);
      if (_order.address != null) {
        latlngList[0] =
            LatLng(_order.address.latitude, _order.address.longitude);
        setMarker('customer',
            LatLng(_order.address.latitude, _order.address.longitude));
      }
      if (!isDriverTracking) {
        if (_order.driver != null) getDriverLocation();
      }
      setState(() {});
    });
  }

  void getDriverLocation() {
    Firestore.instance
        .collection('liveLocation')
        .document(_order.driverId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        driverLocation = LatLng(doc['latitude'], doc['longitude']);
        setMarker('driver', driverLocation);

        isDriverTracking = true;
        latlngList[1] = driverLocation;
        moveToPolyLocation();
        setState(() {});
      }
    });
  }

  void setMarker(String id, LatLng location) {
    MarkerId mId = MarkerId(id);
    Marker marker = Marker(
      alpha: 0.8,
      markerId: mId,
      position: LatLng(
        location.latitude,
        location.longitude,
      ),
      draggable: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(id == 'driver'
          ? BitmapDescriptor.hueBlue
          : BitmapDescriptor.hueRed), // BitmapDescriptor.defaultMarker,
    );
    _markers[mId] = marker;
    // setState(() {});
  }

  void moveToPolyLocation() {
    // print(latlngList);
    if (_mapController != null && latlngList.isNotEmpty) if (mounted)
      _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(_createBounds(latlngList), 45));
  }

  LatLngBounds _createBounds(List<LatLng> positions) {
    final southwestLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value < element ? value : element); // smallest
    final southwestLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value < element ? value : element);
    final northeastLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value > element ? value : element); // biggest
    final northeastLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value > element ? value : element);
    return LatLngBounds(
        southwest: LatLng(southwestLat, southwestLon),
        northeast: LatLng(northeastLat, northeastLon));
  }

  @override
  Widget build(BuildContext context) {
    AppSettingsProvider _appSettings =
        Provider.of<AppSettingsProvider>(context);
    if (_order != null) {
      if (_order.pickerUpdatedAt != null) {
        var diff = _appSettings.appSettings.serverTime
            .difference(_order.pickerUpdatedAt);
        if (diff < Duration(minutes: 15)) {
          print('User Can Edit');
          setState(() {
            _canEdit = true;
          });
        } else {
          setState(() {
            _canEdit = false;
          });
          print('User Can not Edit');
        }
      } else {
        var diff =
            _appSettings.appSettings.serverTime.difference(_order.createdAt);
        if (diff < Duration(minutes: 15)) {
          setState(() {
            _canEdit = true;
          });
        } else {
          setState(() {
            _canEdit = false;
          });
        }
      }
    }
    return Scaffold(
        bottomNavigationBar: _bottomNavigation(),
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'Order # ${_order.orderNumber}',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: <Widget>[
              _trackOrder(),
              SizedBox(
                height: 15,
              ),
              _itemList(),

              // _timeSlot(),
              SizedBox(
                height: 5,
              ),

              Card(
                child: ListTile(
                  title: Text('Delivery Time'),
                  subtitle: Text(_order.slot.title),
                ),
              ),

              SizedBox(
                height: 5,
              ),
              // widget.order.customer.defaultAddress != null
              //     ? _address()
              //     : SizedBox(),
              // _userCard(),

              SizedBox(
                height: 10,
              ),

              // _paymentMode(),
            ],
          ),
        ));
  }

  Widget _trackOrder() {
    if (_order.address == null) return SizedBox();

    return _order.driver != null
        ? Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
                setState(() {});
              },
              zoomControlsEnabled: false,
              zoomGesturesEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              markers: Set<Marker>.of(_markers.values),
              initialCameraPosition: CameraPosition(
                  zoom: 14,
                  target: LatLng(
                    widget.order.address.latitude,
                    widget.order.address.longitude,
                  )),
            ),
          )
        : SizedBox();
  }

  Widget _bottomNavigation() {
    // final CartProvider cart = Provider.of<CartProvider>(context);
    print(_order.paymentMethod);
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
            child: Container(
              width: Get.width * 0.95,
              height: 50,
              child: (_order.statusMessage == 'Picker Updated' ||
                      _order.statusMessage == 'Picker Confirmed')
                  ? FlatButton(
                      color: Colors.green[100],
                      textColor: Colors.green[900],
                      child: Text(_canEdit
                          ? 'Accept'
                          : _order.paymentMethod == 'Credit Card'
                              ? 'Pay'
                              : _order.statusMessage),
                      onPressed: _canEdit
                          ? () async {
                              await _orderService.userAcceptOrder(_order.id);
                              // Get.back();
                              // Get.back();
                            }
                          : _order.paymentMethod == 'Credit Card'
                              ? () async {
                                  await _orderService
                                      .userAcceptOrder(_order.id);

                                  print('Credit Card');
                                }
                              : null,
                    )
                  : FlatButton(
                      child: Text(_order.statusMessage),
                      onPressed: null,
                    ),
            ),
            // Container(
            //   width: Get.width * 0.45,
            //   height: 50,
            //   child: FlatButton(
            //     color: Colors.green[800],
            //     textColor: Colors.white,
            //     child: Text('Confirm'),
            //     onPressed: () {
            //       // Get.to(CheckOutPage());
            //     },
            //   ),
            // ),
          ),
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
        ..._order.items.map((e) => e.isRemoved
            ? SizedBox()
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                width: Get.width,
                child: Column(
                  children: <Widget>[
                    Row(
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
                              image: new CachedNetworkImageProvider(
                                  e.item.image.thumb),
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
                                    color: e.isPicked
                                        ? Colors.green[900]
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    decoration: e.isAvailable
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough,
                                    fontSize: 16),
                              ),
                              Text(
                                e.item.volume,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  decoration: e.isAvailable
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              Text(
                                e.isAvailable
                                    ? '${e.item.defaultPrice} QAR'
                                    : 'Out of Stock',
                                style: TextStyle(
                                  color:
                                      e.isAvailable ? Colors.grey : Colors.red,
                                  fontSize: 14,
                                ),
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
                                    color: e.isPicked
                                        ? Colors.green[800]
                                        : Colors.grey,
                                    decoration: e.isAvailable
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'x${e.quantity}',
                                style: TextStyle(
                                    color: Colors.grey,
                                    decoration: e.isAvailable
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    (e.isPicked &&
                            !e.isAvailable &&
                            e.altItem != null &&
                            _canEdit)
                        ? Container(
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.all(10),
                            width: Get.width * 0.9,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.grey, width: 1)),
                            child: Column(
                              children: <Widget>[
                                Row(
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
                                          image: new CachedNetworkImageProvider(
                                              e.altItem.image.thumb),
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          e.altItem.titleEn,
                                          style: TextStyle(
                                              color: e.isPicked
                                                  ? Colors.green[900]
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        SizedBox(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                  '${e.altItem.defaultPrice} x ${e.altQuantity}'),
                                              Text(
                                                '    :    ${e.altTotal.toStringAsFixed(2)} QAR',
                                                style: TextStyle(
                                                    color: Colors.green[800],
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: Get.width * 0.8,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      FlatButton(
                                        color: Colors.red[50],
                                        textColor: Colors.red[800],
                                        child: Text('Remove'),
                                        onPressed: () async {
                                          var res = await _orderService
                                              .setItemRemoved(
                                                  itemId: e.id,
                                                  orderId: _order.id);

                                          print(res);
                                        },
                                      ),
                                      FlatButton(
                                        color: Colors.green[50],
                                        textColor: Colors.green[900],
                                        child: Text('Accept'),
                                        onPressed: () async {
                                          var res = await _orderService
                                              .setItemAccepted(
                                                  itemId: e.id,
                                                  orderId: _order.id);

                                          print(res);
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox()
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
                  widget.order.customer.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text('+${widget.order.customer.mobile}'),
              ],
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                launch('tel:+${widget.order.customer.mobile}');
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
                    'https://api.whatsapp.com/send?phone=+${widget.order.customer.mobile}');
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
        widget.order.customer.defaultAddress.latitude,
        widget.order.customer.defaultAddress.longitude,
      ),
      draggable: true,
      icon: BitmapDescriptor.defaultMarker,
    );
    markers[mId] = marker;

    return GestureDetector(
      onTap: () async {
        // print('hello');
        // String url =
        //     // "https://www.google.com/maps/search/?api=1&query=$lat,$lng,17";
        //     "https://maps.google.com/?daddr=${widget.order.customer.defaultAddress.latitude},${widget.order.customer.defaultAddress.longitude}&directionsmode=driving";
        // if (await canLaunch(url)) {
        //   await launch(url);
        // } else {
        //   print('Could not launch Maps');
        //   // throw 'Could not launch Maps';
        // }
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
                  // print('hello');
                  // String url =
                  //     // "https://www.google.com/maps/search/?api=1&query=$lat,$lng,17";
                  //     "https://maps.google.com/?daddr=${widget.order.customer.defaultAddress.latitude},${widget.order.customer.defaultAddress.longitude}&directionsmode=driving";
                  // if (await canLaunch(url)) {
                  //   await launch(url);
                  // } else {
                  //   print('Could not launch Maps');
                  //   // throw 'Could not launch Maps';
                  // }
                },
                initialCameraPosition: CameraPosition(
                    zoom: 14,
                    target: LatLng(
                      widget.order.customer.defaultAddress.latitude,
                      widget.order.customer.defaultAddress.longitude,
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
                'Street : ${widget.order.customer.defaultAddress.streetNumber}, Building : ${widget.order.customer.defaultAddress.building}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
