import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  String id;
  String name;
  String address;
  String placeId;
  String streetName;
  String buildingNumber;
  String zone;
  String landmark;
  DateTime createdAt;
  double lat;
  double lng;

  Place({
    this.id,
    this.name,
    this.address,
    this.lat,
    this.lng,
    this.placeId,
    this.streetName,
    this.buildingNumber,
    this.zone,
    this.createdAt,
    this.landmark,
  });

  factory Place.fromFirestore(DocumentSnapshot doc) {
    // Map data = doc.data;
    return Place(
        id: doc.documentID,
        name: doc['name'] ?? '',
        address: doc['address'] ?? '',
        lat: doc['lat'],
        lng: doc['lng'],
        placeId: doc['placeId'],
        streetName: doc['streetName'],
        buildingNumber: doc['buildingNumber'],
        zone: doc['zone'],
        createdAt: doc['createdAt']?.toDate(),
        landmark: doc['landmark']);
  }

  Place.fromJson(Map<String, dynamic> doc) {
    id = doc['id'];
    name = doc['name'] ?? '';
    address = doc['address'] ?? '';
    lat = doc['lat'];
    lng = doc['lng'];
    placeId = doc['placeId'];
    streetName = doc['streetName'];
    buildingNumber = doc['buildingNumber'];
    zone = doc['zone'];
    createdAt = doc['createdAt']?.toDate();
    landmark = doc['landmark'];
  }

  // static List<Place> fromJson(Map<String, dynamic> json) {
  //   List<Place> places = new List();

  //   var results = json['results'] as List;
  //   for (var item in results) {
  //     var p = Place(
  //         id: item['id'],
  //         name: item['name'],
  //         address: item['address'],
  //         placeId: item['placeId'],
  //         lat: item['lat'],
  //         lng: item['lng'],
  //         streetName: item['streetName'],
  //         buildingNumber: item['buildingNumber'],
  //         zone: item['zone'],
  //         landmark: item['landmark']);

  //     places.add(p);
  //   }

  //   return places;
  // }

  Map<String, dynamic> toJSON() => {
        'id': id,
        'name': name,
        'address': address,
        'placeId': placeId,
        'lat': lat,
        'lng': lng,
        'streetName': streetName,
        'buildingNumber': buildingNumber,
        'zone': zone,
        'createdAt': createdAt,
        'landmark': landmark,
      };
}
