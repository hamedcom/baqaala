import 'package:baqaala/src/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuggestItem {
  String id;
  String imageUrl;
  User user;
  String itemName;
  String itemDescription;
  DateTime createdAt;

  SuggestItem({
    this.id,
    this.imageUrl,
    this.user,
    this.itemName,
    this.itemDescription,
    this.createdAt,
  });

  factory SuggestItem.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data;
    return SuggestItem(
      id: doc.documentID,
      imageUrl: data['imageUrl'],
      itemName: data['itemName'],
      itemDescription: data['itemDescription'],
      user: data['user'] != null
          ? User.fromJson(Map<String, dynamic>.from(data['user']))
          : null,
      createdAt: data['createdAt'] != null ? data['createdAt'].toDate() : null,
    );
  }

  Map<String, dynamic> toJSON() => {
        'id': id,
        'user': user != null ? user.toJSON() : null,
        'imageUrl': imageUrl,
        'itemName': itemName,
        'itemDescription': itemDescription,
        'createdAt': createdAt
      };
}
