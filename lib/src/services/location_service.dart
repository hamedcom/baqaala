import 'package:background_location/background_location.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  final Firestore _db = Firestore.instance;
  final AuthModel _aService = AuthModel.instance();

  LocationService({this.distanceFilter});

  final distanceFilter;
  LatLng _oldLocation, _newLocation;
  Geolocator _locator = Geolocator();

  Stream<DocumentSnapshot> getLiveLocation(String uid) {
    var res = _db.collection('liveLocation').document(uid).snapshots();
    return res;
  }

  startBackgroundLocationUpdates() {
    BackgroundLocation.startLocationService();

    // AashuBackgroundLocation.startLocationService();

    BackgroundLocation.getLocationUpdates((location) async {
      if (_oldLocation == null) {
        _oldLocation = LatLng(location.latitude, location.longitude);
        _db.collection('liveLocation').document(_aService.userId).setData({
          'latitude': location.latitude,
          'longitude': location.longitude,
          'oldLocation': _oldLocation.toString(),
          'lastUpdated': FieldValue.serverTimestamp()
        }, merge: true);
        print('Location Updated to :$_oldLocation');
      }

      _newLocation = LatLng(location.latitude, location.longitude);

      print(_newLocation);

      double distance = await _locator.distanceBetween(
          _oldLocation.latitude,
          _oldLocation.longitude,
          _newLocation.latitude,
          _newLocation.longitude);

      if (distanceFilter > 0) {
        if (distance > distanceFilter) {
          _db.collection('liveLocation').document(_aService.userId).setData({
            'latitude': location.latitude,
            'longitude': location.longitude,
            'oldLocation': _oldLocation.toString(),
            'lastUpdated': FieldValue.serverTimestamp()
          }, merge: true);
          print('Location Updated to :$_newLocation');
        } else {
          print('Distance is lessthan $distanceFilter for updating..');
        }
      } else if (distanceFilter == 0) {
        _db.collection('liveLocation').document(_aService.userId).setData({
          'latitude': location.latitude,
          'longitude': location.longitude,
          'oldLocation': _oldLocation.toString(),
          'lastUpdated': FieldValue.serverTimestamp()
        }, merge: true);
        print('Location Updated to :$_newLocation');
      }

      _oldLocation = _newLocation;
    });
  }

  setLiveLocationToOrder(String orderID) {
    BackgroundLocation.startLocationService();
    // AashuBackgroundLocation.startLocationService();

    BackgroundLocation.getLocationUpdates((location) async {
      if (_oldLocation == null) {
        _oldLocation = LatLng(location.latitude, location.longitude);
        _db.collection('orders').document(orderID).setData({
          'vehicleLocations': {
            _aService.userId: '${location.latitude}_${location.longitude}'
          }
        }, merge: true);

        // _db.collection('liveLocation').document(_aService.userId).setData({
        //   'latitude': location.latitude,
        //   'longitude': location.longitude,
        //   'oldLocation': _oldLocation.toString(),
        //   'lastUpdated': FieldValue.serverTimestamp()
        // }, merge: true);
        // print('Location Updated to :$_oldLocation');
      }

      _newLocation = LatLng(location.latitude, location.longitude);

      print(_newLocation);

      double distance = await _locator.distanceBetween(
          _oldLocation.latitude,
          _oldLocation.longitude,
          _newLocation.latitude,
          _newLocation.longitude);

      if (distanceFilter > 0) {
        if (distance > distanceFilter) {
          // _db.collection('liveLocation').document(_aService.userId).setData({
          //   'latitude': location.latitude,
          //   'longitude': location.longitude,
          //   'oldLocation': _oldLocation.toString(),
          //   'lastUpdated': FieldValue.serverTimestamp()
          // }, merge: true);
          _db.collection('orders').document(orderID).setData({
            'vehicleLocations': {
              _aService.userId: '${location.latitude}_${location.longitude}'
            }
          }, merge: true);
          // print('Location Updated to :$_newLocation');
        } else {
          print('Distance is lessthan $distanceFilter for updating..');
        }
      } else if (distanceFilter == 0) {
        // _db.collection('liveLocation').document(_aService.userId).setData({
        //   'latitude': location.latitude,
        //   'longitude': location.longitude,
        //   'oldLocation': _oldLocation.toString(),
        //   'lastUpdated': FieldValue.serverTimestamp()
        // }, merge: true);
        _db.collection('bookings').document(orderID).setData({
          'vehicleLocations': {
            _aService.userId: '${location.latitude}_${location.longitude}'
          }
        }, merge: true);
        // print('Location Updated to :$_newLocation');
      }

      _oldLocation = _newLocation;
    });
  }

  stopBackgroundLocationUpdates() {
    BackgroundLocation.stopLocationService();
  }
}
