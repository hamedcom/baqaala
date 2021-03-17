import 'dart:io';

import 'package:baqaala/src/helpers/image_picker_helper.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/services/cloud_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class UserSuggestItem extends StatefulWidget {
  UserSuggestItem({Key key}) : super(key: key);

  @override
  _UserSuggestItemState createState() => _UserSuggestItemState();
}

class _UserSuggestItemState extends State<UserSuggestItem> {
  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _itemDescriptionController = TextEditingController();
  String _itemName = '', _itemDescription = '', _imageUrl;
  bool _isBusy = false;
  bool _isUploading = false;
  File _selectedImage;
  String _filePath;

  @override
  void initState() {
    super.initState();

    _itemNameController.addListener(() {
      setState(() {
        _itemName = _itemNameController.text;
      });
    });

    _itemDescriptionController.addListener(() {
      setState(() {
        _itemDescription = _itemDescriptionController.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (mounted) {
      _itemNameController.removeListener(() {});
      _itemDescriptionController.removeListener(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthModel _auth = Provider.of<AuthModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Suggest Item',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Container(
            height: Get.height,
            width: Get.width,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _itemNameController,
                  decoration: InputDecoration(
                      hintText: 'Item or Service Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4))),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _itemDescriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                      hintText: 'Desciption about Item or Service',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4))),
                ),
                SizedBox(
                  height: 10,
                ),
                _selectImage(),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 50,
                  width: Get.width,
                  child: RaisedButton(
                    color: Colors.green[800],
                    textColor: Colors.white,
                    child: _isBusy
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            'Submit',
                            style: TextStyle(
                                fontSize: ResponsiveFlutter.of(context)
                                    .fontSize(2.3)),
                          ),
                    onPressed: (_itemName != '' &&
                            _itemDescription != '' &&
                            !_isBusy)
                        ? () async {
                            setState(() {
                              _isBusy = true;
                            });
                            print(_itemName);
                            print(_itemDescription);
                            print(_imageUrl);

                            var res = await Firestore.instance
                                .collection('suggestions')
                                .add({
                              'imageUrl': _imageUrl,
                              'itemName': _itemName,
                              'itemDescription': _itemDescription,
                              'createdAt': FieldValue.serverTimestamp(),
                              'user': _auth.fUser.toJSON()
                            });

                            if (res != null) {
                              Get.back();
                              Get.snackbar(
                                  'Thank You', 'Thank you for your Suggestions',
                                  colorText: Colors.white,
                                  backgroundColor: Colors.green[800]);
                            }

                            setState(() {
                              _isBusy = false;
                            });
                          }
                        : null,
                  ),
                )
              ],
            )),
      ),
    );
  }

  Widget _selectImage() {
    return GestureDetector(
      onTap: () async {
        var res = await VImagePicker.getImage();
        if (res == null) {
          return;
        }

        setState(() {
          _isUploading = true;
          _isBusy = true;
          _filePath = res.imagePath;
        });

        var fileTime = DateTime.now().millisecondsSinceEpoch;

        var imgupload = await CloudStorageService.instance
            .uploadSuggestionImage(
                '${fileTime}_product_image', File(res.imagePath));
        //   print(res.bytesTransferred);
        _imageUrl = await imgupload.ref.getDownloadURL();

        setState(() {
          _isUploading = false;
          _isBusy = false;
        });
        print(_imageUrl);
      },
      child: _filePath == null
          ? Container(
              height: 50,
              // width: Get.width,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () async {
                      var res = await VImagePicker.getImage();
                      if (res == null) {
                        return;
                      }

                      setState(() {
                        _isUploading = true;
                        _isBusy = true;
                        _filePath = res.imagePath;
                      });

                      var fileTime = DateTime.now().millisecondsSinceEpoch;

                      var imgupload = await CloudStorageService.instance
                          .uploadSuggestionImage(
                              '${fileTime}_product_image', File(res.imagePath));
                      //   print(res.bytesTransferred);
                      _imageUrl = await imgupload.ref.getDownloadURL();

                      setState(() {
                        _isUploading = false;
                        _isBusy = false;
                      });
                      print(_imageUrl);
                    },
                  )),
            )
          : Container(
              width: Get.width,
              height: 200,
              child: Image.file(
                File(_filePath),
                fit: BoxFit.contain,
              )),
    );
  }
}
