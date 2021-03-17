import 'package:algolia/algolia.dart';
import 'package:baqaala/src/helpers/algolia_app.dart';
import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/widgets/common/insta_item.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchProduct extends SearchDelegate<Item> {
  final Algolia _algoliaApp = AlgoliaApp.algolia;
  bool isReturnItem = false;

  SearchProduct({this.isReturnItem});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
      IconButton(
        icon: Icon(FontAwesomeIcons.barcode),
        onPressed: () async {
          var result = await BarcodeScanner.scan(
              options: ScanOptions(restrictFormat: [
            BarcodeFormat.code128,
            BarcodeFormat.code39,
            BarcodeFormat.aztec,
            BarcodeFormat.code93,
            BarcodeFormat.dataMatrix,
            BarcodeFormat.ean13,
            BarcodeFormat.ean8,
            BarcodeFormat.interleaved2of5,
            BarcodeFormat.pdf417
          ]));
          if (result.rawContent.length > 0) {
            query = result.rawContent;
          }
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: _search(query),
      builder: (context, res) {
        switch (res.connectionState) {
          case ConnectionState.done:
            return GridView.count(
              crossAxisCount: 2,
              children: _productsFound(res.data, context),
            );
          case ConnectionState.waiting:
            return Center(
              child: SpinKitThreeBounce(
                size: 20,
                color: Colors.green,
              ),
            );
          case ConnectionState.none:
            print('None');
            break;
          default:
            return Center(
              child: SpinKitThreeBounce(
                size: 20,
                color: Colors.green,
              ),
            );
        }

        if (res.connectionState == ConnectionState.done) {}
        return Container(
          child: Text('OK'),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    print(query);
    if (query.length > 0) {
      return FutureBuilder(
        future: _search(query),
        builder: (context, res) {
          switch (res.connectionState) {
            case ConnectionState.done:
              return GridView.count(
                crossAxisCount: 2,
                children: _productsFound(res.data, context),
              );
            case ConnectionState.waiting:
              return Center(
                child: SpinKitThreeBounce(
                  size: 20,
                  color: Colors.green,
                ),
              );
            case ConnectionState.none:
              print('None');
              break;
            default:
              return Center(
                child: SpinKitThreeBounce(
                  size: 20,
                  color: Colors.green,
                ),
              );
          }

          if (res.connectionState == ConnectionState.done) {}
          return Container(
            child: Text('OK'),
          );
        },
      );
    } else {
      return Container(
        child: Center(
          child: Text('Suggestions'),
        ),
      );
    }
  }

  List<Widget> _productsFound(
      List<AlgoliaObjectSnapshot> foundItems, BuildContext context) {
    return foundItems.map<Widget>((item) {
      print(item.objectID);
      return InstantItem(
        width: 300,
        product: Item.fromJson(Map.from(item.data)),
        isReturnItem: isReturnItem,
      );
    }).toList();

    // List<Item> _products = [];
    // if (foundItems.isNotEmpty) {
    //   foundItems.forEach((element) {
    //     _products.add(Item.fromJson(Map.from(element.data)));
    //   });
    // } else {}
  }

  Future<List<AlgoliaObjectSnapshot>> _search(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index('items').search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }
}
