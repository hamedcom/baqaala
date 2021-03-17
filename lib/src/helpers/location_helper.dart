import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:baqaala/src/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geolocation.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;

import "package:google_maps_webservice/places.dart";
// import 'package:google_maps_webservice/directions.dart';
// import 'package:google_maps_webservice/distance.dart';
import 'package:google_maps_webservice/geocoding.dart';
// import 'package:google_maps_webservice/geolocation.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:google_maps_webservice/timezone.dart';
import 'package:http/http.dart';
import 'package:geolocator/geolocator.dart';

const GOOGLE_API_KEY = 'AIzaSyCPfSi4qxuGbKZffnWiTmI2uoOZiGbe-7o';

class LocationHelper {
  // Returns Formated Addres of LatLng
  static Future<String> getPlaceAddress(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&language=en&key=$GOOGLE_API_KEY';
    final response = await http.get(url);
    return json.decode(response.body)['results'][0]['formatted_address'];
  }

  // Returns Place using search Query
  static Future getPalcebyText(String query) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$query&inputtype=textquery&fields=formatted_address,name,geometry&language=en&key=$GOOGLE_API_KEY';

    final response = await http.get(url);

    return json.decode(response.body);
  }

  static Future<PlacesAutocompleteResponse> getAutoComplete(String query,
      [String countryISO = 'qa']) async {
    BaseClient httpClient;

    final GoogleMapsPlaces places =
        GoogleMapsPlaces(apiKey: GOOGLE_API_KEY, httpClient: httpClient);

    return await places.autocomplete(query,
        language: 'en', components: [Component('country', countryISO)]);

    // places.autocomplete(query).then((val) {
    //   return val.predictions;
    // });
  }

  static Future<Place> getPlaceByID(String id) async {
    BaseClient httpClient;
    Place place = Place();

    final GoogleMapsPlaces places =
        GoogleMapsPlaces(apiKey: GOOGLE_API_KEY, httpClient: httpClient);

    PlacesDetailsResponse p = await places.getDetailsByPlaceId(id);

    place.name = p.result.formattedAddress;
    place.lat = p.result.geometry.location.lat;
    place.lng = p.result.geometry.location.lng;

    return place;
  }

  static Future<Place> getPlaceByLocation(LatLng position) async {
    BaseClient httpClient;
    Place place = Place();
    final GoogleMapsGeocoding places =
        GoogleMapsGeocoding(apiKey: GOOGLE_API_KEY, httpClient: httpClient);
    try {
      var res = await places
          .searchByLocation(Location(position.latitude, position.longitude));
      place.name = res.results.first.formattedAddress;
      place.lat = res.results.first.geometry.location.lat;
      place.lng = res.results.first.geometry.location.lng;

      return place;
    } catch (e) {
      print(e);
    }
  }

  // Returns Unit8List for Asset Image used as Marker for Maps

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  static Future<Uint8List> getBytesFromCanvas2(
      int width, int height, String text) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.grey;
    final Radius radius = Radius.circular(0.0);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: text,
      style: TextStyle(fontSize: 25.0, color: Colors.pink),
    );
    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * 0.5) - painter.height * 0.5));
    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

  static Future<LatLng> getCurrentLocation() async {
    Geolocator location = Geolocator();
    Position position = await location.getLastKnownPosition();
    return LatLng(position.latitude, position.longitude);
  }

  // Getting Live location Stream
  static getLiveLocation() async {
    Geolocator location = Geolocator();
    location.getPositionStream().listen((pos) {
      return LatLng(pos.latitude, pos.longitude);
    });
  }

  static Future<Place> getPlaceByCurrentLocation() async {
    BaseClient httpClient;
    Place place = Place();

    Geolocator location = Geolocator();

    final GoogleMapsGeocoding places =
        GoogleMapsGeocoding(apiKey: GOOGLE_API_KEY, httpClient: httpClient);

    Position position = await location.getLastKnownPosition();

    // print(position);

    try {
      var res = await places
          .searchByLocation(Location(position.latitude, position.longitude));

      place.name = res.results.first.formattedAddress;
      place.lat = position.latitude; // res.results.first.geometry.location.lat;
      place.lng =
          position.longitude; // res.results.first.geometry.location.lng;

      return place;
    } catch (e) {
      print(e);
      return null;
      // throw (e);
      // print('Error');
      // print(e);
    }
  }

  static Future getPalcebyText2(String query) async {
    GoogleMapsPlaces places;
    BaseClient httpClient;

    places = GoogleMapsPlaces(apiKey: GOOGLE_API_KEY, httpClient: httpClient);

    places.searchByText(query, language: 'en').then((val) {
      // print('Name :${val.results[0].formattedAddress}');
      // print('Location : ${val.results[0].geometry.location}');
    });

    // final url =
    //     'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$query&inputtype=textquery&fields=formatted_address,name,geometry&key=$GOOGLE_API_KEY';

    // final response = await http.get(url);

    // return json.decode(response.body);
  }

  // Returns Distance and  Route CoOrdinates (Path) of two LatLng
  static Future getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$GOOGLE_API_KEY";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    var distance = values["routes"][0]["legs"][0]["distance"];
    var points = values["routes"][0]["overview_polyline"]["points"];

    return [distance, points];
  }

  // var bounds = LatLngBounds();

  static List<LatLng> convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  static Set<Polyline> createRoute(String encondedPoly) {
    Set<Polyline> polyLines = {};
    polyLines.add(Polyline(
        polylineId: PolylineId('route'),
        width: Platform.isIOS ? 2 : 2,
        points: convertToLatLng(decodePoly(encondedPoly)),
        jointType: JointType.round,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        color: Colors.black));
    return polyLines;
  }

  static List decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    // print(lList.toString());

    return lList;
  }

  // Custom Markers..

  static Future<Uint8List> getBytesFromCanvas(
      int width, int height, urlAsset) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final ByteData datai = await rootBundle.load(urlAsset);
    var imaged = await loadImage(new Uint8List.view(datai.buffer));
    canvas.drawImageRect(
      imaged,
      Rect.fromLTRB(
          0.0, 0.0, imaged.width.toDouble(), imaged.height.toDouble()),
      Rect.fromLTRB(0.0, 0.0, width.toDouble(), height.toDouble()),
      new Paint(),
    );

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

  static Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}
