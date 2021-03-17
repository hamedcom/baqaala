import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:baqaala/src/models/credit_card.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class PayfortIntegration {
  String _gatewayHost = 'https://checkout.payfort.com/';
  String _gatewaySandboxHost = 'https://sbcheckout.payfort.com/';
  String _language = 'en';

  // Set Sandmox Mode false for Production
  bool _isSandboxMode = true;

  // Edit Valuese according to Payfort Account
  String _merchantIdentifier = "660e542b";
  String _accessCode = "PavNwhVGTE9abvW5UW5E";
  String _shaRequestPhrase = "\$2y\$10\$BYPhGDp5Y";
  String _shaResponsePhrase = "\$2y\$10\$FbeF16dw6";

  String _returnUrl =
      'https://us-central1-baqaala-new.cloudfunctions.net/successPayment';

  PayfortIntegration();

  String getGatewayApiUrl() {
    if (_isSandboxMode) {
      return 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi';
    } else {
      return 'https://paymentservices.payfort.com/FortAPI/paymentApi';
    }
  }

  String getTokenPageUrl() {
    if (_isSandboxMode) {
      return '${_gatewaySandboxHost}FortAPI/paymentPage';
    } else {
      return '${_gatewayHost}FortAPI/paymentPage';
    }
  }

  String calculateSignature(List<Map<String, dynamic>> attributes,
      [String signType = 'request']) {
    attributes.sort((a, b) {
      return a.keys.first.compareTo(b.keys.first);
    });

    String data = '';
    attributes.forEach((element) {
      data = data + element.keys.first + '=' + element.values.first.toString();
    });

    if (signType == 'request') {
      data = _shaRequestPhrase + data + _shaRequestPhrase;
    } else {
      data = _shaResponsePhrase + data + _shaResponsePhrase;
    }

    var bytes = utf8.encode(data);
    var val = sha256.convert(bytes);
    return val.toString();
  }

  int convertToFortAmount(double amount, String currencyCode) {
    int decimalPoints = getCurrencyDecimalPoint(currencyCode);
    var newAmount = 0.0;
    newAmount = double.tryParse(amount.toStringAsFixed(decimalPoints)) *
        pow(10, decimalPoints);
    return newAmount.toInt();
  }

  String convertFromFortAmount(int amount, String currencyCode) {
    int decimalPoints = getCurrencyDecimalPoint(currencyCode);
    double newAmount = amount / pow(10, decimalPoints);
    return newAmount.toStringAsFixed(decimalPoints);
  }

  int getCurrencyDecimalPoint(String currency) {
    int decimalPoint = 2;
    List<String> currencies = ['JOD', 'KWD', 'OMR', 'TND', 'BHD', 'LYD', 'IQD'];
    if (currencies.contains(currency)) {
      return 3;
    } else {
      return decimalPoint;
    }
  }

  String generateMerchantReference() {
    var rng = new Random();
    var code = rng.nextInt(89) + 100;
    var dateString = DateTime.now().millisecondsSinceEpoch;
    return '$dateString$code';
  }

  String generateTokenName() {
    // var bytes = utf8.encode(cardNumber.toString());
    // var val = sha256.convert(bytes);
    var uuid = Uuid();
    return uuid.v4();
  }

  String getPaymentOptionName(String po) {
    switch (po) {
      case 'creditcard':
        return 'Credit Card';
      case 'cc_merchantpage':
        return 'Credit Cards (Merchant Page)';
      case 'naps':
        return 'Debit Card (NAPS)';
      default:
        return '';
    }
  }

  Future<TokenResult> createToken({
    String cardNumber,
    String cardHolderName,
    String expiryDate,
    String securityCode,
  }) async {
    // String card = cardNumber;
    String card = cardNumber.replaceAll(' ', '');

    List<String> ex = expiryDate.split('/');
    String expiry = '${ex[1]}${ex[0]}';
    List<Map<String, dynamic>> attributes = [];

    String reference = generateMerchantReference();
    String tokenName = generateTokenName();

    attributes.add({'language': 'en'});
    attributes.add({'access_code': _accessCode});
    attributes.add({'merchant_identifier': _merchantIdentifier});
    attributes.add({'merchant_reference': reference});
    attributes.add({'service_command': 'TOKENIZATION'});
    // attributes.add({'token_name': tokenName});
    attributes.add({'return_url': _returnUrl});

    var response = await http.post(getTokenPageUrl(), headers: {
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
    }, body: {
      'service_command': 'TOKENIZATION',
      'language': 'en',
      'access_code': _accessCode,
      'merchant_identifier': _merchantIdentifier,
      'merchant_reference': reference,
      'expiry_date': expiry,
      'card_holder_name': cardHolderName,
      'card_number': card,
      'card_security_code': securityCode,
      'return_url': _returnUrl,
      // 'token_name': tokenName,
      'remember_me': 'YES',
      'signature': calculateSignature(attributes)
    });

    final int statusCode = response.statusCode;
    print(statusCode);
    print(response.body);
    RegExp exp = RegExp(r'returnUrlParams = {(.*?)};');
    var match = exp.stringMatch(response.body);
    if (match != null) {
      var returnText = match.replaceFirst(RegExp(r'returnUrlParams = {'), '{');
      returnText = returnText.replaceFirst(RegExp(r'};'), '}');
      // print(returnText);
      var obj = jsonDecode(returnText);
      print(obj);
      return TokenResult.fromJson(obj);
    } else {
      return null;
    }
  }

  Future<PurchaseResult> processPayment(
      {double amount,
      CreditCard cc,
      String paymentOption = 'creditcard', // creditcard , naps
      String creditTo, // order or wallet
      String orderId,
      String userId,
      String customerIP = '192.168.1.1',
      String orderDescription,
      String currencyCode = 'QAR',
      String userEmail}) async {
    List<Map<String, dynamic>> attributes = [];

    int amt = convertToFortAmount(amount, currencyCode);

    String reference = generateMerchantReference();

    attributes.add({'language': _language});
    attributes.add({'access_code': _accessCode});
    attributes.add({'merchant_identifier': _merchantIdentifier});
    attributes.add({'merchant_reference': reference});
    attributes.add({'command': 'PURCHASE'});
    // attributes.add({'card_security_code': cc.securityCode ?? 123});
    attributes.add({'amount': amt});
    if (paymentOption == 'NAPS') attributes.add({'payment_option': 'NAPS'});
    attributes.add({'currency': currencyCode});
    attributes.add({'customer_email': userEmail});
    attributes.add({'customer_ip': customerIP});
    attributes.add({'token_name': cc.tokenName});
    attributes.add({'order_description': orderDescription});
    attributes.add({'merchant_extra': userId});
    attributes.add({'merchant_extra2': orderId});
    attributes.add({'merchant_extra1': creditTo});
    attributes.add({'remember_me': 'YES'});
    attributes.add({'return_url': _returnUrl});

    // print(attributes);

    var response = await http.post(getGatewayApiUrl(),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode({
          'language': _language,
          'access_code': _accessCode,
          'merchant_identifier': _merchantIdentifier,
          'merchant_reference': reference,
          'command': 'PURCHASE',
          // 'card_security_code': cc.securityCode ?? 123,
          'amount': amt,
          if (paymentOption == 'NAPS') 'payment_option': 'NAPS',
          'currency': currencyCode,
          'customer_email': userEmail,
          'customer_ip': customerIP,
          'token_name': cc.tokenName,
          'order_description': orderDescription,
          'merchant_extra': userId,
          'merchant_extra2': orderId,
          'merchant_extra1': creditTo,
          'remember_me': 'YES',
          'return_url': _returnUrl,
          'signature': calculateSignature(attributes)
        }));

    final int statusCode = response.statusCode;
    print(statusCode);
    var obj = jsonDecode(response.body);
    print(obj);
    PurchaseResult result = PurchaseResult.fromJson(obj);
    return result;
  }
}

