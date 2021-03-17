import 'package:baqaala/src/providers/cart_provider.dart';
import 'package:baqaala/src/widgets/user/cart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ViewCartButton extends StatefulWidget {
  ViewCartButton({Key key}) : super(key: key);

  @override
  _ViewCartButtonState createState() => _ViewCartButtonState();
}

class _ViewCartButtonState extends State<ViewCartButton> {
  @override
  Widget build(BuildContext context) {
    final CartProvider cart = Provider.of<CartProvider>(context);
    return cart.itemCount > 0
        ? Container(
            width: Get.width * 0.95,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[800],
                    blurRadius: 3,
                    spreadRadius: 0,
                    offset: Offset(0, 0))
              ],
            ),
            child: GestureDetector(
              onTap: () async {
                await Get.to(Cart());
                setState(() {});
              },
              child: Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.green[800],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15))),
                    width: Get.width * 0.7,
                    height: 55,
                    child: Center(
                        child: Text(
                      '${cart.totalItem} Items , ${cart.totalAmount} QAR',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15))),
                    width: Get.width * 0.25,
                    height: 55,
                    child: Center(
                        child: Text(
                      'View Cart',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    )),
                  )
                ],
              ),
            ))
        : SizedBox();
  }
}
