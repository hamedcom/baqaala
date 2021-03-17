import 'package:algolia/algolia.dart';
import 'package:baqaala/src/helpers/algolia_app.dart';
import 'package:baqaala/src/models/category.dart';
import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/widgets/common/insta_item.dart';
import 'package:baqaala/src/widgets/common/insta_item2.dart';
import 'package:baqaala/src/widgets/user/search_product_delegate.dart';
import 'package:baqaala/src/widgets/user/view_cart_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlternativeItems extends StatefulWidget {
  final Item item;
  final String storeId;
  final Category category;
  final String subCategory;
  final bool isReturnItem;

  AlternativeItems(
      {Key key,
      this.item,
      this.category,
      this.subCategory,
      this.storeId,
      this.isReturnItem})
      : super(key: key);

  @override
  _AlternativeItemsState createState() => _AlternativeItemsState();
}

class _AlternativeItemsState extends State<AlternativeItems> {
  List<Item> _items = [];
  final Algolia _algoliaApp = AlgoliaApp.algolia;
  bool _isBusy = false;
  bool _isReturnItem;

  @override
  void initState() {
    super.initState();
    getProducts();
    _isReturnItem = widget.isReturnItem ?? false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[200],
      floatingActionButton: _isReturnItem ? SizedBox() : ViewCartButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Alternative Products',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              Item item = await showSearch(
                  context: context,
                  delegate: SearchProduct(isReturnItem: _isReturnItem));
              if (item != null) {
                Get.back(result: item);
              }
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
          child: _isBusy
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _items.length > 0
                  ? GridView.count(
                      crossAxisCount: 2,
                      children: _items.map((e) {
                        return InstantItem2(
                          // width: 300,
                          product: e,
                          storeId: widget.storeId,
                          isReturnItem: widget.isReturnItem,
                        );
                      }).toList(),
                    )
                  : Center(
                      child: Text('No Alternatives Found'),
                    ),
        )),
      ),
    );
  }

  getProducts() async {
    _isBusy = true;
    setState(() {});
    if (widget.item.tags.length > 0) {
      widget.item.tags.forEach((tag) async {
        var res = await _search(tag);
        if (res.length > 0) {
          res.forEach((aitem) {
            print(aitem);
            Item fItem = Item.fromJson(Map.from(aitem.data));
            if (widget.item.barcode != fItem.barcode) _items.add(fItem);
          });
        }
        _isBusy = false;
        setState(() {});
      });
    } else if (widget.item.subCategory != null) {
      var res = await _search(widget.item.subCategory);
      if (res.length > 0) {
        res.forEach((aitem) {
          print(aitem);
          Item fItem = Item.fromJson(Map.from(aitem.data));
          if (widget.item.barcode != fItem.barcode) _items.add(fItem);
        });
      }
      _isBusy = false;
      setState(() {});
    } else {
      _items = [];
      _isBusy = false;
      setState(() {});
    }
  }

  Future<List<AlgoliaObjectSnapshot>> _search(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index('items').search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  List<Widget> productList(AsyncSnapshot snapshot, BuildContext context) {
    return snapshot.data.documents.map<Widget>((document) {
      Item item = Item.fromSnapShot(document);

      return InstantItem(
        product: item,
        storeId: widget.storeId,
        isReturnItem: widget.isReturnItem,
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
