import 'package:cloud_firestore/cloud_firestore.dart';

class VivekSampleModel {
  String name;
  double amount;
  int count;
  List<String> tokens;
  Map<String, dynamic> item;
  DateTime createdAt;

  VivekSampleModel({
    this.name,
    this.amount,
    this.tokens,
    this.item,
    this.createdAt,
  });

  factory VivekSampleModel.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data;
    return VivekSampleModel(
      name: data['name'],
      tokens: data['tokens'] != null ? List<String>.from(data['tokens']) : [],
      createdAt: data['createdAt']?.toDate() ?? null,
      item: doc['item'] != null ? Map.from(doc['item']) : null,
    );
  }
}
