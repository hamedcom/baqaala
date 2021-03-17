import 'package:cloud_firestore/cloud_firestore.dart';

class CreditCard {
  String id;
  String number; // 305645******0989
  bool isEnable;
  String cardBin;
  String expiryDate;
  String cardHolderName;
  String tokenName;
  String currency;
  String reference;
  String securityCode; //cvv
  String fullNumber;
  String type; // visa , mastercard

  CreditCard({
    this.id,
    this.number,
    this.fullNumber,
    this.securityCode,
    this.isEnable,
    this.expiryDate,
    this.cardBin,
    this.cardHolderName,
    this.tokenName,
    this.currency,
    this.reference,
    this.type,
  });

  factory CreditCard.fromJson(Map<String, dynamic> data) {
    return CreditCard(
      id: data['id'],
      number: data['number'],
      securityCode: data['securityCode'],
      fullNumber: data['fullNumber'],
      isEnable: data['isEnable'] ?? true,
      cardBin: data['cardBin'],
      expiryDate: data['expiryDate'],
      cardHolderName: data['cardHolderName'],
      tokenName: data['tokenName'],
      currency: data['currency'],
      type: data['type'],
      reference: data['reference'],
    );
  }

  factory CreditCard.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data;
    return CreditCard(
        id: doc.documentID,
        number: data['number'],
        isEnable: data['isEnable'] ?? true,
        cardBin: data['cardBin'],
        securityCode: data['securityCode'],
        fullNumber: data['fullNumber'],
        expiryDate: data['expiryDate'],
        cardHolderName: data['cardHolderName'],
        tokenName: data['tokenName'],
        currency: data['currency'],
        type: data['type'],
        reference: data['reference']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'isEnable': isEnable,
        'cardBin': cardBin,
        'expiryDate': expiryDate,
        'cardHolderName': cardHolderName,
        'tokenName': tokenName,
        'currency': currency,
        'type': type,
        'reference': reference,
        'securityCode': securityCode,
        'fullNumber': fullNumber,
      };
}
