import 'dart:io';
import 'dart:typed_data';

import 'package:blurhash/blurhash.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class VImageService {
  final ImagePicker _picker = ImagePicker();
  static VImageService instance = VImageService();

  Future<PickedFile> getImageFromLibrary() {
    return _picker.getImage(source: ImageSource.gallery);
  }

  Future<PickedFile> getImageFromCamera() {
    return _picker.getImage(source: ImageSource.camera);
  }

  Future<String> blurHashEncode(PickedFile file) async {
    // ByteData bytes = await rootBundle.load(file.path);
    Uint8List pixels = await file.readAsBytes();
    var hash = await BlurHash.encode(pixels, 4, 3);
    return hash;
  }

  Future<Uint8List> blurHashDecode(String hash,
      {int width = 20, int height = 12}) async {
    Uint8List imageDataBytes;
    try {
      imageDataBytes = await BlurHash.decode(hash, width, height);
      return imageDataBytes;
    } on PlatformException catch (e) {
      print(e.message);
      return null;
    }
  }
}
