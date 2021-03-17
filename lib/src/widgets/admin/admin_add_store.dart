import 'package:baqaala/src/models/store.dart';
import 'package:baqaala/src/models/store_category.dart';
import 'package:baqaala/src/widgets/admin/admin_select_store_category.dart';
import 'package:baqaala/src/widgets/admin/admin_store_console.dart';
import 'package:baqaala/src/widgets/common/v_blurhash_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAddStore extends StatefulWidget {
  AdminAddStore({Key key}) : super(key: key);

  @override
  _AdminAddStoreState createState() => _AdminAddStoreState();
}

class _AdminAddStoreState extends State<AdminAddStore> {
  StoreCategory _storeCategory;
  String titleEn = '';
  bool _isBusy = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Add Store',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: <Widget>[
            _storeCategory != null
                ? _storeTypeCard()
                : Card(
                    child: ListTile(
                      title: Text(_storeCategory != null
                          ? '${_storeCategory.titleEn}'
                          : 'Select Store Type'),
                      subtitle: _storeCategory != null
                          ? Text('Tap to edit Store Type')
                          : Text('Tap to select Store Type'),
                      trailing: Icon(Icons.chevron_right),
                      leading: Icon(
                        Icons.store,
                        size: 40,
                        color: _storeCategory != null
                            ? Colors.green
                            : Colors.grey[300],
                      ),
                      onTap: () async {
                        StoreCategory res =
                            await Get.to(AdminSelectStoreCategory(
                          returnStoreType: true,
                        ));
                        if (res != null) {
                          setState(() {
                            _storeCategory = res;
                          });
                        }
                      },
                    ),
                  ),
            _storeFields(),
          ],
        ),
      ),

      // Center(
      //   child: RaisedButton(
      //     child: Text('Select Type'),
      //     onPressed: () async {
      //       StoreCategory res = await Get.to(AdminSelectStoreCategory(
      //         returnStoreType: true,
      //       ));

      //       // print(res?.id);
      //     },
      //   ),
      // ),
    );
  }

  Widget _storeFields() {
    return _storeCategory != null
        ? Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              TextField(
                onChanged: (val) {
                  setState(() {
                    titleEn = val;
                  });
                },
                autocorrect: false,
                style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Store Name",
                  labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  errorStyle:
                      TextStyle(color: Colors.redAccent[400], fontSize: 15),

                  // focusedBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(
                  //   color: Colors.green[900],
                  // )),
                  // focusedErrorBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(
                  //   color: Colors.redAccent[400],
                  // )),

                  // enabledBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(
                  //   color: Colors.green[900],
                  // )),
                  // fillColor: Colors.black.withOpacity(0.2),
                  // filled: true,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 50,
                width: double.infinity,
                child: RaisedButton(
                  color: Colors.green[700],
                  child: Text('NEXT',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  onPressed: (titleEn.length < 3 || _isBusy)
                      ? null
                      : () async {
                          setState(() {
                            _isBusy = true;
                          });
                          try {
                            DocumentReference ref = await Firestore.instance
                                .collection('stores')
                                .add({
                              'storeName': titleEn,
                              'categoryId': _storeCategory.id,
                              'category': _storeCategory.toJSON()
                            });

                            if (ref.documentID != null) {
                              var doc = await ref.get();
                              Store store = Store.fromSnapShot(doc);
                              Get.back();

                              Get.to(AdminStoreConsole(
                                store: store,
                                storeId: store.id,
                              ));
                            }
                            setState(() {
                              _isBusy = false;
                            });
                          } catch (e) {
                            setState(() {
                              _isBusy = false;
                            });
                            Get.rawSnackbar(
                              message: 'Unknown Error',
                              margin: EdgeInsets.all(10),
                              borderRadius: 10,
                              backgroundColor: Colors.red[800],
                              snackStyle: SnackStyle.FLOATING,
                            );
                          }

                          // Get.rawSnackbar(
                          //   message: 'Successfully Updated',
                          //   margin: EdgeInsets.all(10),
                          //   borderRadius: 10,
                          //   backgroundColor: Colors.green[800],
                          //   snackStyle: SnackStyle.FLOATING,
                          // );
                        },
                ),
              )
            ],
          )
        : SizedBox();
  }

  Widget _storeTypeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: () async {
          StoreCategory res = await Get.to(AdminSelectStoreCategory(
            returnStoreType: true,
          ));
          if (res != null) {
            setState(() {
              _storeCategory = res;
            });
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
                blurHash: _storeCategory.image.blurhash,
                image: _storeCategory.image.url,
                height: 130,
                width: Get.width,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(5)),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _storeCategory.titleEn,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Tap Here to Change Store Type',
                      style: TextStyle(
                        color: Colors.grey[350],
                        fontSize: 16,
                      ),
                    ),
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
