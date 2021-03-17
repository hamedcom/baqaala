import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/providers/wallet_provider.dart';
import 'package:baqaala/src/widgets/user/manage_cards.dart';
import 'package:baqaala/src/widgets/user/topup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class Wallet extends StatefulWidget {
  Wallet({Key key}) : super(key: key);

  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    final WalletProvider wallet = Provider.of<WalletProvider>(context);
    final AuthModel auth = Provider.of<AuthModel>(context);

    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   brightness: Brightness.light,
        //   iconTheme: IconThemeData(color: Colors.black),
        // ),
        body: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          //   iconTheme: IconThemeData(color: Colors.black),
          iconTheme: IconThemeData(color: Colors.black),
          brightness: Brightness.light,

          // title: Text('SliverAppBar'),
          backgroundColor: Colors.blueGrey[100],
          expandedHeight: ResponsiveFlutter.of(context).scale(280),
          pinned: true,
          stretch: true,
          snap: true,
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(color: Colors.blueGrey[100]),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: ResponsiveFlutter.of(context).scale(80),
                  ),
                  Text('Available Balance'),
                  SizedBox(
                    height: ResponsiveFlutter.of(context).scale(10),
                  ),
                  Text(
                    wallet.balance > 0
                        ? wallet.balance.toStringAsFixed(2)
                        : '0',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveFlutter.of(context).fontSize(6)),
                  ),
                  Text(
                    'QAR',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveFlutter.of(context).fontSize(3)),
                  ),
                  SizedBox(
                    height: ResponsiveFlutter.of(context).scale(30),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          print('TopUp');

                          Get.to(TopUp());
                        },
                        child: Container(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.white),
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveFlutter.of(context).scale(10),
                              ),
                              Text(
                                'Top Up',
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          print('TopUp');
                          Get.to(ManageCards());
                        },
                        child: Container(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.white),
                                child: Icon(
                                  Icons.credit_card,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveFlutter.of(context).scale(10),
                              ),
                              Text(
                                'Manage Cards',
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(auth.fUser.uid)
              .collection('transactions')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:

              case ConnectionState.waiting:
                return SliverFixedExtentList(
                  itemExtent: 80.0,
                  delegate: SliverChildListDelegate([
                    Center(child: CircularProgressIndicator()),
                  ]),
                );

              default:
                if (snapshot.hasData) {
                  if (snapshot.data.documents.length != 0)
                    return SliverFixedExtentList(
                        itemExtent: 80.0,
                        delegate: SliverChildListDelegate([
                          Center(
                            child: Text(
                              'Recent Transactions',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          ...txnList(snapshot, context)
                        ]));
                  else
                    return SliverFixedExtentList(
                      itemExtent: 80.0,
                      delegate: SliverChildListDelegate([
                        Center(
                          child: Text(
                            'No Transactions Found',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      ]),
                    );
                } else if (snapshot.hasError) {
                  return SliverFixedExtentList(
                    itemExtent: 80.0,
                    delegate: SliverChildListDelegate(
                        [Center(child: Text('Error: ${snapshot.error}'))]),
                  );
                }

                return SliverFixedExtentList(
                  itemExtent: 80.0,
                  delegate: SliverChildListDelegate([
                    Center(
                      child: Text(
                        'No Transactions Found',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  ]),
                );
            }
          },
        ),
        // SliverFixedExtentList(
        //   itemExtent: 80.0,
        //   delegate: SliverChildListDelegate(
        //     [
        //       Container(
        //         padding: EdgeInsets.all(10),
        //         child: Text(
        //           'Recent Transactions',
        //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    ));
  }

  List<Widget> txnList(AsyncSnapshot snapshot, BuildContext context) {
    return snapshot.data.documents.map<Widget>((document) {
      var amount = document['amount'].toString() + ' QR';
      Color tColor = Colors.red;
      if (document['type'] == 'Credit') {
        tColor = Colors.green[800];
        amount = '+$amount';
      } else {
        tColor = Colors.red[800];
        amount = '-$amount';
      }
      return ListTile(
        title: Text(
          document['description'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(document['merchantReference']),
        trailing: Text(
          amount,
          style: TextStyle(color: tColor, fontWeight: FontWeight.bold),
        ),
      );
    }).toList();
  }
}
