import 'package:after_layout/after_layout.dart';
import 'package:baqaala/src/helpers/location_helper.dart';
import 'package:baqaala/src/models/place.dart';
import 'package:baqaala/src/models/user.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/providers/location_provider.dart';
import 'package:baqaala/src/widgets/common/select_location.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AddAddress extends StatefulWidget {
  AddAddress({Key key}) : super(key: key);

  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> with AfterLayoutMixin {
  GoogleMapController _controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Place _place;
  Address _address;
  TextEditingController _addressController = TextEditingController();
  TextEditingController _streetNameController = TextEditingController();
  TextEditingController _streetNumberController = TextEditingController();
  TextEditingController _zoneController = TextEditingController();
  TextEditingController _buildingController = TextEditingController();
  TextEditingController _landmarkController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final LocationProvider _locProvider =
        Provider.of<LocationProvider>(context);
    final AuthModel _auth = Provider.of<AuthModel>(context);
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Add Address',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              _mapSnippet(),
              _textFields(),
              Container(
                  padding: EdgeInsets.all(15),
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    child: Text(
                      'Save Address',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.green[700],
                    onPressed: _locProvider.busy
                        ? null
                        : () async {
                            _address.aptNumber = _buildingController.text;
                            _address.streetNumber =
                                _streetNumberController.text;
                            _address.zone = _zoneController.text;
                            _address.building = _buildingController.text;
                            _address.landMark = _landmarkController.text;
                            _address.latitude =
                                _locProvider.selectedLatLng.latitude;
                            _address.longitude =
                                _locProvider.selectedLatLng.longitude;

                            _locProvider.setBusy(true);
                            var res = await _locProvider.saveAddress(
                                _address, _auth.fUser);
                            _locProvider.setBusy(false);
                            if (res) {
                              Get.snackbar(
                                  'Success', 'Address Saved Sucessfully',
                                  backgroundColor: Colors.green[800],
                                  colorText: Colors.white);
                              Get.back();
                            } else {
                              Get.snackbar('Error', 'Unknown Error',
                                  backgroundColor: Colors.red[800],
                                  colorText: Colors.white);
                            }
                          },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    var result = await Get.to(SelectLocation());
    if (result != null) {
      getAddressFromLatLng(result);
      final MarkerId pickup = MarkerId('Selected Location');
      final Marker marker = Marker(
        alpha: 0.7,
        markerId: pickup,
        position: result,
        infoWindow:
            InfoWindow(title: pickup.value, snippet: 'Selected Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(0.5),
      );
      setState(() {
        markers[pickup] = marker;
      });
      _controller.animateCamera(
          CameraUpdate.newLatLng(LatLng(result.latitude, result.longitude)));
      // _locProvider.setLatLng(result);
      // _controller.animateCamera(cameraUpdate)
    }
    print(result);
  }

  Container buildTextField(String labelText, String placeholder,
      bool isPassword, TextEditingController controller,
      [bool isNumber = false]) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(color: Colors.blueGrey, fontSize: 12),
          ),
          SizedBox(
            height: 5,
          ),
          TextField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: isNumber ? TextInputType.number : TextInputType.url,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(16),
                filled: true,
                fillColor: Colors.grey[200],
                hintText: placeholder,
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]),
                ),
              ))
        ],
      ),
    );
  }

  Widget _textFields() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          buildTextField('Address', 'Enter Address', false, _addressController),
          buildTextField('Street No', 'Street Number', false,
              _streetNumberController, true),
          buildTextField(
              'Zone', 'Enter Zone Number', false, _zoneController, true),
          buildTextField('Building', 'Enter Building Number', false,
              _buildingController, true),
          buildTextField(
              'Landmark', 'Enter Landmark', false, _landmarkController),
        ],
      ),
    );
  }

  void getAddressFromLatLng(LatLng loc) async {
    _place = await LocationHelper.getPlaceByLocation(loc);
    _address = Address(
      area: _place.name,
      latitude: _place.lat,
      longitude: _place.lng,
    );
    _addressController.text = _place.name;

    print('Address : ${_address.area} , ${_place.streetName}, ${_place.zone}');

    setState(() {});
  }

  Widget _mapSnippet() {
    final LocationProvider _locProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final _initialLocation = CameraPosition(
      target: LatLng(25.3557021, 51.2372571),
      zoom: 16.5,
      // tilt: 20,
    );

    if (_locProvider.selectedLatLng != null) {
      final MarkerId pickup = MarkerId('Selected Location');
      final Marker marker = Marker(
        alpha: 0.7,
        markerId: pickup,
        position: _locProvider.selectedLatLng,
        infoWindow:
            InfoWindow(title: pickup.value, snippet: 'Selected Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(0.5),
      );
      setState(() {
        markers[pickup] = marker;
      });
    }

    return Container(
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      height: 200,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: _initialLocation,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              controller.setMapStyle(darkMap);
              setState(() {});
              if (_locProvider.selectedLatLng != null) {
                controller.animateCamera(CameraUpdate.newLatLng(LatLng(
                    _locProvider.selectedLatLng.latitude,
                    _locProvider.selectedLatLng.longitude)));
              }
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            // liteModeEnabled: true,
            mapToolbarEnabled: false,
            markers: Set<Marker>.of(markers.values),
            onTap: (loc) async {
              var res = await Get.to(SelectLocation());
              if (res != null) {
                getAddressFromLatLng(res);
                final MarkerId pickup = MarkerId('Selected Location');
                final Marker marker = Marker(
                  alpha: 0.7,
                  markerId: pickup,
                  position: res,
                  infoWindow: InfoWindow(
                      title: pickup.value, snippet: 'Selected Location'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(0.5),
                );
                setState(() {
                  markers[pickup] = marker;
                });
                _controller.animateCamera(CameraUpdate.newLatLng(
                    LatLng(res.latitude, res.longitude)));
                // _locProvider.setLatLng(result);
                // _controller.animateCamera(cameraUpdate)
              }
            },
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Text(
              'Tap Here to Change Location',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

final darkMap = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#181818"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1b1b1b"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#2c2c2c"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8a8a8a"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#373737"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3c3c3c"
      }
    ]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#4e4e4e"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#000000"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#3d3d3d"
      }
    ]
  }
]
''';
