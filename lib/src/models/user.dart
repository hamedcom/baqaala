import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String name;
  String email;
  String storeId;
  String displayPicture;
  int mobile;
  double rating;
  String status; // active,banned
  bool isMobileVerified;
  bool isEmailVerified;
  String language;
  Map<dynamic, dynamic> roles;
  List<String> tokens; // all loggedin devices tokens
  DateTime joinedAt;
  DateTime lastLogin;
  DateTime lastSeen;
  DateTime lastOrdered; // we can send OTP if last ordered more than 15 days..
  String buildNumber; // for check recent version for update
  int otp;
  String emailVerificationToken;
  int otpCount;
  String promoCode; // if any Promo Codes
  Address defaultAddress;
  int totalOrders;
  double totalOrderValue;
  int totalCancellations;

  User({
    this.uid,
    this.name,
    this.email,
    this.storeId,
    this.displayPicture,
    this.mobile,
    this.status,
    this.rating,
    this.isEmailVerified,
    this.isMobileVerified,
    this.language,
    this.roles,
    this.tokens,
    this.joinedAt,
    this.lastLogin,
    this.lastSeen,
    this.lastOrdered,
    this.buildNumber,
    this.otp,
    this.emailVerificationToken,
    this.otpCount,
    this.promoCode,
    this.defaultAddress,
    this.totalOrders,
    this.totalOrderValue,
    this.totalCancellations,
  });

  factory User.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data;
    return User(
      uid: doc.documentID,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      displayPicture: data['displayPicture'] ?? null,
      storeId: data['storeId'],
      joinedAt: data['joinedAt']?.toDate() ?? null,
      lastLogin: data['lastLogin']?.toDate() ?? null,
      lastSeen: data['lastSeen']?.toDate() ?? null,
      lastOrdered: data['lastOrdered']?.toDate() ?? null,
      tokens: data['tokens'] != null ? List<String>.from(data['tokens']) : [],
      mobile: data['mobile'],
      status: data['status'],
      rating: data['rating'],
      isEmailVerified: data['isEmailVerified'],
      isMobileVerified: data['isMobileVerified'],
      language: data['language'],
      buildNumber: data['buildNumber'],
      otp: data['otp'],
      emailVerificationToken: data['emailVerificationToken'],
      promoCode: data['promoCode'],
      defaultAddress: data['defaultAddress'] != null
          ? Address.fromJson(Map<String, dynamic>.from(data['defaultAddress']))
          : null,
      totalOrders: data['totalOrders'],
      otpCount: data['otpCount'],
      roles: data['roles'] != null ? Map.from(data['roles']) : {},
      totalOrderValue: data['totalOrderValue'],
      totalCancellations: data['totalCancellations'],
    );
  }

  User.fromJson(Map<String, dynamic> data) {
    uid = data['uid'];
    name = data['name'] ?? '';
    email = data['email'] ?? '';
    displayPicture = data['displayPicture'] ?? null;
    storeId = data['storeId'];
    joinedAt = data['joinedAt']?.toDate() ?? null;
    lastLogin = data['lastLogin']?.toDate() ?? null;
    lastSeen = data['lastSeen']?.toDate() ?? null;
    lastOrdered = data['lastOrdered']?.toDate() ?? null;
    tokens = data['tokens'] != null ? List<String>.from(data['tokens']) : [];
    mobile = data['mobile'];
    status = data['status'];
    rating = data['rating'];
    isEmailVerified = data['isEmailVerified'];
    isMobileVerified = data['isMobileVerified'];
    language = data['language'];
    buildNumber = data['buildNumber'];
    otp = data['otp'];
    emailVerificationToken = data['emailVerificationToken'];
    promoCode = data['promoCode'];
    defaultAddress = data['defaultAddress'] != null
        ? Address.fromJson(Map<String, dynamic>.from(data['defaultAddress']))
        : null;
    totalOrders = data['totalOrders'];
    otpCount = data['otpCount'];
    roles = data['roles'] != null ? Map.from(data['roles']) : {};
    totalOrderValue = data['totalOrderValue'];
    totalCancellations = data['totalCancellations'];
  }

  Map<String, dynamic> toJSON() => {
        'uid': uid,
        'name': name,
        'email': email,
        'storeId': storeId,
        'displayPicture': displayPicture,
        'mobile': mobile,
        'status': status,
        'rating': rating,
        'isEmailVerified': isMobileVerified,
        'isMobileVerified': isMobileVerified,
        'language': language,
        'roles': roles,
        'tokens': tokens,
        'joinedAt': joinedAt,
        'lastLogin': lastLogin,
        'lastSeen': lastSeen,
        'lastOrdered': lastOrdered,
        'buildNumber': buildNumber,
        'otp': otp,
        'emailVerificationToken': emailVerificationToken,
        'otpCount': otpCount,
        'promoCode': promoCode,
        'defaultAddress':
            defaultAddress != null ? defaultAddress.toJSON() : null,
        'totalOrders': totalOrders,
        'totalOrderValue': totalOrderValue,
        'totalCancellations': totalCancellations
      };
}

