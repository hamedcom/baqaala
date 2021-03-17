import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:baqaala/src/common/config/payfort.dart';
import 'package:baqaala/src/models/credit_card.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/services/payfort_integration.dart';
import 'package:baqaala/src/services/payfort_service.dart';
import 'package:baqaala/src/widgets/user/payfort_token_page.dart';
import 'package:baqaala/src/widgets/user/payment_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/route_manager.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddCard extends StatefulWidget {
  final double amount;
  final String creditTo;
  AddCard({Key key, this.amount, this.creditTo}) : super(key: key);

  @override
  _AddCardState createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> with AfterLayoutMixin<AddCard> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool isValid = false;
  bool isBusy = false;
  double amount = 0;
  bool isAmountEnable = true;
  String creditTo;
  TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('Add Card Inititated');
    _amountController.addListener(() {
      var tmpAmount = double.tryParse(_amountController.text);

      amount = tmpAmount ?? 0;
      setState(() {});
    });
    if (widget.amount != null) {
      isAmountEnable = false;
      amount = widget.amount;
      _amountController.text = amount?.toString();
      setState(() {});
    }
    // purchase();
    // createToken();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) async {}

  @override
  Widget build(BuildContext context) {
    final AuthModel auth = Provider.of<AuthModel>(context);

    var maskFormatter = new MaskTextInputFormatter(
        mask: '##/##', filter: {"#": RegExp(r'[0-9]')});

    var cardFormatter = new MaskTextInputFormatter(
        mask: '#### #### #### ####', filter: {"#": RegExp(r'[0-9]')});
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Add new card',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: ListView(
        children: [
          CreditCardWidget(
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cardHolderName: cardHolderName,
            cvvCode: cvvCode,
            showBackView: isCvvFocused,
            cardBgColor: Colors.lightGreen[900],
          ),
          CreditCardForm(
            onCreditCardModelChange: onCreditCardModelChange,
            cardHolderName: cardHolderName,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
            child: TextFormField(
              controller: _amountController,
              enabled: isAmountEnable,
              style: TextStyle(
                color: Colors.black,
              ),
              decoration: InputDecoration(
                suffixText: 'QAR',
                border: OutlineInputBorder(),
                labelText: 'Enter Amount',
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            height: 90,
            child: FlatButton(
              color: Colors.orange[300],
              disabledColor: Colors.grey[200],
              child: Text('Continue'),
              onPressed: (isValid && amount > 0 && !isBusy)
                  ? () async {
                      PayfortIntegration payfort = PayfortIntegration();
                      CreditCard cc = CreditCard(
                        cardHolderName: cardHolderName,
                        securityCode: cvvCode,
                        expiryDate: expiryDate,
                        number: cardNumber,
                        currency: 'QAR',
                      );
                      setState(() {
                        isBusy = true;
                      });
                      try {
                        CreditCard cc = CreditCard(
                          cardHolderName: cardHolderName,
                          number: cardNumber,
                          securityCode: cvvCode,
                          expiryDate: expiryDate,
                        );

                        // var res = await Get.to(PayfortTokenPage(
                        //   cc: cc,
                        // ));

                        // print(res);

                        var result = await payfort.createToken(
                          cardNumber: cardNumber,
                          cardHolderName: cardHolderName,
                          securityCode: cvvCode,
                          expiryDate: expiryDate,
                        );

                        print(result.responseMessage);
                        print(result.tokenName);
                        print(amount);
                        if (result.responseMessage == 'Success') {
                          cc.tokenName = result.tokenName;
                          // cc.tokenName = '7546e5d4a24442149acf736f4d5c88ed';
                          var response = await payfort.processPayment(
                              cc: cc,
                              amount: amount,
                              // paymentOption: 'NAPS',
                              orderDescription: 'TopUp Wallet',
                              userId: auth.fUser.uid,
                              orderId: '1234',
                              userEmail: auth.fUser.email,
                              creditTo: 'wallet');

                          print(response);
                          if (response.secureUrl != null) {
                            var res = await Get.to(PaymentView(
                              purchaseResult: response,
                            ));
                            if (res != null && res == 'Success') {
                              Get.back();
                              Get.rawSnackbar(
                                  snackStyle: SnackStyle.FLOATING,
                                  snackPosition: SnackPosition.TOP,
                                  margin: EdgeInsets.all(15),
                                  borderRadius: 15,
                                  backgroundColor: Colors.green[800],
                                  title: 'Success',
                                  message: 'Card Added Successfully');
                            }
                            print(res);
                          }
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
                        // var result = await PayfortService.instance.saveCard(
                        //   cardHolderName: cardHolderName,
                        //   cardNumber: cardNumber,
                        //   securityCode: cvvCode,
                        //   expiryDate: expiryDate,
                        // );

                        // if (result != null) {
                        //   Get.back(result: result);
                        //   Get.rawSnackbar(
                        //       snackStyle: SnackStyle.FLOATING,
                        //       snackPosition: SnackPosition.TOP,
                        //       margin: EdgeInsets.all(15),
                        //       borderRadius: 15,
                        //       backgroundColor: Colors.green[800],
                        //       title: 'Success',
                        //       message: 'Card Added Successfully');
                        // }
                      } catch (e) {
                        Get.rawSnackbar(
                            snackStyle: SnackStyle.FLOATING,
                            snackPosition: SnackPosition.TOP,
                            margin: EdgeInsets.all(15),
                            borderRadius: 15,
                            backgroundColor: Colors.red[800],
                            title: 'Error',
                            message: e.toString());
                      }
                      setState(() {
                        isBusy = false;
                      });
                    }
                  : null,
            ),
          )
        ],
        //ListView(
        //   padding: EdgeInsets.all(10),
        //   children: [
        //     TextField(
        //       keyboardType: TextInputType.number,
        //       inputFormatters: [cardFormatter],
        //       decoration: InputDecoration(labelText: 'Card Number'),
        //     ),
        //     Container(
        //       width: Get.width,
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           SizedBox(
        //             width: Get.width * 0.35,
        //             child: TextField(
        //               keyboardType: TextInputType.number,
        //               inputFormatters: [maskFormatter],
        //               decoration: InputDecoration(
        //                   labelText: 'Expiray date', hintText: 'MM/YY'),
        //               onChanged: (val) {
        //                 print(val);
        //               },
        //             ),
        //           ),
        //           SizedBox(
        //             width: Get.width * 0.35,
        //             child: TextField(
        //               keyboardType: TextInputType.number,
        //               decoration: InputDecoration(labelText: 'Security Code'),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //     Spacer(),
        //     SizedBox(
        //       height: 50,
        //     ),
        //     SizedBox(
        //       height: 50,
        //       child: FlatButton(
        //         color: Colors.orange[300],
        //         child: Text('Save Card'),
        //         onPressed: () {},
        //       ),
        //     )
        //   ],
        // )
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;

      if (cardNumber != null && expiryDate != null && cvvCode != null) {
        if (cardNumber.length >= 16 &&
            expiryDate.length >= 4 &&
            cvvCode.length >= 3 &&
            cardHolderName.length > 2) {
          isValid = true;
        }
      }
    });
  }
}
