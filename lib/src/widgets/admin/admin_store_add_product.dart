import 'package:baqaala/src/common/utils.dart';
import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/models/store.dart';
import 'package:baqaala/src/widgets/common/v_blurhash_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transparent_image/transparent_image.dart';

class AdminStoreAddProduct extends StatefulWidget {
  final Store store;
  AdminStoreAddProduct({Key key, this.store}) : super(key: key);

  @override
  _AdminStoreAddProductState createState() => _AdminStoreAddProductState();
}

class _AdminStoreAddProductState extends State<AdminStoreAddProduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Add Product',
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
      stream: Firestore.instance.collection('globalItems').snapshots(),
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
              height: 100,
              child: item.image != null
                  ? VBlurHashImage(
                      blurHash: item.image.blurhash,
                      image: item.image.thumb,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        height: 100,
                        fit: BoxFit.cover,
                        image: Utils.getImageLinkBySku(item.sku),
                      ),
                    ),
            ),
            // : Center(
            //     child: Image.asset(
            //       'assets/images/top2.jpg',
            //       height: 100,
            //       width: 100,
            //       fit: BoxFit.cover,
            //     ),
            //   )),
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
            Container(
              width: double.infinity,
              height: 45,
              child: RaisedButton(
                color: Colors.green[800],
                child: Text(
                  item.availableStores.contains(widget.store.id)
                      ? 'Added '
                      : 'Add To Store',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: item.availableStores.contains(widget.store.id)
                    ? null
                    : () async {
                        await Firestore.instance
                            .collection('globalItems')
                            .document(item.id)
                            .updateData({
                          'availableStores':
                              FieldValue.arrayUnion([widget.store.id])
                        });

                        // Get.snackbar('Success', 'Successfully Added');
                      },
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        print(item.id);
      },
    );
  }
}
