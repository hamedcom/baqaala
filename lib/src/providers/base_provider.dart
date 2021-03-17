import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class BaseProvider extends ChangeNotifier {
  final Firestore db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _busy = false;

  String _errorMessage;

  bool get busy => _busy;
  FirebaseAuth get auth => _auth;
  String get errorMessage => _errorMessage;
  bool get hasErrorMessage => _errorMessage != null && _errorMessage.isNotEmpty;

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }
}
