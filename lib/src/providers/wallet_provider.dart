import 'package:baqaala/src/providers/base_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletProvider extends BaseProvider {
  Firestore _db = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  static WalletProvider instance = WalletProvider();
  double _balance = 0;
  bool _isFetching = false;

  WalletProvider() {
    getBalance();
  }

  double get balance => _balance;
  bool get isFetching => _isFetching;

  getBalance() async {
    _isFetching = true;
    notifyListeners();
    _user = await _auth.currentUser();
    print(_user.uid);
    if (_user != null) {
      _db
          .collection('users')
          .document(_user.uid)
          .collection('wallet')
          .document('wallet')
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          _balance = doc['balance'] != null ? doc['balance'].toDouble() : 0;
        }
        _isFetching = false;
        notifyListeners();
      });
    } else {
      getBalance();
    }
  }
}
