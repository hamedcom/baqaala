import 'dart:convert';

import 'package:baqaala/src/models/cart_item.dart';
import 'package:baqaala/src/models/slot.dart';
import 'package:baqaala/src/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  waiting_for_store_to_accept,
  store_accepted,
  store_cancelled,
  picker_updated,
  customer_updated,
  customer_accepted,
  customer_cancelled,
  unpaid,
  paid,
  delivered,
  driver_cancelled,
}

enum PaymentMethod { card, cash_on_delivery, card_on_delivery }

class Order {
  String id;
  String orderNumber;
  String storeId;
  String storeCode;
  String storeName;
  String customerId;
  List<String> pickerIds;
  String driverId;
  User customer;
  User storeManager; // assigned Store Manager
  User picker; // assigned Picker
  User driver; // assigned Driver
  Slot slot;
  List<CartItem> items;
  int totalItems;
  double total;
  double confirmedTotal;
  int convenienceFee;
  int status;
  String orderStatus; // pending, cancelled, completed
  String statusMessage;
  Address address;
  bool isConfirmed;
  bool isDriverStarted;
  bool isPickerConfirmed;
  bool isPickerUpdated;
  bool isCustomerConfirmed;
  bool isOrderModified;
  String paymentMethod; // Cash on delivery, Card on delivery , Credit Card

  DateTime createdAt;
  DateTime updatedAt;
  DateTime pickerUpdatedAt;

  Order({
    this.id,
    this.orderNumber,
    this.storeId,
    this.storeCode,
    this.storeName,
    this.customerId,
    this.pickerIds,
    this.driverId,
    this.customer,
    this.storeManager,
    this.picker,
    this.driver,
    this.items,
    this.totalItems,
    this.total,
    this.confirmedTotal,
    this.convenienceFee,
    this.status,
    this.isDriverStarted,
    this.statusMessage,
    this.slot,
    this.address,
    this.orderStatus,
    this.createdAt,
    this.updatedAt,
    this.pickerUpdatedAt,
    this.isConfirmed,
    this.isPickerConfirmed,
    this.isPickerUpdated,
    this.isCustomerConfirmed,
    this.isOrderModified,
    this.paymentMethod,
  });

  factory Order.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data;
    List<CartItem> cartitems;
    if (data['items'] != null) {
      var slotObjsJson = jsonDecode(data['items']) as List;
      cartitems =
          slotObjsJson.map((slotJson) => CartItem.fromJson(slotJson)).toList();
      // print(slots);
    } else {
      cartitems = [];
    }

    return Order(
      id: doc.documentID,
      storeId: data['storeId'],
      storeCode: data['storeCode'],
      storeName: data['storeName'],
      orderNumber: data['orderNumber'],
      customerId: data['customerId'],
      isConfirmed: data['isConfirmed'] ?? false,
      isDriverStarted: data['isDriverStarted'] ?? false,
      isPickerUpdated: data['isPickerUpdated'] ?? false,
      isPickerConfirmed: data['isPickerConfirmed'] ?? false,
      isCustomerConfirmed: data['isCustomerConfirmed'] ?? false,
      isOrderModified: data['isOrderModified'] ?? false,
      pickerIds:
          data['pickerIds'] != null ? List<String>.from(data['pickerIds']) : [],
      driverId: data['driverId'],
      totalItems: data['totalItems'],
      total: data['total'],
      confirmedTotal: data['confirmedTotal'] ?? 0,
      convenienceFee: data['convenienceFee'] ?? 10,
      status: data['status'],
      orderStatus: data['orderStatus'],
      createdAt: data['createdAt'] != null ? data['createdAt'].toDate() : null,
      updatedAt: data['updatedAt'] != null ? data['updatedAt'].toDate() : null,
      pickerUpdatedAt: data['pickerUpdatedAt'] != null
          ? data['pickerUpdatedAt'].toDate()
          : null,
      statusMessage: data['statusMessage'],
      paymentMethod: data['paymentMethod'] ?? 'Cash On Delivery',
      slot: data['slot'] != null
          ? Slot.fromJson(Map<String, dynamic>.from(data['slot']))
          : null,
      address: data['address'] != null
          ? Address.fromJson(Map<String, dynamic>.from(data['address']))
          : null,
      storeManager: data['storeManager'] != null
          ? User.fromJson(Map<String, dynamic>.from(data['storeManager']))
          : null,
      driver: data['driver'] != null
          ? User.fromJson(Map<String, dynamic>.from(data['driver']))
          : null,
      picker: data['picker'] != null
          ? User.fromJson(Map<String, dynamic>.from(data['picker']))
          : null,
      customer: data['customer'] != null
          ? User.fromJson(Map<String, dynamic>.from(data['customer']))
          : null,
      items: cartitems,
    );
  }

  Map<String, dynamic> toJson() {
    var itms = [];
    items.forEach((value) {
      itms.add(value.toJSON());
    });

    var it = jsonEncode(itms);
    return {
      'id': id,
      'storeCode': storeCode,
      'storeName': storeName,
      'orderNumber': orderNumber,
      'storeManager': storeManager?.toJSON(),
      'driver': driver?.toJSON(),
      'picker': picker?.toJSON(),
      'customer': customer?.toJSON(),
      'slot': slot != null ? slot.toJson() : null,
      'items': it,
      'storeId': storeId,
      'isDriverStarted': isDriverStarted,
      'isPickerConfirmed': isPickerConfirmed,
      'isPickerUpdated': isPickerUpdated,
      'isCustomerConfirmed': isCustomerConfirmed,
      'isOrderModified': isOrderModified,
      'customerId': customerId,
      'pickerId': pickerIds,
      'driverId': driverId,
      'isConfirmed': isConfirmed,
      'total': total,
      'convenienceFee': convenienceFee,
      'confirmedTotal': confirmedTotal,
      'totalItems': totalItems,
      'paymentMethod': paymentMethod,
      'status': status,
      'orderStatus': orderStatus,
      'createdAt': createdAt,
      'pickerUpdatedAt': pickerUpdatedAt,
      'updatedAt': updatedAt,
      'statusMessage': statusMessage,
      'address': address != null ? address.toJSON() : null,
    };
  }
}
