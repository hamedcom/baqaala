import 'package:cloud_firestore/cloud_firestore.dart';

class Country {
  String id;
  String name;
  String isoCode;
  int countryCode;
  String currency;
  String defaultLanguage;
  String regex;
  bool isActive;

  Country({
    this.name,
    this.isoCode,
    this.countryCode,
    this.currency,
    this.defaultLanguage,
    this.regex,
    this.id,
    this.isActive,
  });

  factory Country.fromFirestore(DocumentSnapshot doc) {
    return Country(
        id: doc.documentID,
        name: doc['name'],
        isoCode: doc['isoCode'],
        countryCode: doc['countryCode'],
        currency: doc['currency'],
        defaultLanguage: doc['defaultLanguage'] ?? 'en',
        regex: doc['regex'] ?? r"^[2-9]*$", // Default for all numbers
        isActive: doc['isActive']);
  }

  Country.fromJson(Map<String, dynamic> doc) {
    id = doc['id'];
    name = doc['name'];
    isoCode = doc['isoCode'];
    defaultLanguage = doc['defaultLanguage'] ?? 'en';
    countryCode = doc['countryCode'];
    currency = doc['currency'];
    regex = doc['regex'] ?? r"^[2-9]*$";
    isActive = doc['isActive'] ?? true;
  }

  Map<String, dynamic> toJSON() => {
        'name': name,
        'isoCode': isoCode,
        'defaultLanguage': defaultLanguage,
        'countryCode': countryCode,
        'currency': currency,
        'regex': regex,
        'isActive': isActive,
      };
}

List<Country> avilableCountries = [
  Country(
    name: 'Qatar',
    isoCode: 'qa',
    defaultLanguage: 'en',
    countryCode: 974,
    currency: 'QAR',
    regex: r"^3\d{7}$|^5\d{7}$|^6\d{7}$|^7\d{7}$",
    isActive: true,
  ),
  Country(
    name: 'Oman',
    isoCode: 'om',
    defaultLanguage: 'en',
    countryCode: 968,
    currency: 'OMR',
    regex: r"^7\d{7}$|^9\d{7}$",
    isActive: false,
  ),
  Country(
    name: 'Bahrain',
    isoCode: 'bh',
    defaultLanguage: 'en',
    countryCode: 973,
    currency: 'BHD',
    regex: r"^3\d{7}$|^6\d{7}$",
    isActive: false,
  ),
  Country(
    name: 'Kuwait',
    isoCode: 'kw',
    defaultLanguage: 'en',
    countryCode: 965,
    currency: 'KWD',
    regex: r"^5\d{7}$|^6\d{7}$|^9\d{7}$",
    isActive: false,
  ),
  Country(
    name: 'Saudi Arabia',
    isoCode: 'sa',
    defaultLanguage: 'en',
    countryCode: 966,
    currency: 'SAR',
    regex: r"^5\d{8}$",
    isActive: false,
  ),
  Country(
    name: 'United Arab Emirates',
    isoCode: 'ae',
    defaultLanguage: 'en',
    countryCode: 971,
    currency: 'AED',
    regex: r"^5\d{8}$",
    isActive: false,
  ),
];
