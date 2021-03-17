import 'package:baqaala/src/models/country.dart';
import 'package:baqaala/src/services/auth_service.dart';
import 'package:baqaala/src/services/shared_pref.dart';
import 'package:baqaala/src/services/snackbar_service.dart';
import 'package:baqaala/src/widgets/auth/verify_mobile.dart';
import 'package:get/get.dart';

import '../models/user.dart';
import 'package:baqaala/src/providers/base_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthModel extends BaseProvider {
  AuthService _authService = AuthService();
  FirebaseAuth _auth;
  FirebaseUser _user;
  User _fUser;
  Status _status = Status.Uninitialized;
  Firestore _db = Firestore.instance;
  SharedPrefs prefs;
  String _newToken;
  bool _isTokenUpdated = false;
  bool _isProvider;
  bool _isDriver;
  bool _isPasswordValid = false,
      _isEmailValid = false,
      _isOldPasswordValid = false,
      _isMobileNumberValid = false,
      isLoginBusy = false,
      isRegisterBusy = false,
      isForgetPasswordBusy = false,
      isOTPValid = false,
      isFullNameValid = false;
  Country _selectedCountry;
  String _appId, _otpCode;

  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  String _otpError;
  String _mobileNumberError;
  String _passwordError, _oldPasswordError;
  String _fullNameError;
  double _balance;
  Address _defaultAddress;
  Address _selectedAddress;

  Address get defaultAddress => _defaultAddress;
  Address get selectedAddress => _selectedAddress;
  bool get isMobileNumberValid => _isMobileNumberValid;
  bool get isEmailValid => _isEmailValid;
  bool get isPasswordValid => _isPasswordValid;
  bool get isOldPasswordValid => _isOldPasswordValid;
  String get otpCode => _otpCode;
  String get appId => _appId;

  AuthModel.instance() : _auth = FirebaseAuth.instance {
    _auth.onAuthStateChanged.listen(_onAuthStateChanged);

    // signOut();

    prefs = SharedPrefs();
    prefs.getToken().then((value) {
      _newToken = value;
    });
    passwordController.addListener(() {
      String pass = passwordController.text;
      _passwordError = null;
      _isPasswordValid = false;
      notifyListeners();
      if (pass != null) {
        if (pass.length < 6) {
          _passwordError = "Password must be minium 6 characters";
          notifyListeners();
        } else {
          _isPasswordValid = true;
          notifyListeners();
        }
      }
    });

    oldPasswordController.addListener(() {
      String pass = oldPasswordController.text;
      _oldPasswordError = null;
      _isOldPasswordValid = false;
      notifyListeners();
      if (pass != null) {
        if (pass.length < 6) {
          _oldPasswordError = "Password must be minium 6 characters";
          notifyListeners();
        } else {
          _isOldPasswordValid = true;
          notifyListeners();
        }
      }
    });

    otpController.addListener(() {
      String otp = otpController.text;
      _otpError = null;
      isOTPValid = false;
      if (otp != null) {
        if (otp.length < 4 || otp.length > 4) {
          _otpError = 'OTP must be 4 Digits';
          notifyListeners();
        } else {
          isOTPValid = true;
          notifyListeners();
        }
      }
    });

    fullNameController.addListener(() {
      String pass = fullNameController.text;
      _fullNameError = null;
      isFullNameValid = false;
      notifyListeners();
      if (pass != null) {
        if (pass.length < 3) {
          _fullNameError = "Name must be minium 3 characters";
          notifyListeners();
        } else {
          isFullNameValid = true;
          notifyListeners();
        }
      }
    });

    emailController.addListener(() {
      String pass = emailController.text;
      _fullNameError = null;
      isFullNameValid = false;
      notifyListeners();
      if (pass != null) {
        if (pass.length < 3 && !pass.contains('@')) {
          _fullNameError = "Enter Valid Email";
          notifyListeners();
        } else {
          isFullNameValid = true;
          notifyListeners();
        }
      }
    });

    mobileNumberController.addListener(() async {
      String val = mobileNumberController.text;
      _mobileNumberError = null;
      _isMobileNumberValid = false;
      notifyListeners();

      if (val != null) {
        if (val.length < 8) {
          _mobileNumberError = 'Enter a Valid Mobile Number';
          notifyListeners();
        }

        if (_selectedCountry == null) {
          await fetchSelectedCountry();
        } else if (val.length > 5) {
          RegExp exp = RegExp(_selectedCountry?.regex);
          if (exp == null) {
            _isMobileNumberValid = true;
            notifyListeners();
          } else {
            bool isValidNumber = exp.hasMatch(val);

            if (isValidNumber) {
              _isMobileNumberValid = true;
              notifyListeners();
              // print('Valid ${_selectedCountry.name} Mobile Number');
            } else {
              _mobileNumberError =
                  'Not a Valid ${_selectedCountry.name} Mobile Number';
              notifyListeners();
            }
          }
        }
      }
    });

    // mobileNumberController.text = '';
    // passwordController.text = '';
  }

  Status get authStatus => _status;
  String get mobileNumberError => _mobileNumberError;
  String get passwordError => _passwordError;
  String get oldPasswordError => _oldPasswordError;

  String get fullNameErrror => _fullNameError;
  FirebaseUser get firebaseUser => _user;
  FirebaseAuth get firebaseAuth => _auth;
  String get userId => _user.uid;
  String get userName => _fUser.name;
  double get balance => _balance;
  List<String> get userTokens => _fUser.tokens;
  Country get selectedCountry => _selectedCountry;
  int get userMobile => _fUser.mobile;
  bool get isProvider => _isProvider = false;
  bool get isDriver => _isDriver = false;

  User get fUser => _fUser;

  bool checkRole(String role) {
    if (_fUser?.roles != null) {
      if (_fUser.roles[role] != null) {
        return _fUser.roles[role];
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  String getRole(var roles) {
    String role = 'Not Assigned';
    if (roles == null) {
      return role;
    } else {
      roles = Map<dynamic, dynamic>.from(roles);
    }

    if (roles['admin'] ?? false) role = "Admin";
    if (roles['manager'] ?? false) role = 'Manager';
    if (roles['store_manager'] ?? false) role = 'Store Manager';
    if (roles['picker'] ?? false) role = 'Picker';
    if (roles['driver'] ?? false) role = 'Driver';
    if (roles['qc'] ?? false) role = 'Quality Controller';
    if (roles['customer_support'] ?? false) role = 'Customer Support';
    if (roles['investor'] ?? false) role = 'Investor';

    return role;
  }

  void setCountry(Country country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void setAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<bool> updateName() async {
    return await _authService.updateName(fUser.uid, fullNameController.text);
  }

  Future<bool> updatePassword() async {
    try {
      return await _authService.updatePassword(
          passwordController.text, oldPasswordController.text);
    } on AuthException catch (e) {
      throw AuthException(e.code, e.message);
    }
  }

  Future<void> updateToken(String token, String buildNumber) async {
    try {
      await _authService.updateToken();
    } catch (e) {
      print(e);
    }
  }

  Future<bool> assignRole(User user, String role) async {
    try {
      await _authService.assignRole(user, role);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> setProfileImage(String url) async {
    try {
      await _authService.setProfileImage(url, fUser.uid);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> fetchSelectedCountry() {
    SharedPrefs prefs = SharedPrefs();
    prefs.getCountry().then((country) {
      if (country != null) {
        _selectedCountry = country;
        notifyListeners();
      } else {
        _selectedCountry = Country(
          name: 'Qatar',
          isoCode: 'qa',
          defaultLanguage: 'en',
          countryCode: 974,
          currency: 'QAR',
          regex: r"^3\d{7}$|^5\d{7}$|^6\d{7}$|^7\d{7}$",
          isActive: true,
        );
        notifyListeners();
      }
    });
  }

  Future<bool> login() async {
    isLoginBusy = true;
    notifyListeners();
    var email = emailController.text;

    try {
      var result = await _authService.login(
          email: email, password: passwordController.text);
      isLoginBusy = false;

      notifyListeners();
      return result;
    } on AuthException catch (e) {
      Get.snackbar('Error', e.message,
          colorText: Colors.white, backgroundColor: Colors.red[800]);

      isLoginBusy = false;
      notifyListeners();
      // SnackBarService.instance.showSnackBarError(e.message);
      return false;
      // throw AuthException(e.code, e.message);
    }
  }

  Future<bool> verifyOTP(String val) async {
    var otp = int.parse(val);
    try {
      return await _authService.verifyOTP(otp, _fUser.uid);
    } on AuthException catch (e) {
      throw AuthException(e.code, e.message);
    }
  }

  Future<User> getCurrentUser() async {
    FirebaseUser fireBaseUser = await _auth.currentUser();

    DocumentSnapshot snapshot =
        await _db.collection('users').document(fireBaseUser.uid).get();
    User _fUser = new User.fromSnapShot(snapshot);
    return _fUser;
  }

  Future<bool> register() async {
    isRegisterBusy = true;
    notifyListeners();
    var mobileNumber = '974${mobileNumberController.text}';

    var email = emailController.text;
    String password = passwordController.text;
    try {
      var result = await _authService.register(
          email: email,
          password: password,
          fullName: fullNameController.text,
          mobile: mobileNumber,
          countryISO: "qa");
      isRegisterBusy = false;
      notifyListeners();
      print('Success');
      Get.offAll(VerifyMobile());
      // NavigationService.instance.goBack();
      SnackBarService.instance.showSnackBarSuccess('Successfully Registered');

      return true;
    } on AuthException catch (e) {
      isRegisterBusy = false;
      notifyListeners();
      print(e.message);
      SnackBarService.instance.showSnackBarError(e.message);

      // throw AuthException(e.code, e.message);
    }

    print(
        'Full Name : ${fullNameController.text} ,Mobile: ${mobileNumberController.text}, Password: ${passwordController.text}');
  }

  Future<User> getUserByMobile() async {
    this.setBusy(true);
    var mobileNumber =
        '${_selectedCountry.countryCode}${mobileNumberController.text}';
    try {
      User user = await _authService.getUserByMobile(int.parse(mobileNumber));
      _fUser = user;
      notifyListeners();
      return user;
    } on AuthException catch (e) {
      throw AuthException(e.code, e.message);
    }
  }

  Future<bool> signIn(String email, String password) async {
    _status = Status.Authenticating;
    notifyListeners();

    AuthResult user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    DocumentSnapshot doc =
        await _db.collection('users').document(user.user.uid).get();

    if (doc.data.isNotEmpty) {
      _fUser = new User.fromSnapShot(doc);
      doc.reference.updateData(
          {'lastLogin': FieldValue.serverTimestamp(), 'token': _newToken});
      _status = Status.Authenticated;
      notifyListeners();
      return true;
    } else {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    _fUser = null;
    notifyListeners();
    // SnackBarService.instance.showSnackBarSuccess('Successfully Loggd out');

    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
      notifyListeners();
    } else {
      _user = firebaseUser;

      _authService.updateToken();
      print('token updated');

      _authService.getUserStream(firebaseUser.uid).listen((doc) {
        _fUser = User.fromSnapShot(doc);
        _status = Status.Authenticated;
        _defaultAddress = _fUser.defaultAddress;
        if (_selectedAddress == null && _defaultAddress != null) {
          _selectedAddress = _defaultAddress;
        }

        // print('User Updated');

        notifyListeners();
      });
      // DocumentSnapshot snapshot =
      //     await _db.collection('users').document(firebaseUser.uid).get();
      // _fUser = User.fromSnapShot(snapshot);
      // _status = Status.Authenticated;
      // notifyListeners();
    }
  }
}
