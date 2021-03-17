import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppSettingsService {
  Firestore _db = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
}
