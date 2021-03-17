import 'package:baqaala/src/common/utils.dart';
import 'package:baqaala/src/models/cart_item.dart';
import 'package:baqaala/src/providers/cart_provider.dart';
import 'package:baqaala/src/widgets/common/insta_item.dart';
import 'package:baqaala/src/widgets/user/checkout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
// import 'package:secure_application/secure_application.dart';

class Cart extends StatefulWidget {
  const Cart({Key key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  // Future<void> secureScreen() async {
  //   await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  // }

  // Future<void> removeSecureScreen() async {
  //   await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  // }

  @override
  void initState() {
    // secureScreen();

    super.initState();
  }

  @override
  void dispose() {
    // removeSecureScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CartProvider cart = Provider.of<CartProvider>(context);
    return Scaffold(
        bottomNavigationBar: _bottomNavigation(),
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Cart',
            style: TextStyle(color: Colors.green[600]),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.green[800]),
        ),
        body: SingleChildScrollView(
          child: cart.itemCount > 0
              ? Column(
                  children: _viewCart(),
                )
              : _noItems(),
        ));
  }

  List<Widget> _viewCart() {
    final CartProvider cart = Provider.of<CartProvider>(context);
    return cart.cartItems.map<Widget>((item) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        width: Get.width,
        height: Get.width * 0.2,
        child: Row(
          children: <Widget>[
            Container(
              width: Get.width * 0.2,
              height: Get.width * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey, blurRadius: 2, offset: Offset(1, 1))
                ],
                image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: item.item.image != null
                      ? CachedNetworkImageProvider(item.item.image.thumb)
                      : CachedNetworkImageProvider(
                          Utils.getImageLinkBySku(item.item.sku)),
                ),
              ),
              // child: CachedNetworkImage(
              //   imageUrl: item.item.image.thumb,
              //   width: 150,
              //   height: 150,
              //   fit: BoxFit.cover,
              // ),
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              width: Get.width * 0.4,
              // color: Colors.green,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    item.item.titleEn,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    item.item.volume ?? '',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  Text(
                    '${item.item.defaultPrice} QAR',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  )
                ],
              ),
            ),
            Container(
              width: Get.width * 0.3,
              // color: Colors.green,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${item.total} QAR',
                    style: TextStyle(
                        color: Colors.green[800], fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 20,
                        child: FlatButton(
                          color: Colors.green[100],
                          textColor: Colors.green[900],
                          child: Center(child: Text('+')),
                          onPressed: () {
                            cart.addItem(item.item);
                          },
                        ),
                      ),
                      Text(
                        item.quantity.toString(),
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        width: 40,
                        height: 20,
                        child: Center(
                          child: FlatButton(
                            color: Colors.grey[400],
                            child: Text('-'),
                            onPressed: () {
                              cart.removeItem(item.item);
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      );

      //  Wrap(
      //   direction: Axis.vertical,
      //   children: <Widget>[
      //     Text(
      //         '${item.item.titleEn} - ${item.quantity} X ${item.item.defaultPrice} = ${item.total} QAR'),
      //     FlatButton(
      //       child: Text('+'),
      //       onPressed: () {
      //         cart.addItem(item.item);
      //       },
      //     ),
      //     FlatButton(
      //       child: Text('-'),
      //       onPressed: () {
      //         cart.removeItem(item.item);
      //       },
      //     )
      //   ],
      // );
    }).toList();
  }

  Widget _bottomNavigation() {
    final CartProvider cart = Provider.of<CartProvider>(context);

    return Container(
      padding: EdgeInsets.all(10),

      height: 150,
      decoration: BoxDecoration(
          color: Colors.grey[200], shape: BoxShape.rectangle
          // RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)));
          ),
      // color: Colors.green,
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total : ${cart.totalAmount} QAR',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              )),
          Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Convenience Fee : 10.0 QAR',
                style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.bold,
                    fontSize: 16),
              )),
          Align(
              alignment: Alignment.centerRight,
              child: Text(
                'SubTotal : ${cart.totalAmount + 10} QAR',
                style: TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              )),
          SizedBox(
            height: 10,
          ),
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: Get.width * 0.45,
                height: 55,
                child: OutlineButton(
                  borderSide: BorderSide(color: Colors.green),
                  textColor: Colors.green[800],
                  child: Text('Add Items'),
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                ),
              ),
              Container(
                width: Get.width * 0.45,
                height: 55,
                child: FlatButton(
                  color: Colors.green[800],
                  textColor: Colors.white,
                  child: Text('Checkout'),
                  onPressed: () {
                    Get.to(CheckOutPage());
                  },
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _noItems() {
    return Center(
      child: Text(
        'Your Cart is Empty',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19),
      ),
    );
  }
}
