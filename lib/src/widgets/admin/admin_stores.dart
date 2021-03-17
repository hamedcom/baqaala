import 'package:baqaala/src/models/store.dart';
import 'package:baqaala/src/widgets/admin/admin_add_store.dart';
import 'package:baqaala/src/widgets/admin/admin_select_store_category.dart';
import 'package:baqaala/src/widgets/admin/admin_store_console.dart';
import 'package:baqaala/src/widgets/common/v_blurhash_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminStores extends StatefulWidget {
  AdminStores({Key key}) : super(key: key);

  @override
  _AdminStoresState createState() => _AdminStoresState();
}

class _AdminStoresState extends State<AdminStores> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Stores',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            _gotoStore(),
            SizedBox(
              height: 15,
            ),
            Text(
              'ALL STORES',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.grey[600]),
            ),
            SizedBox(
              height: 10,
            ),
            _stores(),
          ],
        ),
      ),
    );
  }

  Widget _stores() {
    return StreamBuilder(
      stream: Firestore.instance.collection('stores').snapshots(),
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
                return Column(children: storeList(snapshot, context));
              else
                return Center(
                  child: Text(
                    'No Stores.',
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

  List<Widget> storeList(AsyncSnapshot snapshot, BuildContext context) {
    return snapshot.data.documents.map<Widget>((document) {
      Store store = Store.fromSnapShot(document);

      return _storeCard(store);
    }).toList();
  }

  Widget _storeCard(Store store) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: () {
          Get.to(AdminStoreConsole(
            store: store,
            storeId: store.id,
          ));
        },
        // onLongPress: () {
        //   Get.to(AdminEditStoreCategory(
        //     storetype: store,
        //   ));
        // },
        child: Container(
          height: 80,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          child: Stack(
            children: <Widget>[
              VBlurHashImage(
                blurHash: store.category.image.blurhash,
                image: store.category.image.url,
                height: 80,
                width: Get.width,
                fit: BoxFit.cover,
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        store.storeName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        '(${store.category.titleEn})',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ]),
              ),
              // Container(
              //   padding: EdgeInsets.all(10),
              //   child: Align(
              //       alignment: Alignment.bottomRight,
              //       child: Text(
              //         "Long Press to Edit",
              //         style: TextStyle(
              //           color: Colors.white38,
              //           fontSize: 14,
              //         ),
              //       )),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gotoStore() {
    final size = MediaQuery.of(context).size.width * .43;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        GestureDetector(
          child: Container(
            width: size,
            height: 60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: LinearGradient(colors: [
                  Colors.green[100],
                  Colors.green[100],
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Center(
              child: Text(
                'New Store',
                style: TextStyle(
                    color: Colors.green[900],
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          onTap: () {
            Get.to(AdminAddStore());
          },
        ),
        GestureDetector(
          child: Container(
            width: size,
            height: 60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.grey[700],
                //     offset: Offset(2, 2),
                //     blurRadius: 5,
                //   ),
                // ],
                gradient: LinearGradient(colors: [
                  Colors.orange[100],
                  Colors.orange[100],
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Center(
              child: Text(
                'Store Types',
                style: TextStyle(
                    color: Colors.orange[900],
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          onTap: () {
            Get.to(AdminSelectStoreCategory(
              returnStoreType: false,
            ));
          },
        ),
      ],
    );
  }
}
