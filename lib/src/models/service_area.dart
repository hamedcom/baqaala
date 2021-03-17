import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceArea {
  String id;
  String storeId;
  String storeTypeId; // Grocery, Fish
  String
      polygonData; // as LatLng list like : 24.34554_56.43324,24.45434_56.233223,24.5654_65.3233
  bool isActive;
  List<LatLng> latlngList;
  String title;
  double convenienceFee;
  int daysToDisplay;

  ServiceArea({
    this.id,
    this.title,
    this.storeId,
    this.storeTypeId,
    this.polygonData,
    this.isActive,
    this.convenienceFee,
    this.daysToDisplay,
  });

  factory ServiceArea.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data;
    return ServiceArea(
      id: doc.documentID,
      storeId: data['storeId'],
      storeTypeId: data['storeTypeId'],
      title: data['title'],
      polygonData: data['polygonData'],
      convenienceFee: data['convenienceFee'],
      daysToDisplay: data['daysToDisplay'] ?? 1,
      isActive: data['isActive'] ?? true,
    );
  }

  ServiceArea.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    storeId = data['storeId'];
    storeTypeId = data['storeTypeId'];
    title = data['title'];
    polygonData = data['polygonData'];
    convenienceFee = data['convenienceFee'];
    daysToDisplay = data['daysToDisplay'] ?? 1;

    isActive = data['isActive'] ?? true;
  }
  Map<String, dynamic> toJSON() => {
        'id': id,
        'storeId': storeId,
        'storeTypeId': storeTypeId,
        'title': title,
        'polygonData': polygonData,
        'convenienceFee': convenienceFee,
        'daysToDisplay': daysToDisplay,
        'isActive': isActive,
      };
}
