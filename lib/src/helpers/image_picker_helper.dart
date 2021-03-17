// import 'package:baqaala/src/models/v_image.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:baqaala/src/models/image_paths.dart';
import 'package:blurhash/blurhash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class VImagePicker {
  static Future<ImagePaths> getImage({
    int imageWidth = 700,
    int imageHeight = 700,
    int imageQuality = 98,
    int thumbWidth = 250,
    int thumbHeight = 250,
    int thumbQuality = 98,
    bool getBlurHash = true,
  }) async {
    File image, thumb;
    String blurHash;

    PickedFile result = await Get.bottomSheet(imageBottomSheet());
    if (result != null) {
      print(result.path);
      image = await ImageCropper.cropImage(
        sourcePath: result.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio16x9,
          CropAspectRatioPreset.ratio7x5
        ],
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: imageQuality,
        maxWidth: imageWidth,
        maxHeight: imageHeight,
      );

      if (image != null) {
        ImageProperties properties =
            await FlutterNativeImage.getImageProperties(image.path);
        thumb = await FlutterNativeImage.compressImage(image.path,
            quality: thumbQuality,
            targetWidth: thumbWidth,
            targetHeight:
                (properties.height * thumbHeight / properties.width).round());
        Uint8List pixels = File(thumb.path).readAsBytesSync();
        if (getBlurHash) {
          blurHash = await BlurHash.encode(pixels, 4, 3);
        } else {
          blurHash = r'LZG6p1{I^6rX}G=0jGR$Z|t7NLW,';
        }

        return ImagePaths(
          imagePath: image.path,
          thumbPath: thumb.path,
          blurHash: blurHash,
        );
      } else {
        return null;
      }

      // ByteData bytes = await rootBundle.load(thumb.path);

    } else {
      return null;
    }
  }
}

Widget imageBottomSheet() {
  PickedFile image;
  ImagePicker _picker = ImagePicker();

  return Container(
    padding: EdgeInsets.all(10),
    height: 140,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey[100],
    ),
    child: Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 55,
          child: FlatButton(
            onPressed: () async {
              image = await _picker.getImage(
                source: ImageSource.camera,
              );
              Get.back(result: image);
            },
            color: Colors.green[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.camera_alt,
                  color: Colors.green[800],
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Take Photo',
                  style: TextStyle(fontSize: 16, color: Colors.green[800]),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          width: double.infinity,
          height: 55,
          child: FlatButton(
            onPressed: () async {
              image = await _picker.getImage(
                source: ImageSource.gallery,
              );
              Get.back(result: image);
            },
            color: Colors.orange[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.camera,
                  color: Colors.orange[900],
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Select From Gallery',
                  style: TextStyle(fontSize: 16, color: Colors.orange[900]),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
