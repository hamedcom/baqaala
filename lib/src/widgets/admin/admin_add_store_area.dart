import 'dart:typed_data';

import 'package:baqaala/src/common/utils.dart';
import 'package:baqaala/src/models/service_area.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

class AdminAddStoreArea extends StatefulWidget {
  final ServiceArea area;
  final String storeId;
  final String storeTypeId;
  AdminAddStoreArea({Key key, this.area, this.storeId, this.storeTypeId})
      : super(key: key);

  @override
  _AdminAddStoreAreaState createState() => _AdminAddStoreAreaState();
}

class _AdminAddStoreAreaState extends State<AdminAddStoreArea> {
  bool _isMoving = false;
  LatLng _currentLocation;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  List<LatLng> latlngList = [];
  GoogleMapController _controller;
  final Set<Polyline> _polyline = {};
  String polyPath = '';
  String areaTitle = '';
  bool _isBusy = false;
  TextEditingController _areaController = TextEditingController();

  var _mapIdleSubscription;

  var _initialLocation = CameraPosition(
    target: LatLng(25.3557021, 51.2372571),
    zoom: 16.5,
    // tilt: 20,
  );

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  @override
  void initState() {
    super.initState();
    myLocation();
    if (widget.area != null) {
      setState(() {
        _areaController.text = widget.area.title;
        areaTitle = widget.area.title;
        latlngList = Utils.stringToLatLngList(widget.area.polygonData);
        polyPath = widget.area.polygonData;
        _initialLocation = CameraPosition(
          target: latlngList[0],
          zoom: 14,
          // tilt: 20,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          widget.area != null ? 'Edit Area' : 'Add Area',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            _googleMap(),
            latlngList.length > 0 ? _undoButton() : SizedBox(),
            _isMoving
                ? Center(
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[800],
                                blurRadius: 3,
                                offset: Offset(0, 0))
                          ],
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                : SizedBox(),
            _isMoving ? SizedBox() : _locationButton(),
            _isMoving
                ? SizedBox()
                : Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width * 0.63,
                            height: 50,
                            color: Colors.white,
                            child: TextField(
                              controller: _areaController,
                              onChanged: (val) {
                                setState(() {
                                  areaTitle = val;
                                });
                              },
                              decoration: InputDecoration(
                                  labelText: 'Area Name',
                                  hintText: 'Ex: Old Airport',
                                  border: OutlineInputBorder()),
                            )),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: 50,
                          child: RaisedButton(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            color: Colors.green[800],
                            child: Text(
                              widget.area != null ? 'Update' : 'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            onPressed: (areaTitle.length > 2 &&
                                    latlngList.length > 2 &&
                                    !_isBusy)
                                ? () async {
                                    setState(() {
                                      _isBusy = true;
                                    });
                                    try {
                                      if (widget.area != null) {
                                        await Firestore.instance
                                            .collection('service_areas')
                                            .document(widget.area.id)
                                            .updateData({
                                          'storeId': widget.storeId,
                                          'storeTypeId': widget.storeTypeId,
                                          'title': areaTitle,
                                          'polygonData': polyPath
                                        });
                                      } else {
                                        await Firestore.instance
                                            .collection('service_areas')
                                            .add({
                                          'storeId': widget.storeId,
                                          'storeTypeId': widget.storeTypeId,
                                          'title': areaTitle,
                                          'isActive': true,
                                          'polygonData': polyPath
                                        });
                                      }

                                      Get.back();
                                    } catch (e) {
                                      print(e);
                                    }
                                    setState(() {
                                      _isBusy = false;
                                    });

                                    // _locProvider.setLatLng(_currentLocation);
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }

  _makePolyLine() {
    _polyline.add(Polyline(
      polylineId: PolylineId('area'),
      visible: true,
      width: 2,
      //latlng is List<LatLng>
      points: latlngList,
      color: Colors.blue,
    ));
  }

  bool _isLocationInsidePolygon(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }

    return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  }

  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }

    double m = (aY - bY) / (aX - bX); // Rise over run
    double bee = (-aX) * m + aY; // y = mx + b
    double x = (pY - bee) / m; // algebra is neat!

    return x > pX;
  }

  Widget _locationButton() {
    return Positioned(
      bottom: 100,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.amber, borderRadius: BorderRadius.circular(10)),
        width: 60,
        height: 50,
        child: FlatButton(
          onPressed: () {
            myLocation();
          },
          child: Icon(
            Icons.my_location,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _googleMap() {
    return GoogleMap(
      polylines:
          (latlngList.length > 0 && latlngList.length < 3) ? _polyline : {},
      polygons: latlngList.length > 2
          ? Set<Polygon>.of(<Polygon>[
              Polygon(
                  polygonId: PolygonId('area'),
                  points: latlngList.length > 2 ? latlngList : [],
                  geodesic: true,
                  strokeColor: Colors.blue.withOpacity(0.6),
                  strokeWidth: 3,
                  fillColor: Colors.blueAccent.withOpacity(0.1),
                  visible: true),
            ])
          : Set<Polygon>.of(<Polygon>[]),
      onMapCreated: (GoogleMapController controller) {
        setState(() {
          _controller = controller;
        });

        _controller.setMapStyle(vmapStyle);
        Future.delayed(Duration(milliseconds: 400), () {
          if (widget.area == null) {
            myLocation();
          } else {
            moveToPolyLocation();
          }
        });
      },
      onCameraMove: (position) {
        // print(position.target);
        setState(() {
          _currentLocation = position.target;
          _isMoving = true;
        });
        _mapIdleSubscription?.cancel();
        _mapIdleSubscription =
            Future.delayed(Duration(milliseconds: 200)).asStream().listen(
                  (_) => _onCameraIdle(),
                );
      },

      onTap: _onTap,

      onCameraMoveStarted: () {
        setState(() {
          _isMoving = true;
          markers = {};
        });
      },

      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      mapType: MapType.normal,
      myLocationButtonEnabled: false,

      zoomControlsEnabled: false,

      // myLocationButtonEnabled: true,
      initialCameraPosition: _initialLocation,
      myLocationEnabled: false,
      markers: Set<Marker>.of(markers.values),
    );
  }

  _onTap(LatLng loc) async {
    setState(() {
      latlngList.add(loc);
      _makePolyLine();
      polyPath = Utils.latlngString(latlngList);

      // print(stringToLatLngList(polyPath));
    });
    _addMarkers();
    // print(polyPath);
  }

  _onCameraIdle() async {
    setState(() {
      _isMoving = false;
    });
    if (_isLocationInsidePolygon(_currentLocation, latlngList)) {
      print('Inside Delivery Area');
    } else {
      print('Outside Delivery Area');
    }

    _addMarkers();
  }

  void myLocation() {
    var geolocator = Geolocator();
    // var locationOptions =
    //     LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 100);

    // geolocator.isLocationServiceEnabled()

    geolocator.getLastKnownPosition().then((Position position) async {
      if (_controller != null && position != null)
        _controller.animateCamera(CameraUpdate.newLatLng(
            LatLng(position?.latitude, position?.longitude)));
    });
  }

  void moveToPolyLocation() {
    if (_controller != null && latlngList.isNotEmpty)
      _controller.animateCamera(
          CameraUpdate.newLatLngBounds(_createBounds(latlngList), 50));
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

  Widget _undoButton() {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.amber, borderRadius: BorderRadius.circular(10)),
        width: 60,
        height: 50,
        child: IconButton(
            icon: Icon(Icons.undo),
            onPressed: () {
              setState(() {
                latlngList.removeLast();
                polyPath = Utils.latlngString(latlngList);
                markers = {};
              });

              _addMarkers();
              // print(latlngList);
            }),
      ),
    );
  }

  _addMarkers([int index = 0]) async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/marker1.png', 50);

    if (latlngList.isNotEmpty) {
      latlngList.asMap().forEach((index, value) {
        MarkerId pickup = MarkerId(index.toString());
        Marker marker = Marker(
          anchor: Offset(0.5, 0.5),
          alpha: 0.6,
          markerId: pickup,
          position: value,
          draggable: true,
          onDragEnd: (val) {
            setState(() {
              latlngList[index] = val;
              polyPath = Utils.latlngString(latlngList);
            });
            // print('ended-$index :  $val');
          },
          icon: BitmapDescriptor.fromBytes(markerIcon),
        );
        // print('$index : $value');
        setState(() {
          markers[pickup] = marker;
        });
      });
    } else {
      final MarkerId pickup = MarkerId('Mylocation');
      Marker marker = Marker(
        alpha: 0.7,
        markerId: pickup,
        position: _currentLocation,
        draggable: true,
        // onDragEnd: (val) {
        //   print('ended-$index :  $val');
        // },
        icon: BitmapDescriptor.defaultMarkerWithHue(0.5),
      );
      setState(() {
        markers[pickup] = marker;
      });
    }
  }
}

final vmapStyle = ''' 
  [
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#eef2f4"
      }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#d1dae0"
      },
      {
        "visibility": "on"
      }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#eef2f4"
      }
    ]
  },
  {
    "featureType": "poi.business",
    "elementType": "labels.icon",
    "stylers": [
      {
        "saturation": -100
      }
    ]
  },
  {
    "featureType": "poi.business",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#606c74"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#AFE1B8"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.school",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#eef2f4"
      }
    ]
  },
  {
    "featureType": "poi.sports_complex",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#AFE1B8"
      }
    ]
  },
  {
    "featureType": "poi.sports_complex",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#f0f0f0"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#FFFFFF"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#606C74"
      }
    ]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#C3CCD2"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit.station.airport",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#E3E8EC"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#B1E1FC"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  }
]
''';