class Role {
  final String title;
  final String value;

  Role({this.title, this.value});
}

List<Role> userRoles = [
  Role(title: 'Administrator', value: 'admin'),
  Role(title: 'Manager', value: 'manager'),
  Role(title: 'Store Manager', value: 'store_manager'),
  Role(title: 'Picker', value: 'picker'),
  Role(title: 'Driver', value: 'driver'),
  Role(title: 'Quality Controller', value: 'qc'),
  Role(title: 'Investor', value: 'investor'),
];

class Address {
  String area; // disaply full address
  String streetName;
  String streetNumber;
  String zone;
  String building;
  String aptNumber;
  double latitude;
  double longitude;
  String landMark;
  String receivedBy; // receiver name
  String label; // office or home
  int mobileNumber; // receiver number
  bool isMobileVerified; // receiver mobile verified
  String note; // if any special note

  Address({
    this.area,
    this.streetName,
    this.streetNumber,
    this.zone,
    this.building,
    this.aptNumber,
    this.latitude,
    this.longitude,
    this.landMark,
    this.receivedBy,
    this.label,
    this.mobileNumber,
    this.isMobileVerified,
    this.note,
  });

  factory Address.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data;
    return Address(
      area: data['area'],
      streetNumber: data['streetNumber'],
      streetName: data['streetName'],
      zone: data['zone'],
      building: data['building'],
      aptNumber: data['aptNumber'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      landMark: data['landMark'],
      receivedBy: data['receivedBy'],
      label: data['label'],
      mobileNumber: data['mobileNumber'],
      isMobileVerified: data['isMobileVerified'],
      note: data['note'],
    );
  }

  Address.fromJson(Map<String, dynamic> data) {
    area = data['area'];
    streetNumber = data['streetNumber'];
    streetName = data['streetName'];
    zone = data['zone'];
    building = data['building'];
    aptNumber = data['aptNumber'];
    latitude = data['latitude'];
    longitude = data['longitude'];
    landMark = data['landMark'];
    receivedBy = data['receivedBy'];
    label = data['label'];
    mobileNumber = data['mobileNumber'];
    isMobileVerified = data['isMobileVerified'];
    note = data['note'];
  }

  Map<String, dynamic> toJSON() => {
        'area': area,
        'streetName': streetName,
        'streetNumber': streetNumber,
        'zone': zone,
        'building': building,
        'aptNumber': aptNumber,
        'latitude': latitude,
        'longitude': longitude,
        'landMark': landMark,
        'receivedBy': receivedBy,
        'label': label,
        'mobileNumber': mobileNumber,
        'isMobileVerified': isMobileVerified,
        'note': note,
      };
}

class ShortUser {
  String uid;
  String name;
  String mobile;
  String displayPicture;

  ShortUser({
    this.uid,
    this.name,
    this.mobile,
    this.displayPicture,
  });

  ShortUser.fromJson(Map<String, dynamic> data) {
    uid = data['uid'];
    name = data['name'];
    mobile = data['mobile'];
    displayPicture = data['displayPicture'];
  }

  Map<String, dynamic> toJSON() => {
        'uid': uid,
        'name': name,
        'mobile': mobile,
        'displayPicture': displayPicture,
      };
}
