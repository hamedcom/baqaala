import 'dart:async';

import 'package:baqaala/src/models/category.dart';
import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/models/store.dart';
import 'package:baqaala/src/models/store_category.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/providers/cart_provider.dart';
import 'package:baqaala/src/providers/wallet_provider.dart';
import 'package:baqaala/src/widgets/common/insta_item.dart';
import 'package:baqaala/src/widgets/common/insta_item2.dart';
import 'package:baqaala/src/widgets/user/search_product_delegate.dart';
import 'package:baqaala/src/widgets/user/view_cart_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class UserProducts extends StatefulWidget {
  final Store store;
  final String storeId;
  final StoreCategory storeType;
  final String category;
  final String subCategory;

  UserProducts(
      {Key key,
      this.store,
      this.storeType,
      this.category,
      this.subCategory,
      this.storeId})
      : super(key: key);

  @override
  _UserProductsState createState() => _UserProductsState();
}

class _UserProductsState extends State<UserProducts> {
  List<Item> _items = [];
  List<String> _favIds = [];
  StreamSubscription _controller;
  Stream<DocumentSnapshot> _snapshot;

  getCart() {
    final CartProvider cart = Provider.of<CartProvider>(context);
  }

  @override
  void initState() {
    super.initState();
    getFavIds();
    // getCart();
  }

  void getFavIds() {
    final AuthModel auth = Provider.of<AuthModel>(context, listen: false);
    _controller = Firestore.instance
        .collection('users')
        .document(auth.userId)
        .collection('favourites')
        .document('items')
        .snapshots()
        .listen((doc) {
      print('listening');
      if (doc.exists) {
        var ids = doc['favIds'] != null ? List<String>.from(doc['favIds']) : [];
        if (ids.length > 0) {
          _favIds = ids;
          print(ids);
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _controller?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[200],
      floatingActionButton: ViewCartButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          widget.category ?? 'Select Products',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final item =
                  await showSearch(context: context, delegate: SearchProduct());
              setState(() {});
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
        ),
        child: SingleChildScrollView(
            child: Container(
          // color: Colors.grey[300],
          width: Get.width,
          height: Get.height,
          child: Column(
            children: <Widget>[
              _productList(),
              SizedBox(
                height: 90,
              )
            ],
          ),
        )),
      ),
    );
  }

  getProducts() {}

  List<Widget> productList(AsyncSnapshot snapshot, BuildContext context) {
    return snapshot.data.documents.map<Widget>((document) {
      Item item = Item.fromSnapShot(document);

      return InstantItem2(
        product: item,
        storeId: widget.storeId,
        isReturnItem: false,
        isFavourite: _favIds.contains(item.id),
      );
    }).toList();
  }

  Widget _productList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('globalItems')
          .where('availableStores', arrayContains: widget.storeId)
          // .where('category', arrayContains: 'fruits')
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
                        children: productList(snapshot, context)));
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
    );
  }
}