class TokenResult {
  String responseCode;
  String cardNumber;
  String cardHolderName;
  String expiryDate;
  String responseMessage;
  String merchantReference;
  String tokenName;
  String returnUrl;
  String currency;
  String rememberMe;
  String status;
  String cardBin;

  TokenResult({
    this.responseCode,
    this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.responseMessage,
    this.merchantReference,
    this.tokenName,
    this.returnUrl,
    this.currency,
    this.rememberMe,
    this.status,
    this.cardBin,
  });

  factory TokenResult.fromJson(Map<String, dynamic> data) {
    return TokenResult(
        responseCode: data['response_code'],
        cardNumber: data['card_number'],
        cardHolderName: data['card_holder_name'],
        expiryDate: data['expiry_date'],
        responseMessage: data['response_message'],
        merchantReference: data['merchant_reference'],
        tokenName: data['token_name'],
        returnUrl: data['return_url'],
        currency: data['currency'],
        rememberMe: data['remember_me'],
        cardBin: data['card_bin'],
        status: data['status']);
  }
}

class PurchaseResult {
  String responseCode;
  String cardNumber;
  String cardHolderName;
  String expiryDate;
  String responseMessage;
  String merchantReference;
  String fortId;
  String secureUrl;
  String currency;
  String customerEmail;
  String status;
  String customerIP;

  PurchaseResult({
    this.responseCode,
    this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.responseMessage,
    this.merchantReference,
    this.fortId,
    this.secureUrl,
    this.currency,
    this.customerEmail,
    this.status,
    this.customerIP,
  });

  factory PurchaseResult.fromJson(Map<String, dynamic> data) {
    return PurchaseResult(
        responseCode: data['response_code'],
        cardNumber: data['card_number'],
        cardHolderName: data['card_holder_name'],
        expiryDate: data['expiry_date'],
        responseMessage: data['response_message'],
        merchantReference: data['merchant_reference'],
        fortId: data['fort_id'],
        secureUrl: data['3ds_url'],
        currency: data['currency'],
        customerEmail: data['customer_email'],
        customerIP: data['customer_ip'],
        status: data['status']);
  }
}
