import 'package:baqaala/src/models/credit_card.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/services/payfort_service.dart';
import 'package:baqaala/src/widgets/user/payfort_redirect.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class TopUp extends StatefulWidget {
  TopUp({Key key}) : super(key: key);

  @override
  _TopUpState createState() => _TopUpState();
}

class _TopUpState extends State<TopUp> {
  bool _isBusy = false;
  CreditCard _selectedCard;
  double _amount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'Top Up',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: ListView(
          children: [
            amountWidget(),
            SizedBox(
              height: 10,
            ),
            cardList(),
            ListTile(
              title: Text(
                ' +  Add new card',
                style: TextStyle(color: Colors.green[800], fontSize: 18),
              ),
              onTap: () {
                // Get.to(AddCard());
                Get.to(PayfortRedirect(
                  amount: _amount > 0 ? _amount : 50,
                  cardType: 'DEBIT',
                  // cardType: 'CREDIT',
                ));
              },
            ),
            Container(
              height: 55,
              width: double.infinity,
              margin: EdgeInsets.all(15),
              child: RaisedButton(
                onPressed: (_isBusy || _selectedCard == null || _amount <= 0)
                    ? null
                    : () async {
                        setState(() {
                          _isBusy = true;
                        });
                        await PayfortService.instance
                            .topUp(_amount, _selectedCard);

                        Future.delayed(Duration(seconds: 5), () {
                          setState(() {
                            _isBusy = false;
                          });
                        });
                      },
                child: _isBusy
                    ? CircularProgressIndicator()
                    : Text('Top Up', style: TextStyle(fontSize: 20)),
                color: Colors.blue,
                textColor: Colors.white,
                elevation: 5,
              ),
            )
          ],
        ));
  }

  Widget cardList() {
    final AuthModel auth = Provider.of<AuthModel>(context);
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .document(auth.userId)
          .collection('cards')
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:

          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            if (snapshot.hasData) {
              if (snapshot.data.documents.length != 0)
                return Column(children: cards(snapshot, context));
              else
                return Center(
                  child: Text(
                    'No Cards Found',
                    style: TextStyle(fontSize: 18),
                  ),
                );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            return null;
        }
      },
    );
  }

  List<Widget> cards(AsyncSnapshot snapshot, BuildContext context) {
    return snapshot.data.documents.map<Widget>((document) {
      CreditCard cc = CreditCard.fromSnapShot(document);
      var expiry =
          '${cc.expiryDate.substring(2, 4)}/${cc.expiryDate.substring(0, 2)}';
      return Card(
        elevation: 2,
        child: ListTile(
          title: Text(
            cc.number ?? '',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Expiry : $expiry'),
          trailing: _selectedCard != null
              ? _selectedCard.tokenName == cc.tokenName
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.green[800],
                    )
                  : SizedBox()
              : SizedBox(),
          onTap: () {
            _selectedCard = cc;
            setState(() {});
            // Get.back(result: cc);
          },
        ),
      );
      ;
    }).toList();
  }

  Widget amountWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            amountCircle(50),
            amountCircle(100),
            amountCircle(250),
            amountCircle(500)
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget amountCircle(double amount) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _amount = amount;
        });
      },
      child: Container(
        margin: EdgeInsets.all(5),
        height: 80,
        width: 80,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: amount == _amount ? Colors.green[800] : Colors.grey[500]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              amount.toString(),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'QAR',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
