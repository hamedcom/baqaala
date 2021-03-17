import 'dart:io';

import 'package:baqaala/src/helpers/image_picker_helper.dart';
import 'package:baqaala/src/models/store_category.dart';
import 'package:baqaala/src/models/v_image.dart';
import 'package:baqaala/src/services/cloud_storage_service.dart';
import 'package:baqaala/src/widgets/common/v_blurhash_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEditStoreCategory extends StatefulWidget {
  final StoreCategory storetype;
  AdminEditStoreCategory({Key key, this.storetype}) : super(key: key);

  @override
  _AdminEditStoreCategoryState createState() => _AdminEditStoreCategoryState();
}

class _AdminEditStoreCategoryState extends State<AdminEditStoreCategory> {
  String _titleEn, _titleAr;
  bool _isVisible = true, _isBusy = false;
  VImage _vimage;

  TextEditingController _titleEnController = TextEditingController();
  TextEditingController _titleArController = TextEditingController();

  bool isValid() {
    if (_titleEn != null && _titleEn.length > 3 && _vimage != null) {
      return true;
    } else
      return false;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _titleEnController.text = widget.storetype.titleEn;
      _titleArController.text = widget.storetype.titleAr;
      _titleAr = widget.storetype.titleAr;
      _titleEn = widget.storetype.titleEn;
      _vimage = widget.storetype.image;
      _isVisible = widget.storetype.isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'Edit Store Category',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _titleEnController,
                    onChanged: (val) {
                      setState(() {
                        _titleEn = val;

                        print(_titleEn);
                      });
                    },
                    autocorrect: false,
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Store Type(English)",
                      labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      errorStyle:
                          TextStyle(color: Colors.redAccent[400], fontSize: 15),

                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.green[900],
                      )),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.redAccent[400],
                      )),

                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.green[900],
                      )),
                      // fillColor: Colors.black.withOpacity(0.2),
                      // filled: true,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _titleArController,
                    onChanged: (val) {
                      setState(() {
                        _titleAr = val;
                      });
                    },
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    autocorrect: false,
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Store Type (Arabic)",
                      labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      errorStyle:
                          TextStyle(color: Colors.redAccent[400], fontSize: 15),

                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.green[900],
                      )),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.redAccent[400],
                      )),

                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.green[900],
                      )),
                      // fillColor: Colors.black.withOpacity(0.2),
                      // filled: true,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _titleEn.length > 3
                      ? GestureDetector(
                          onTap: () async {
                            setState(() {
                              _isBusy = true;
                            });

                            var res = await VImagePicker.getImage();
                            if (res == null) {
                              return;
                            }
                            print(res.imagePath);
                            print(res.thumbPath);
                            print(res.blurHash);

                            var imgupload = await CloudStorageService.instance
                                .uploadStoreCategoryImage(
                                    '${widget.storetype.slug}_storetype_image',
                                    File(res.imagePath));
                            //   print(res.bytesTransferred);
                            var imgurl = await imgupload.ref.getDownloadURL();
                            var filename = await imgupload.ref.getName();

                            var thumbupload = await CloudStorageService.instance
                                .uploadStoreCategoryImage(
                                    'thumb_${widget.storetype.slug}_storetype_image',
                                    File(res.thumbPath));
                            var thumburl =
                                await thumbupload.ref.getDownloadURL();

                            _vimage = VImage(
                                blurhash: res.blurHash,
                                url: imgurl,
                                thumb: thumburl,
                                filename: filename);

                            setState(() {
                              _isBusy = false;
                            });

                            // print(imgurl);
                            // print(filename);
                            // print(thumburl);
                            // print(thumbFilename);
                          },
                          child: _vimage == null
                              ? Container(
                                  height: 150,
                                  width: Get.width,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Add Image',
                                      style: TextStyle(
                                          color: Colors.green[500],
                                          fontSize: 22),
                                    ),
                                  ),
                                )
                              : VBlurHashImage(
                                  image: _vimage.url,
                                  blurHash: _vimage.blurhash,
                                  height: 150,
                                  width: 500,
                                  fit: BoxFit.cover,
                                ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    width: Get.width,
                    child: RaisedButton(
                      color: Colors.green[600],
                      child: _isBusy
                          ? CircularProgressIndicator()
                          : Text(
                              'Save',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                      onPressed: (isValid() && !_isBusy)
                          ? () async {
                              setState(() {
                                _isBusy = true;
                              });

                              try {
                                await Firestore.instance
                                    .collection('storeTypes')
                                    .document(widget.storetype.slug)
                                    .setData({
                                  'titleEn': _titleEn,
                                  'titleAr': _titleAr,
                                  'isActive': _isVisible,
                                  'image': _vimage.toJSON(),
                                }, merge: true);
                                print('Success');

                                Get.back();
                              } catch (e) {
                                print(e);
                              }

                              setState(() {
                                _isBusy = false;
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
