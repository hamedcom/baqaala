import 'package:baqaala/src/models/credit_card.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/widgets/user/add_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';

class ManageCards extends StatefulWidget {
  final bool isReturnCard;
  ManageCards({Key key, this.isReturnCard}) : super(key: key);

  @override
  _ManageCardsState createState() => _ManageCardsState();
}

class _ManageCardsState extends State<ManageCards> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'Manage Cards',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: ListView(
          children: [
            SizedBox(
              height: 10,
            ),
            cardList(),
            Divider(),
            ListTile(
              title: Text(
                ' +  Add new card',
                style: TextStyle(color: Colors.green[800], fontSize: 18),
              ),
              onTap: () {
                Get.to(AddCard(
                  amount: 123.43,
                ));
              },
            ),
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
          onTap: () {
            // Get.back(result: cc);
          },
        ),
      );
      ;
    }).toList();
  }
}
