import 'dart:io';

import 'package:algolia/algolia.dart';
import 'package:baqaala/src/common/utils.dart';
import 'package:baqaala/src/helpers/algolia_app.dart';
import 'package:baqaala/src/helpers/image_picker_helper.dart';
import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/models/slot.dart';
import 'package:baqaala/src/models/v_image.dart';
import 'package:baqaala/src/services/cloud_storage_service.dart';
import 'package:baqaala/src/services/image_service.dart';
import 'package:baqaala/src/widgets/admin/admin_add_product.dart';
import 'package:baqaala/src/widgets/common/product_search.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slugify2/slugify.dart';
import 'package:transparent_image/transparent_image.dart';

class AdminProducts extends StatefulWidget {
  AdminProducts({Key key}) : super(key: key);

  @override
  _AdminProductsState createState() => _AdminProductsState();
}

class _AdminProductsState extends State<AdminProducts> {
  TextEditingController barcodeController = TextEditingController();
  final Algolia _algoliaApp = AlgoliaApp.algolia;
  String barcode;
  bool isBarcodeEditing = false;
  String fileUrl;
  List<String> slots = [];
  List<VImage> _images = [];
  List<Item> _products = [];

  @override
  void initState() {
    super.initState();
    barcodeController.addListener(() {
      barcode = barcodeController.text;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        // elevation: 0,
        child: Icon(Icons.add),
        onPressed: () {
          // Get.to(AdminAddProduct(
          //     // barcode: '43225666334664',
          //     ));
          Get.to(ProductSearch());
        },
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Global Products',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: ListView(
          padding: EdgeInsets.only(top: 25, left: 10, right: 10),
          children: [
            _searchBar(showSearchBar: isBarcodeEditing),
            _products.isNotEmpty ? Column(children: productList()) : SizedBox(),
            // _slotSelection()
          ]
          //  RaisedButton(
          //   child: Text('Scan Barcode'),
          //   onPressed: () async {
          //     var result = await BarcodeScanner.scan();
          //     print(result.rawContent);
          //   },
          // ),
          ),
    );
  }

  // Widget _slotSelection() {
  //   return ListView.builder(
  //       shrinkWrap: true,
  //       itemCount: allSlots.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return CheckboxListTile(
  //           title: Text(allSlots[index]),
  //           activeColor: Colors.green[800],
  //           value: slots.contains(allSlots[index]),
  //           onChanged: (val) {
  //             if (val) {
  //               slots.add(allSlots[index]);
  //             } else {
  //               slots.remove(allSlots[index]);
  //             }
  //             print(slots);
  //             // print(Slugify().slugify(allSlots[index]));
  //             setState(() {});
  //           },
  //         );
  //       });
  // }

  _searchItem(String query) async {
    List<AlgoliaObjectSnapshot> items = await _search(query);

    if (items.isNotEmpty) {
      _products = [];
      items.forEach((element) {
        _products.add(Item.fromJson(Map.from(element.data)));
      });
      setState(() {});
    } else {
      _products = [];
      setState(() {});
    }
  }

  Future<List<AlgoliaObjectSnapshot>> _search(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index('items').search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  List<Widget> productList() {
    return _products.map<Widget>((document) {
      return ProductCard(item: document);
    }).toList();
  }

  Widget _searchBar({bool showSearchBar = true}) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: 50,
              child: TextField(
                controller: barcodeController,
                onChanged: (val) {
                  if (val.length > 0)
                    isBarcodeEditing = true;
                  else
                    isBarcodeEditing = false;
                  if (val.length > 0) {
                    _searchItem(val);
                  } else {
                    _products = [];
                  }

                  setState(() {});
                },

                // onTap: () {
                //   setState(() {
                //     isBarcodeEditing = true;
                //   });
                // },
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.search),
                  labelText: 'Search',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              height: 50,
              child: RaisedButton(
                color: Colors.amber,
                child: Icon(FontAwesomeIcons.qrcode),
                onPressed: () async {
                  setState(() {
                    isBarcodeEditing = false;
                  });
                  var result = await BarcodeScanner.scan();
                  if (result.rawContent.length > 0) {
                    barcodeController.text = result.rawContent;

                    _searchItem(result.rawContent);

                    print(result.rawContent);
                  }
                },
              ),
            ),
          ],
        ),
        // SizedBox(
        //   height: showSearchBar ? 10 : 0,
        // ),
        // showSearchBar
        //     ? Container(
        //         height: 50,
        //         width: MediaQuery.of(context).size.width,
        //         child: RaisedButton(
        //           color: Colors.green[800],
        //           child: Text(
        //             'Search Product',
        //             style: TextStyle(color: Colors.white),
        //           ),
        //           onPressed: () {
        //             Slugify slugify = new Slugify();
        //             String slug = slugify.slugify('Hello World!');
        //             print(slug);
        //           },
        //         ),
        //       )
        //     : SizedBox()
      ],
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
          FadeInImage.memoryNetwork(
              width: 100,
              height: 100,
              placeholder: kTransparentImage,
              image: Utils.getImageLinkBySku(item.sku)),
          // CachedNetworkImage(
          //   height: 100,
          //   width: 100,
          //   imageUrl: item.image != null
          //       ? item.image.thumb
          //       : Utils.getImageLinkBySku(item.sku),
          //   fit: BoxFit.cover,
          // ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.titleEn,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              // Text(
              //   item?.titleAr,
              //   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              // ),
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
