import 'dart:convert';

import 'package:crypto/crypto.dart';

// Payfort Configuaration

abstract class Payfort {
  static String accessCode = "PavNwhVGTE9abvW5UW5E";
  static String merchantIdentifier = "660e542b";
  static String shaType = "SHA-256";
  static String shaRequestPhrase = "\$2y\$10\$BYPhGDp5Y";
  static String shaResponsePhrase = "\$2y\$10\$FbeF16dw6";

  static String merchantPage2Url =
      "https://sbcheckout.PayFort.com/FortAPI/paymentPage";

  static String baseUrl = "";
  static String versionPrefix = "/v";
  static String mAPIVersion = "2";

  static String getSignature(List<Map<String, dynamic>> attributes) {
    attributes.sort((a, b) {
      return a.keys.first.compareTo(b.keys.first);
    });
    // print(attributes);
    String data = '';
    attributes.forEach((element) {
      data = data + element.keys.first + '=' + element.values.first.toString();
    });

    data = shaRequestPhrase + data + shaRequestPhrase;
    // print(data);
    var bytes = utf8.encode(data);
    var val = sha256.convert(bytes);
    return val.toString();
  }

  static const SUCCESS = 200;
  static const SERVER_ERROR = 500;
  static const CONFIG_ERROR = 100;
  static const CONNECTION_ERROR = -2;
  static const PAYMENT_CANCELED_ERROR = -1;

  static const KEY_CARD = "card";
  static const KEY_TOKEN = "token";
}
