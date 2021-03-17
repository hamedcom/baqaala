import 'dart:convert';

import 'package:baqaala/src/models/store_category.dart';
import 'package:baqaala/src/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'slot.dart';

class Store {
  String id;
  String storeName;
  String storeCode;
  User storeManager;
  String managerId;
  String categoryId;
  StoreCategory category;
  bool isStoreOpen;
  bool isStoreActive;
  bool isSlotSystemEnabled; // slot system or direct delivery
  List<Slot> availableSlots;
  List<String> pickerIds;
  List<String> driverIds;
  List<String> qcIds;
  bool isSlotAutoDisable;
  int maxOrderPerSlot; // 100 orders
  int maxValuePerSlot; // 5000 QR
  bool isAllSlotsMaxOrderAndValue;
  bool isServiceByArea; // location polygon or radius
  double radius; // in meteres ex: 1500 meters
  LatLng location;
  double minOrderValue;
  double minCartValue;
  double minForFreeDelivery;
  DateTime createdAt;
  DateTime updatedAt;

  Store({
    this.id,
    this.storeName,
    this.storeCode,
    this.createdAt,
    this.updatedAt,
    this.storeManager,
    this.managerId,
    this.categoryId,
    this.category,
    this.isStoreOpen,
    this.isStoreActive,
    this.isSlotSystemEnabled,
    this.isSlotAutoDisable,
    this.maxOrderPerSlot,
    this.maxValuePerSlot,
    this.availableSlots,
    this.isServiceByArea,
    this.radius,
    this.location,
    this.minCartValue,
    this.minOrderValue,
    this.minForFreeDelivery,
    this.isAllSlotsMaxOrderAndValue,
    this.pickerIds,
    this.driverIds,
    this.qcIds,
  });

  factory Store.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data;
    List<Slot> slots;
    if (data['availableSlots'] != null) {
      var slotObjsJson = jsonDecode(data['availableSlots']) as List;
      slots = slotObjsJson.map((slotJson) => Slot.fromJson(slotJson)).toList();
      // print(slots);
    } else {
      slots = [];
    }

    return Store(
      id: doc.documentID,
      storeName: data['storeName'] ?? '',
      storeManager: data['storeManager'] != null
          ? User.fromJson(Map<String, dynamic>.from(data['storeManager']))
          : null,
      managerId: data['managerId'],
      storeCode: data['storeCode'],
      categoryId: data['categoryId'],
      category: data['category'] != null
          ? StoreCategory.fromJSON(Map<String, dynamic>.from(data['category']))
          : null,
      isStoreOpen: data['isStoreOpen'] ?? true,
      isStoreActive: data['isStoreActive'] ?? true,
      isSlotSystemEnabled: data['isSlotSystemEnabled'] ?? true,
      isSlotAutoDisable: data['isSlotAutoDisable'] ?? false,
      maxOrderPerSlot: data['maxOrderPerSlot'],
      maxValuePerSlot: data['maxValuePerSlot'],
      availableSlots: slots,
      pickerIds:
          doc['pickerIds'] != null ? List<String>.from(doc['pickerIds']) : [],
      driverIds:
          doc['driverIds'] != null ? List<String>.from(doc['driverIds']) : [],
      qcIds: doc['qcIds'] != null ? List<String>.from(doc['qcIds']) : [],
      createdAt: data['createdAt'] != null ? data['createdAt'].toDate() : null,
      updatedAt: data['updatedAt'] != null ? data['updatedAt'].toDate() : null,
      isServiceByArea: data['isServiceByArea'] ?? true,
      isAllSlotsMaxOrderAndValue: data['isAllSlotsMaxOrderAndValue'] ?? false,
      radius: data['radius'] != null ? data['radius'].toDouble() : 1000,
      location:
          data['location'] != null ? LatLng.fromJson(data['location']) : null,
    );
  }

  factory Store.fromJson(Map<String, dynamic> data) {
    List<Slot> slots;
    if (data['availableSlots'] != null) {
      var slotObjsJson = jsonDecode(data['availableSlots']) as List;
      slots = slotObjsJson.map((slotJson) => Slot.fromJson(slotJson)).toList();
      // print(slots);
    } else {
      slots = [];
    }

    return Store(
      id: data['id'],
      storeName: data['storeName'] ?? '',
      storeManager: data['storeManager'] != null
          ? User.fromJson(Map<String, dynamic>.from(data['storeManager']))
          : null,
      managerId: data['managerId'],
      storeCode: data['storeCode'],
      categoryId: data['categoryId'],
      category: data['category'] != null
          ? StoreCategory.fromJSON(Map<String, dynamic>.from(data['category']))
          : null,
      isStoreOpen: data['isStoreOpen'] ?? true,
      isStoreActive: data['isStoreActive'] ?? true,
      isSlotSystemEnabled: data['isSlotSystemEnabled'] ?? true,
      isSlotAutoDisable: data['isSlotAutoDisable'] ?? false,
      maxOrderPerSlot: data['maxOrderPerSlot'],
      createdAt: data['createdAt'] != null ? data['createdAt'].toDate() : null,
      updatedAt: data['updatedAt'] != null ? data['updatedAt'].toDate() : null,
      maxValuePerSlot: data['maxValuePerSlot'],
      isAllSlotsMaxOrderAndValue: data['isAllSlotsMaxOrderAndValue'] ?? false,
      availableSlots: slots,
      pickerIds:
          data['pickerIds'] != null ? List<String>.from(data['pickerIds']) : [],
      driverIds:
          data['driverIds'] != null ? List<String>.from(data['driverIds']) : [],
      qcIds: data['qcIds'] != null ? List<String>.from(data['qcIds']) : [],
      isServiceByArea: data['isServiceByArea'] ?? true,
      radius: data['radius'] != null ? data['radius'].toDouble() : 1000,
      location:
          data['location'] != null ? LatLng.fromJson(data['location']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'storeName': storeName,
        'storeCode': storeCode,
        'storeManager': storeManager?.toJSON(),
        'managerId': managerId,
        'categoryId': categoryId,
        'category': category?.toJSON(),
        'isStoreOpen': isStoreOpen,
        'isStoreActive': isStoreActive,
        'isSlotSystemEnabled': isSlotSystemEnabled,
        'isSlotAutoDisable': isSlotAutoDisable,
        'maxOrderPerSlot': maxOrderPerSlot,
        'maxValuePerSlot': maxValuePerSlot,
        'isAllSlotsMaxOrderAndValue': isAllSlotsMaxOrderAndValue,
        'availableSlots': availableSlots,
        'isServiceByArea': isServiceByArea,
        'radius': radius,
        'location': location?.toJson(),
      };
}
