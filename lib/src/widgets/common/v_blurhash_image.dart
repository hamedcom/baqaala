import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:blurhash/blurhash.dart';
import 'package:transparent_image/transparent_image.dart';

class VBlurHashImage extends StatefulWidget {
  VBlurHashImage(
      {Key key,
      @required this.blurHash,
      @required this.image,
      this.width,
      this.height,
      this.fit = BoxFit.cover})
      : super(key: key);

  final String blurHash;
  final String image;
  final double width;
  final double height;
  final BoxFit fit;

  _VBlurHashImageState createState() => _VBlurHashImageState();
}

class _VBlurHashImageState extends State<VBlurHashImage> {
  Uint8List _imageDataBytes;

  @override
  void initState() {
    super.initState();
    blurHashDecode();
  }

  Future blurHashDecode() async {
    Uint8List imageDataBytes;

    try {
      imageDataBytes = await BlurHash.decode(widget.blurHash, 32, 32);
    } on PlatformException catch (e) {
      print(e.message);
    }

    setState(() {
      _imageDataBytes = imageDataBytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _imageDataBytes == null
        ? Container(width: widget.width, height: widget.height)
        : Stack(
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: 1,
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Image.memory(
                    _imageDataBytes,
                    width: widget.width,
                    height: widget.height,
                    fit: widget.fit,
                  ),
                ),
              ),
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: widget.image,
                    width: widget.width,
                    height: widget.height,
                    fit: widget.fit,
                  ),
                ),
              )
            ],
          );
  }
}
