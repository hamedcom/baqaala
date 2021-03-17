import 'dart:typed_data';

import 'package:baqaala/src/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class SelectLocation extends StatefulWidget {
  const SelectLocation({Key key}) : super(key: key);

  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  GoogleMapController _controller;
  bool _isMoving = false;
  LatLng _currentLocation;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  var _mapIdleSubscription;

  final _initialLocation = CameraPosition(
    target: LatLng(25.3557021, 51.2372571),
    zoom: 16.5,
    // tilt: 20,
  );

  @override
  void initState() {
    super.initState();
    myLocation();
  }

  @override
  Widget build(BuildContext context) {
    final LocationProvider _locProvider =
        Provider.of<LocationProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Select Location',
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
                    height: 50,
                    child: RaisedButton(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      color: Colors.green[800],
                      child: Text(
                        'Confirm Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      onPressed: () {
                        _locProvider.setLatLng(_currentLocation);
                        Get.back(result: _currentLocation);
                      },
                    ),
                  )
          ],
        ),
      ),
    );
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

  void myLocation() {
    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 100);

    // geolocator.isLocationServiceEnabled()

    geolocator.getLastKnownPosition().then((Position position) async {
      if (_controller != null)
        _controller.animateCamera(CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude)));
      var loc = await geolocator.placemarkFromCoordinates(
          position.latitude, position.longitude);
      print(loc);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  Widget _googleMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        setState(() {
          _controller = controller;
        });

        _controller.setMapStyle(vmapStyle);
        Future.delayed(Duration(milliseconds: 100), () {
          myLocation();
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

      // myLocationButtonEnabled: true,
      initialCameraPosition: _initialLocation,
      myLocationEnabled: false,
      markers: Set<Marker>.of(markers.values),
    );
  }

  _onCameraIdle() async {
    setState(() {
      _isMoving = false;
    });
    _addMarkers();
  }

  _addMarkers() {
    final MarkerId pickup = MarkerId('Selected Location');
    final Marker marker = Marker(
      alpha: 0.7,
      markerId: pickup,
      position: _currentLocation,
      infoWindow: InfoWindow(title: pickup.value, snippet: 'Selected Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(0.5),
    );
    setState(() {
      markers[pickup] = marker;
    });
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
