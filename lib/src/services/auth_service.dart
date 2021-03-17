import 'dart:async';
import 'package:baqaala/src/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user.dart';
import 'package:flutter/services.dart';

class AuthService {
  Firestore _db = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  static AuthService instance = AuthService();

  AuthService();

  Future<User> getUser(String uid) async {
    DocumentSnapshot snapshot =
        await _db.collection('users').document(uid).get();
    User _fUser = new User.fromSnapShot(snapshot);
    return _fUser;
  }

  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _db.collection('users').document(uid).snapshots();
  }

  Future<bool> verifyOTP(int otp, String uid) async {
    var doc = await _db.collection('users').document(uid).get();
    var serverOTP = doc.data['otp'];
    if (otp == serverOTP) {
      doc.reference.updateData({'status': 'verified'});
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateName(String uid, String name) async {
    try {
      await _db.collection('users').document(uid).updateData({'name': name});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateToken({String lang, int buildNumber}) async {
    try {
      FirebaseUser user = await _auth.currentUser();
      var prefs = SharedPrefs.instance;
      String token = await prefs.getToken();
      String lang = await prefs.getLocale();

      if (user != null && token != null) {
        await _db.collection('users').document(user.uid).setData({
          'tokens': FieldValue.arrayUnion([token]),
          'lastLogin': FieldValue.serverTimestamp(),
          'lang': lang,
          // 'buildNumber': buildNumber,
          // 'roles': {'admin': true}
        }, merge: true);
        print('Token Updated');
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updatePassword(String password, String oldPassword) async {
    FirebaseUser user = await _auth.currentUser();

    // user.reauthenticateWithCredential(oldPassword);
    try {
      await _auth.signInWithEmailAndPassword(
          email: user.email, password: oldPassword);
      await user.updatePassword(password);
      return true;
    } on PlatformException catch (e) {
      throw AuthException(e.code, e.message);
      // print(e);
      // return false;
    }
  }

  Future<bool> login({String email, String password}) async {
    try {
      var result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      print(result);
      return true;
    } on PlatformException catch (e) {
      // print(e.code);
      switch (e.code) {
        case 'ERROR_WRONG_PASSWORD':
          throw AuthException('WRONG_PASSWORD', 'Wrong password');
          break;
        case 'ERROR_INVALID_EMAIL':
          throw AuthException('INVALID_EMAIL', 'Invalid email');
          break;
        case 'ERROR_USER_NOT_FOUND':
          throw AuthException('USER_NOT_FOUND', 'User not Found');
          break;
        case 'ERROR_USER_DISABLED':
          throw AuthException('USER_DISABLED', 'Your Account is Blocked');
          break;
        case 'ERROR_TOO_MANY_REQUESTS':
          throw AuthException('TOO_ANY_REQUESTS',
              'Too Many Requests. Please wait sometime and try again.');
          break;
        case 'ERROR_NETWORK_REQUEST_FAILED':
          throw AuthException('NETWORK_ERROR',
              'Network Error, Please Check your internet connection');
          break;
        case 'ERROR_OPERATION_NOT_ALLOWED':
          throw AuthException(
              'OPERATION_NOT_ALLOWED', 'This Operation Not Allowed');
          break;
        default:
          throw AuthException('UNKNOWN_ERROR', e.code);
      }
      // return false;
    }

    // return false;
  }

  Future<User> getUserByMobile(int mobileNumber) async {
    try {
      var doc = await _db
          .collection('users')
          .where('mobile', isEqualTo: mobileNumber)
          .getDocuments();
      if (doc.documents.isEmpty) {
        throw AuthException('USER_NOT_FOUND', 'User Not Found');
      } else {
        User user = User.fromSnapShot(doc.documents.first);
        return user;
      }
    } on PlatformException catch (e) {
      throw AuthException(e.code, e.message);
    }
  }

  Future<bool> register(
      {String email,
      String password,
      String mobile,
      String fullName,
      String countryISO}) async {
    final prefs = SharedPrefs();
    String token = await prefs.getToken();

    String collection = 'users';
    // if (countryISO != null) {
    //   collection = 'users_$countryISO';
    // }

    try {
      var result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      var doc =
          await _db.collection(collection).document(result.user.uid).setData({
        'uid': result.user.uid,
        'name': fullName,
        'email': email,
        'mobile': int.parse(mobile),
        'tokens': FieldValue.arrayUnion([token]),
        'roles': null,
        'countryIso': countryISO,
        'status': 'unverified',
        'otpCount': 0,
        'forgetSMSCount': 0,
      }, merge: true);
      return true;
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          throw AuthException('MOBILE_EXISTS', 'Email Already Exists');
          break;
        case 'ERROR_WEAK_PASSWORD':
          throw AuthException('WEAK_PASSWORD', 'Weak Password');
          break;
        case 'ERROR_INVALID_EMAIL':
          throw AuthException('INVALID_EMAIL', 'Invalid Email');
          break;
        case 'ERROR_NETWORK_REQUEST_FAILED':
          throw AuthException('NETWORK_ERROR',
              'Network Error, Please Check your internet connection');
        default:
          print(e);
          throw AuthException('UNKNOWN_ERROR', e.code);
      }
      // print(e.code);
    }
    // return false;
  }

  Future<bool> assignRole(User user, String role) async {
    try {
      await _db.collection('users').document(user.uid).setData({
        'roles': {
          'admin': role == 'admin',
          'manager': role == 'manager',
          'store_manager': role == 'store_manager',
          'picker': role == 'picker',
          'driver': role == 'driver',
          'qc': role == 'qc',
          'customer_support': role == 'customer_support',
          'investor': role == 'investor',
        }
      }, merge: true);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> setProfileImage(String url, String uid) async {
    try {
      await _db
          .collection('users')
          .document(uid)
          .setData({'profilePicture': url}, merge: true);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<User> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      DocumentSnapshot snapshot =
          await _db.collection('users').document(user.uid).get();
      if (snapshot.exists) {
        User _fUser = new User.fromSnapShot(snapshot);
        return _fUser;
      } else {
        throw ('No User Data Found');
      }
    } else {
      throw ('User Not Logged in.');
    }
  }

  // Future<void> refreshUser() async {
  //   if (user != null) {
  //     DocumentSnapshot snapshot =
  //         await _db.collection('users').document(_user.uid).get();
  //     _fUser = new User.fromSnapShot(snapshot);

  //     _db.collection('providers').document(_user.uid).get().then((doc) {
  //       print(doc.data['status']);
  //       if (doc.data['status'] == 'active') {
  //         _isProvider = true;
  //       }
  //     }).catchError((onError) {});

  //     _db.collection('drivers').document(_user.uid).get().then((doc) {
  //       if (doc.data['status'] == 'active') {
  //         _isDrvier = true;
  //       }
  //     }).catchError((onError) {});

  //     notifyListeners();
  //   }
  // }

  // Future<void> updateToken(String token) async {
  //   if (user != null) {
  //     if (_isTokenUpdated == false) {
  //       print('updating token');

  //       _db.collection('users').document(user?.uid).get().then((data) {
  //         data.reference.updateData(
  //             {'lastLogin': FieldValue.serverTimestamp(), 'token': token});
  //         _fUser = new User.fromSnapShot(data);
  //         _isTokenUpdated = true;
  //         notifyListeners();
  //       });
  //     }
  //   }
  // }

}
