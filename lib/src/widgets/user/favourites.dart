import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/widgets/common/insta_item2.dart';
import 'package:baqaala/src/widgets/user/user_order_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserFavourites extends StatefulWidget {
  const UserFavourites({Key key}) : super(key: key);

  @override
  _UserFavouritesState createState() => _UserFavouritesState();
}

class _UserFavouritesState extends State<UserFavourites> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AuthModel auth = Provider.of<AuthModel>(context);

    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'Favourites',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            height: Get.height,
            width: Get.width,
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(auth.fUser.uid)
                  .collection('favourites')
                  .document('items')
                  .collection('items')
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
                        return Expanded(
                            child: GridView.count(
                                crossAxisCount: 2,
                                children: _favList(snapshot, context)));
                      else
                        return Center(
                          child: Text(
                            'No Products.',
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
            ),
          ),
        ));
  }

  List<Widget> _favList(AsyncSnapshot snapshot, BuildContext context) {
    return snapshot.data.documents.map<Widget>((document) {
      Item item = Item.fromSnapShot(document);

      return InstantItem2(
        product: item,
        isReturnItem: false,
      );
    }).toList();
  }
}
