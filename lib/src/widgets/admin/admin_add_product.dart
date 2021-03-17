import 'dart:io';

import 'package:baqaala/src/helpers/image_picker_helper.dart';
import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/models/v_image.dart';
import 'package:baqaala/src/services/cloud_storage_service.dart';
import 'package:baqaala/src/widgets/common/v_blurhash_image.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AdminAddProduct extends StatefulWidget {
  final String barcode;
  AdminAddProduct({Key key, this.barcode}) : super(key: key);

  @override
  _AdminAddProductState createState() => _AdminAddProductState();
}

class _AdminAddProductState extends State<AdminAddProduct> {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _titleEnController = TextEditingController();
  final TextEditingController _titleArController = TextEditingController();
  final TextEditingController _descriptionEnController =
      TextEditingController();
  final TextEditingController _descriptionArController =
      TextEditingController();
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _defaultPriceController = TextEditingController();
  final TextEditingController _discountPriceController =
      TextEditingController();
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  List<String> tags = [];
  List<VImage> images = [];
  VImage _vimage;
  bool _isBusy = false;
  bool _isUploading = false;
  String blurHash;
  bool _productExist = true;
  Item foundItem;

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
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            _barcodeField(),
            SizedBox(
              height: 10,
            ),
            foundItem != null ? _productCard(foundItem) : SizedBox(),
            !_productExist ? _imageSelect() : SizedBox(),
            SizedBox(
              height: 10,
            ),
            !_productExist ? _textFields() : SizedBox(),
            SizedBox(
              height: 10,
            ),
            !_productExist ? _submitButton() : SizedBox(),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      width: Get.width,
      height: 55,
      child: RaisedButton(
        color: Colors.green,
        child: Text(
          'Submit',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        onPressed: _isBusy
            ? null
            : () async {
                setState(() {
                  _isBusy = true;
                });
                if (_tagController.text.length > 0) {
                  tags = [];
                  var arr = _tagController.text.split(',');
                  if (arr.length > 0) {
                    arr.forEach((element) {
                      tags.add(element.trim());
                    });
                  }
                  print(tags);
                }

                Item product = Item(
                    barcode: _barcodeController.text,
                    titleEn: _titleEnController.text,
                    titleAr: _titleArController.text,
                    descriptionEn: _descriptionEnController.text,
                    descriptionAr: _descriptionArController.text,
                    volume: _volumeController.text,
                    defaultPrice: _defaultPriceController.text.length > 0
                        ? double.parse(_defaultPriceController.text)
                        : 0,
                    costPrice: _costPriceController.text.length > 0
                        ? double.parse(_costPriceController.text)
                        : 0,
                    discountPrice: _discountPriceController.text.length > 0
                        ? double.parse(_discountPriceController.text)
                        : 0,
                    tags: tags,
                    image: _vimage);

                try {
                  await Firestore.instance
                      .collection("globalItems")
                      .document(_barcodeController.text)
                      .setData(product.toJSON(), merge: true);
                  Get.back();
                  Get.snackbar(
                      'Succefully Added', 'Product Added Successfully');
                  print('success');
                } catch (e) {
                  print(e);
                }

                setState(() {
                  _isBusy = false;
                });
              },
      ),
    );
  }

  Widget _productCard(Item item) {
    // product card
    return Container(
      width: Get.width,
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Align(
            child: Text('Product Already Exists'),
          ),
          SizedBox(
            height: 10,
          ),
          VBlurHashImage(
            image: item.image.url,
            blurHash: item.image.blurhash,
            height: 250,
            width: 250,
            fit: BoxFit.fitHeight,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            item.titleEn,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Text(
              item.titleAr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            'Price : ${item.defaultPrice.toString()}QR',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _textFields() {
    return Column(
      children: <Widget>[
        TextField(
          controller: _titleEnController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          decoration: InputDecoration(
            // suffixIcon: Icon(Icons.search),
            labelText: 'Title English',
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: _titleArController,
          textDirection: TextDirection.rtl,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          decoration: InputDecoration(
            // suffixIcon: Icon(Icons.search),
            labelText: 'Title Arabic',
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: _descriptionEnController,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          maxLines: 3,
          decoration: InputDecoration(
            // suffixIcon: Icon(Icons.search),
            labelText: 'Description English',
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: _descriptionArController,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          textDirection: TextDirection.rtl,
          maxLines: 3,
          decoration: InputDecoration(
            // suffixIcon: Icon(Icons.search),
            labelText: 'Description Arabic',
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: _volumeController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          decoration: InputDecoration(
            // suffixIcon: Icon(Icons.search),
            hintText: 'Ex. 500g or 1.5L or 5Kg',
            labelText: 'Volume',
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: _defaultPriceController,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            // suffixIcon: Icon(Icons.search),
            labelText: 'Default Price',
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: _costPriceController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          decoration: InputDecoration(
            // suffixIcon: Icon(Icons.search),
            labelText: 'Cost Price',
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: _discountPriceController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          decoration: InputDecoration(
            // suffixIcon: Icon(Icons.search),
            labelText: 'Discount Price',
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: _tagController,
          textInputAction: TextInputAction.done,
          onEditingComplete: () {},
          onSubmitted: (val) {},
          decoration: InputDecoration(
            // suffixIcon: Icon(Icons.search),
            hintText: 'Ex: milk,dairy',
            labelText: 'Alternate Tags',
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
      ],
    );
  }

  Widget _imageSelect() {
    return GestureDetector(
      onTap: () async {
        var res = await VImagePicker.getImage();
        if (res == null) {
          return;
        }
        setState(() {
          _isUploading = true;
          _vimage = null;
          blurHash = res.blurHash;
        });

        print(res.imagePath);
        print(res.thumbPath);
        print(res.blurHash);

        var imgupload = await CloudStorageService.instance.uploadProductImage(
            '${_barcodeController.text}_product_image', File(res.imagePath));
        //   print(res.bytesTransferred);
        var imgurl = await imgupload.ref.getDownloadURL();
        var filename = await imgupload.ref.getName();

        var thumbupload = await CloudStorageService.instance.uploadProductImage(
            'thumb_${_barcodeController.text}_product_image',
            File(res.thumbPath));
        var thumburl = await thumbupload.ref.getDownloadURL();

        _vimage = VImage(
            blurhash: res.blurHash,
            url: imgurl,
            thumb: thumburl,
            filename: filename);

        setState(() {
          if (images.length > 0) {
            images[0] = _vimage;
          } else {
            images.add(_vimage);
          }
          _isUploading = false;
        });

        // print(imgurl);
        // print(filename);
        // print(thumburl);
        // print(thumbFilename);
      },
      child: (_vimage == null)
          ? Column(
              children: <Widget>[
                Container(
                  height: 200,
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Product Image',
                      style: TextStyle(color: Colors.green[500], fontSize: 20),
                    ),
                  ),
                ),
                _isUploading
                    ? LinearProgressIndicator(
                        backgroundColor: Colors.white,
                      )
                    : SizedBox()
              ],
            )
          : VBlurHashImage( 
              image: _vimage.url,
              blurHash: _vimage.blurhash,
              height: 200,
              width: Get.width,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _barcodeField() {
    if (widget.barcode != null) {
      _barcodeController.text = widget.barcode;
      return TextField(
        controller: _barcodeController,
        decoration: InputDecoration(
          // suffixIcon: Icon(Icons.search),
          labelText: 'Barcode',
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
        enabled: false,
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: 50,
            child: TextField(
              controller: _barcodeController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) =>
                  FocusScope.of(context).nextFocus(), // move focus to next

              onChanged: (val) {
                setState(() {});
              },
              onEditingComplete: () async {
                print('Searching for Product');
                var doc = await Firestore.instance
                    .collection("globalItems")
                    .document(_barcodeController.text)
                    .get();
                if (doc.exists) {
                  print('Product Exists');
                  setState(() {
                    foundItem = Item.fromSnapShot(doc);
                    print(foundItem.titleEn);
                    _productExist = true;
                  });
                } else {
                  print('Product Not Found');
                  setState(() {
                    foundItem = null;
                    _productExist = false;
                  });
                }
              },

              // onTap: () {
              //   setState(() {
              //     isBarcodeEditing = true;
              //   });
              // },
              decoration: InputDecoration(
                // suffixIcon: Icon(Icons.search),
                labelText: 'Enter Barcode',
                focusedBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
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
                var result = await BarcodeScanner.scan();
                if (result.rawContent.length > 0) {
                  _barcodeController.text = result.rawContent;
                  var doc = await Firestore.instance
                      .collection("globalItems")
                      .document(result.rawContent)
                      .get();
                  if (doc.exists) {
                    print('Product Exists');
                    setState(() {
                      foundItem = Item.fromSnapShot(doc);
                      print(foundItem.titleEn);
                      _productExist = true;
                    });
                  } else {
                    print('Product Not Found');
                    setState(() {
                      foundItem = null;
                      _productExist = false;
                    });
                  }

                  // _barcodeController.selection = TextSelection.fromPosition(
                  //     TextPosition(offset: _barcodeController.text.length));
                }
                print(result.rawContent);
              },
            ),
          ),
        ],
      );
    }
  }
}
