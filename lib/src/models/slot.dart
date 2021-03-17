import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Slot {
  String id;
  String title; // 09PM - 05PM
  bool isEnable;
  int maxOrders;
  int maxValue;
  String startTime;
  String endTime;
  String closeTime;
  List<String> days; // ['sunday','monday']

  Slot({
    this.id,
    this.title,
    this.isEnable,
    this.maxValue,
    this.maxOrders,
    this.startTime,
    this.endTime,
    this.closeTime,
    this.days,
  });

  factory Slot.fromJson(Map<String, dynamic> data) {
    return Slot(
      id: data['id'],
      title: data['title'],
      isEnable: data['isEnable'] ?? false,
      maxOrders: data['maxOrders'],
      maxValue: data['maxValue'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      closeTime: data['closeTime'],
      days: data["days"] != null ? List<String>.from(data['days']) : [],
    );
  }

  factory Slot.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data;
    return Slot(
      id: doc.documentID,
      title: data['title'],
      isEnable: data['isEnable'] ?? false,
      maxOrders: data['maxOrders'],
      maxValue: data['maxValue'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      closeTime: data['closeTime'],
      days: data["days"] != null ? List<String>.from(data['days']) : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isEnable': isEnable,
        'maxOrders': maxOrders,
        'maxValue': maxValue,
        'startTime': startTime,
        'endTime': endTime,
        'closeTime': closeTime,
        'days': days,
      };
}

List<Slot> allSlots = [
  Slot(id: '08 AM - 10 AM', title: '08 AM - 10 AM', isEnable: false),
  Slot(id: '10 AM - 12 PM', title: '10 AM - 12 PM', isEnable: false),
  Slot(id: '12 AM - 02 PM', title: '12 AM - 02 PM', isEnable: false),
  Slot(id: '02 PM - 04 PM', title: '02 PM - 04 PM', isEnable: false),
  Slot(id: '04 PM - 06 PM', title: '04 PM - 06 PM', isEnable: true),
  Slot(id: '06 PM - 08 PM', title: '06 PM - 08 PM', isEnable: true),
  Slot(id: '08 PM - 10 PM', title: '08 PM - 10 PM', isEnable: true),
  Slot(id: '10 PM - 12 AM', title: '10 PM - 12 AM', isEnable: false),
];
