import 'package:algolia/algolia.dart';
import 'package:baqaala/src/helpers/algolia_app.dart';
import 'package:baqaala/src/models/item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:get/get.dart';

class ProductSearch extends StatefulWidget {
  ProductSearch({Key key}) : super(key: key);

  @override
  _ProductSearchState createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  final Algolia _algoliaApp = AlgoliaApp.algolia;
  String _searchText;
  String _barcode;

  List<Item> products = [];

  Future<List<AlgoliaObjectSnapshot>> _search(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index('items').search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  @override
  void initState() {
    super.initState();
    readExcelFile();
  }

  readExcelFile() async {
    List<String> plist = [
      'baby-products',
      'beverages',
      'breakfast',
      'canned-items',
      'snacks'
    ];
    plist.forEach((cat) async {
      print(cat);
      ByteData data = await rootBundle.load("assets/$cat.xlsx");
      var bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      var excel = Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        print(table); //sheet Name
        print(excel.tables[table].maxCols);
        print(excel.tables[table].maxRows);
        for (var row in excel.tables[table].rows) {
          print(row[0]);
          if (row[0] != 'Product List' &&
              row[0] != null &&
              row[0] != 'BARCODE') {
            Item product = Item();
            product.barcode = row[1]?.toString();
            product.sku = row[1]?.toString();
            product.categories = ["$cat"];
            // product.subCategory = row[3];
            product.titleEn = row[0];
            // product.titleAr = row[5];
            product.descriptionEn = row[3];
            // product.descriptionAr = row[7];
            // product.volume = row[8]?.toString();
            product.defaultPrice = row[2]?.toDouble();
            product.costPrice = row[2]?.toDouble();
            product.discountPrice = row[2]?.toDouble();

            products.add(product);
            // print(product.barcode);
            await Firestore.instance
                .collection("globalItems")
                .document(product.barcode)
                .setData(product.toJSON(), merge: true);
          }
        }

        // print(products);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Upload Products',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: Get.width,
          child: Column(children: products.isNotEmpty ? productList() : []),
        ),
      ),
    );
  }

  List<Widget> productList() {
    return products.map<Widget>((document) {
      return _productCard(document);
    }).toList();
  }

  Widget _productCard(Item item) {
    return GestureDetector(
      child: Container(
        width: Get.width,
        // padding: EdgeInsets.all(15),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Title En : ${item.titleEn}'),
                Text('Title Ar : ${item.titleAr}'),
                Text('Description En : ${item.descriptionEn}'),
                Text('Description Ar : ${item.descriptionAr}'),
                Text('Default Price : ${item.defaultPrice}'),
                Text('Cost Price : ${item.costPrice}'),
                Text('Discount Price : ${item.discountPrice}'),
                Text('Volume : ${item.volume}'),
                Text('BarCode # ${item.barcode}'),
                Text('SKU # ${item.sku}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Item item;

  const ProductCard({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: Get.width,
      height: 110,
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.titleEn,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                item.titleAr,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Row(
                children: <Widget>[
                  Text('Price : '),
                  Text(
                    '${item.defaultPrice.toString()}QR',
                    style: TextStyle(decoration: TextDecoration.lineThrough),
                  ),
                  Text(
                    ' ${item.discountPrice.toString()}QR',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '#${item.barcode}',
                style: TextStyle(color: Colors.grey[400]),
              )
            ],
          )
        ],
      ),
    );
  }
}
