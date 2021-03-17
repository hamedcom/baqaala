import 'dart:io';

import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  FirebaseStorage _storage;
  StorageReference _baseRef;

  String _profileImages = "profile_images";
  String _messages = "messages";
  String _images = "images";

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage.ref();
  }

  String getImageBySku(String sku) {
    String filename = sku + '.jpg';
    _baseRef
        .child('pimages')
        .child(filename)
        .getDownloadURL()
        .then((value) => print(value));
  }

  Future<StorageTaskSnapshot> uploadStoreCategoryImage(
      String _id, File _image) {
    String filename = _id + '.jpg';
    try {
      return _baseRef
          .child('store_category_images')
          .child(filename)
          .putFile(_image)
          .onComplete;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<StorageTaskSnapshot> uploadProductImage(String _id, File _image) {
    String filename = _id + '.jpg';
    try {
      return _baseRef
          .child('product_images')
          .child(filename)
          .putFile(_image)
          .onComplete;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<StorageTaskSnapshot> uploadSuggestionImage(String _id, File _image) {
    String filename = _id + '.jpg';
    try {
      return _baseRef
          .child('product_suggestions')
          .child(filename)
          .putFile(_image)
          .onComplete;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<StorageTaskSnapshot> uploadMediaMessage(String _uid, File _file) {
    var _timestamp = DateTime.now();
    var _fileName = basename(_file.path);
    _fileName += "_${_timestamp.toString()}";
    try {
      return _baseRef
          .child(_messages)
          .child(_uid)
          .child(_images)
          .child(_fileName)
          .putFile(_file)
          .onComplete;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
