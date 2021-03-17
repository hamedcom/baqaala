import 'package:baqaala/src/common/utils.dart';
import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/models/store.dart';
import 'package:baqaala/src/widgets/admin/admin_store_add_product.dart';
import 'package:baqaala/src/widgets/common/v_blurhash_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transparent_image/transparent_image.dart';

class AdminStoreProducts extends StatefulWidget {
  final Store store;
  AdminStoreProducts({Key key, this.store}) : super(key: key);

  @override
  _AdminStoreProductsState createState() => _AdminStoreProductsState();
}

class _AdminStoreProductsState extends State<AdminStoreProducts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Get.to(AdminStoreAddProduct(store: widget.store));
        },
      ),
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Products',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Container(
        width: Get.width,
        height: Get.height,
        child: Column(
          children: <Widget>[_productList()],
        ),
      )),
    );
  }

  Widget _productList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('globalItems')
          .where('availableStores', arrayContains: widget.store.id)
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

  List<Widget> productList(AsyncSnapshot snapshot, BuildContext context) {
    return snapshot.data.documents.map<Widget>((document) {
      Item item = Item.fromSnapShot(document);

      return _productCard(item);
    }).toList();
  }

  Widget _productCard(Item item) {
    return GestureDetector(
      child: Card(
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 145,
              child: item.image != null
                  ? VBlurHashImage(
                      blurHash: item.image.blurhash,
                      image: item.image.thumb,
                      height: 145,
                      fit: BoxFit.cover,
                    )
                  : FadeInImage.memoryNetwork(
                      height: 145,
                      fit: BoxFit.cover,
                      placeholder: kTransparentImage,
                      image: Utils.getImageLinkBySku(item.sku),
                    ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              item.titleEn,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: 5,
            ),
            Text('Price: ${item.defaultPrice} QR'),
            // SizedBox(
            //   height: 5,
            // ),
            // Container(
            //   width: double.infinity,
            //   height: 48,
            //   child: RaisedButton(
            //     color: Colors.green[800],
            //     child: Text(
            //       item.availableStores.contains(widget.store.id)
            //           ? 'Added '
            //           : 'Add To Store',
            //       style: TextStyle(color: Colors.white),
            //     ),
            //     onPressed: item.availableStores.contains(widget.store.id)
            //         ? null
            //         : () async {
            //             await Firestore.instance
            //                 .collection('globalItems')
            //                 .document(item.id)
            //                 .updateData({
            //               'availableStores':
            //                   FieldValue.arrayUnion([widget.store.id])
            //             });

            //             // Get.snackbar('Success', 'Successfully Added');
            //           },
            //   ),
            // ),
          ],
        ),
      ),
      onTap: () {
        print(item.id);
      },
    );
  }
}
