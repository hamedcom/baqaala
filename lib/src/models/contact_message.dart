import 'package:baqaala/src/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactMessage {
  String id;
  String imageUrl;
  User user;
  String message;
  DateTime createdAt;

  ContactMessage({
    this.id,
    this.imageUrl,
    this.user,
    this.message,
    this.createdAt,
  });

  factory ContactMessage.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data;
    return ContactMessage(
      id: doc.documentID,
      imageUrl: data['imageUrl'],
      message: data['message'],
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
        'message': message,
        'createdAt': createdAt
      };
}
