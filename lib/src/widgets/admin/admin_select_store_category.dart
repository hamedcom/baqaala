import 'package:baqaala/src/models/store_category.dart';
import 'package:baqaala/src/widgets/admin/admin_add_store_category.dart';
import 'package:baqaala/src/widgets/admin/admin_edit_store_category.dart';
import 'package:baqaala/src/widgets/common/v_blurhash_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminSelectStoreCategory extends StatefulWidget {
  final bool returnStoreType;
  AdminSelectStoreCategory({Key key, this.returnStoreType}) : super(key: key);

  @override
  _AdminSelectStoreCategoryState createState() =>
      _AdminSelectStoreCategoryState();
}

class _AdminSelectStoreCategoryState extends State<AdminSelectStoreCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          widget.returnStoreType ? 'Select Store Type' : 'Store Types',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
        height: Get.height,
        width: Get.width,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            widget.returnStoreType
                ? SizedBox()
                : GestureDetector(
                    onTap: () {
                      print('hello');

                      Get.to(AdminAddStoreCategory());
                    },
                    child: Container(
                      margin: EdgeInsets.all(8),
                      height: 60,
                      width: Get.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: LinearGradient(
                              colors: [
                                Colors.green[100],
                                Colors.green[100],
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                      child: Center(
                        child: Text(
                          'Add Store Type',
                          style: TextStyle(
                              color: Colors.green[900],
                              fontSize: 19,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
            SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: Firestore.instance.collection('storeTypes').snapshots(),
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
                        return Column(
                            children: storeTypeList(snapshot, context));
                      else
                        return Center(
                          child: Text(
                            'No Store Types.',
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
          ],
        ),
      ),
    );
  }

  List<Widget> storeTypeList(AsyncSnapshot snapshot, BuildContext context) {
    return snapshot.data.documents.map<Widget>((document) {
      StoreCategory store = StoreCategory.fromSnapShot(document);

      return _storeTypeCard(store, context);
    }).toList();
  }

  Widget _storeTypeCard(StoreCategory store, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: GestureDetector(
        onTap: () {
          if (widget.returnStoreType) {
            Get.back(result: store);
          } else {
            Get.to(AdminEditStoreCategory(
              storetype: store,
            ));
          }
        },
        // onLongPress: () {
        //   Get.to(AdminEditStoreCategory(
        //     storetype: store,
        //   ));
        // },
        child: Container(
          height: 130,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          child: Stack(
            children: <Widget>[
              VBlurHashImage(
                blurHash: store.image.blurhash,
                image: store.image.url,
                height: 130,
                width: Get.width,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(5)),
                child: Center(
                    child: Text(
                  store.titleEn,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                )),
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
}
