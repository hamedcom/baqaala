import 'dart:convert';
import 'dart:io';

import 'package:baqaala/src/common/config/payfort.dart';
import 'package:baqaala/src/models/credit_card.dart';
import 'package:baqaala/src/widgets/user/payment_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:slugify2/slugify.dart';
import 'package:http/http.dart' as http;

class PayfortService {
  Firestore _db = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;

  static PayfortService instance = PayfortService();

  Future<Map<String, dynamic>> getToken() {}

  Future<bool> topUp(double amount, CreditCard cc) {
    print(amount);
    print(cc.number);
    processPayment(amount, cc);
  }

  Future<bool> processPayment(double amount, CreditCard cc,
      {String command = 'PURCHASE'}) async {
    List<Map<String, dynamic>> attributes = [];

    int amt = (amount * 100).toInt();

    String reference = DateTime.now().millisecondsSinceEpoch.toString();

    attributes.add({'language': 'en'});
    attributes.add({'access_code': Payfort.accessCode});
    attributes.add({'merchant_identifier': Payfort.merchantIdentifier});
    attributes.add({'merchant_reference': reference});
    attributes.add({'command': command});
    attributes.add({'card_security_code': cc.securityCode ?? 123});
    attributes.add({'amount': amt});
    attributes.add({'currency': 'QAR'});
    attributes.add({'customer_email': 'vivek@gmail.com'});
    attributes.add({'customer_ip': '192.168.1.1'});
    attributes.add({'token_name': cc.tokenName});

    // print(Payfort.getSignature(attributes));
    String payfortUrl =
        'https://sbpaymentservices.payfort.com/FortAPI/paymentApi';

    var response = await http.post(payfortUrl,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode({
          'command': command, // AUTHORIZATION, PURCHASE
          'language': 'en',

          'access_code': Payfort.accessCode,
          'merchant_identifier': Payfort.merchantIdentifier,
          'amount': amt,
          'merchant_reference': reference,
          'customer_email': 'vivek@gmail.com',
          'customer_ip': '192.168.1.1',
          'currency': 'QAR',
          'token_name': cc.tokenName,
          'card_security_code': cc.securityCode ?? 123,
          'signature': Payfort.getSignature(attributes)
        }));
    // .then((http.Response response) {
    final int statusCode = response.statusCode;
    print(statusCode);
    var obj = jsonDecode(response.body);
    print(obj);
    PurchaseResult result = PurchaseResult.fromJson(obj);
    print(result.responseCode);
    if (result.responseCode == '20064') {
      var res = await Get.to(PaymentView(
          // purchaseResult: result,
          ));
      if (res == 'Success') {
        await _db
            .collection('users')
            .document(_user.uid)
            .collection('wallet')
            .document('wallet')
            .setData({
          'balance': FieldValue.increment(amount),
          'lastUpdated': FieldValue.serverTimestamp()
        }, merge: true);
        Get.back();
        Get.rawSnackbar(
            snackStyle: SnackStyle.FLOATING,
            snackPosition: SnackPosition.TOP,
            margin: EdgeInsets.all(15),
            borderRadius: 15,
            backgroundColor: Colors.green[800],
            title: 'Success',
            message: '$amount QAR Added to your wallet!');
      }
      print(res);
    } else {
      Get.rawSnackbar(
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(15),
          borderRadius: 15,
          backgroundColor: Colors.red[800],
          title: 'Error',
          message: result.responseMessage);
    }
    // });
  }

  Future<CreditCard> saveCard(
      {String cardNumber,
      String cardHolderName,
      String expiryDate,
      String securityCode}) async {
    String card = cardNumber.replaceAll(' ', '');
    List<String> ex = expiryDate.split('/');
    String expiry = '${ex[1]}${ex[0]}';
    var tokenName = Slugify(delimiter: '').slugify(
        '${card.substring(0, 4)}$expiry${card.substring(card.length - 4, card.length)}');

    var result = await createToken(
      cardHolderName: cardHolderName,
      cardNumber: card,
      expiryDate: expiry,
      securityCode: securityCode,
      tokenName: tokenName,
    );

    if (result.responseMessage == 'Success') {
      print('$card, $cardHolderName, $expiry, $securityCode, $tokenName');
      print(result.tokenName);

      CreditCard newCard = CreditCard(
        cardBin: result.cardBin,
        number: result.cardNumber,
        fullNumber: cardNumber,
        securityCode: securityCode,
        cardHolderName: result.cardHolderName,
        isEnable: true,
        expiryDate: result.expiryDate,
        tokenName: result.tokenName,
        currency: result.currency,
        reference: result.merchantReference,
      );

      if (_user == null) {
        _user = await _auth.currentUser();
      }

      // try {
      //   var doc = await _db
      //       .collection('users')
      //       .document(_user.uid)
      //       .collection('cards')
      //       .document(tokenName)
      //       .setData(newCard.toJson(), merge: true);
      // } catch (e) {
      //   throw e;
      // }

      // var res = await processPayment(1, newCard, command: 'AUTHORIZATION');

      return newCard;
    } else {
      throw (result.responseMessage);
    }
  }

  Future<TokenResult> createToken({
    String cardNumber,
    String cardHolderName,
    String expiryDate,
    String securityCode,
    String tokenName,
  }) async {
    String reference = DateTime.now().millisecondsSinceEpoch.toString();
    List<Map<String, dynamic>> attributes = [];

    attributes.add({'language': 'en'});
    attributes.add({'access_code': Payfort.accessCode});
    attributes.add({'merchant_identifier': Payfort.merchantIdentifier});
    attributes.add({'merchant_reference': reference});
    attributes.add({'service_command': 'TOKENIZATION'});
    attributes.add({'currency': 'QAR'});
    attributes.add({'return_url': 'http://baqaala.com'});
    // print(Payfort.getSignature(attributes));
    String payfortUrl = 'https://sbcheckout.PayFort.com/FortAPI/paymentPage';

    var response = await http.post(payfortUrl, headers: {
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
    }, body: {
      'service_command': 'TOKENIZATION',
      'language': 'en',
      'access_code': Payfort.accessCode,
      'merchant_identifier': Payfort.merchantIdentifier,
      'merchant_reference': reference,
      'expiry_date': expiryDate,
      'card_holder_name': cardHolderName,
      'card_number': cardNumber,
      'card_security_code': securityCode,
      'currency': 'QAR',
      'return_url': 'http://baqaala.com',
      'remember_me': 'YES',
      'signature': Payfort.getSignature(attributes)
    }); //.then((http.Response response) {
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
    // });
  }

  PayfortService() {
    if (_user == null) {
      _auth.currentUser().then((value) {
        _user = value;
      });
    }
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
