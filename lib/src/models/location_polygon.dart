import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPolygon {
  String id;
  String storeId;
  String areaName;
  List<LatLng> polygons;

  LocationPolygon({
    this.id,
    this.storeId,
    this.areaName,
    this.polygons,
  });

  factory LocationPolygon.fromFirestore(DocumentSnapshot doc) {
    return LocationPolygon(
      id: doc.documentID,
      storeId: doc['storeId'],
      areaName: doc['areaName'],
      polygons: doc['polygons'],
    );
  }
}
