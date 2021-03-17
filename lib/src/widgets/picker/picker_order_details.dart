import 'package:baqaala/src/models/cart_item.dart';
import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/models/order.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/services/order_service.dart';
import 'package:baqaala/src/widgets/picker/picker_item_details.dart';
import 'package:baqaala/src/widgets/user/alternative_items.dart';
import 'package:baqaala/src/widgets/user/home.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class PickerOrderDetails extends StatefulWidget {
  final String orderId;
  PickerOrderDetails({Key key, this.orderId}) : super(key: key);

  @override
  _PickerOrderDetailsState createState() => _PickerOrderDetailsState();
}

class _PickerOrderDetailsState extends State<PickerOrderDetails> {
  Order _order;
  List<CartItem> _items;
  final OrderService _orderService = OrderService.instance;
  int _itemsToSelect;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    getOrder();
  }

  void getOrder() {
    Firestore.instance
        .collection('orders')
        .document(widget.orderId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _order = Order.fromSnapShot(doc);
        _items = _order.items;
        _itemsToSelect = 0;
        _items.forEach((element) {
          if (!element.isPicked && element.isAvailable && !element.isRemoved)
            _itemsToSelect++;
        });
        Future.delayed(Duration(milliseconds: 10), () {
          if (mounted) setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthModel auth = Provider.of<AuthModel>(context);
    if (!auth.checkRole('admin') && !auth.checkRole('picker')) {
      Get.offAll(Home());
    }

    return Scaffold(
      bottomNavigationBar: _bottomNavigation(),
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          _order != null ? 'Order #${_order.orderNumber}' : 'Order',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: _order == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: EdgeInsets.all(15),
              children: <Widget>[
                _scanBarcode(),
                SizedBox(
                  height: 5,
                ),
                _itemList(),
              ],
            ),
    );
  }

  Widget _scanBarcode() {
    return Container(
      width: double.infinity,
      height: 50,
      child: FlatButton(
        onPressed: () async {
          var result = await BarcodeScanner.scan();
          if (result.rawContent.length > 0) {
            bool res = await _orderService.setItemIsPicked(
              itemId: result.rawContent,
              orderId: _order.id,
              barcodeScanned: true,
              val: true,
            );

            if (res) {
              print('Item Found');
            } else {
              Get.snackbar('Item Not Found', 'Item Not Found in this Order',
                  backgroundColor: Colors.red[800], colorText: Colors.white);
              print('Item Not Found');
            }
          }
        },
        child: Text(
          'Scan Barcode',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveFlutter.of(context).fontSize(2.2)),
        ),
        color: Colors.blue[100],
        textColor: Colors.blue[900],
      ),
    );
  }

  Widget _itemList() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Text(
          'Items ( $_itemsToSelect to Select)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10,
        ),
        ..._items?.map((e) => Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              width: Get.width,
              // height: Get.width * 0.25,
              child: GestureDetector(
                onTap: e.isRemoved
                    ? null
                    : () async {
                        await Get.to(
                            PickerItemDetails(
                              cartItem: e,
                              order: _order,
                            ),
                            duration: Duration(milliseconds: 100));
                        // Get.bottomSheet(_bottomSheet(e));
                        print('hello');
                      },
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: ResponsiveFlutter.of(context).wp(15),
                          height: ResponsiveFlutter.of(context).wp(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 2,
                                  offset: Offset(1, 1))
                            ],
                            image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new CachedNetworkImageProvider(
                                  e.item.image.thumb),
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
                          width: ResponsiveFlutter.of(context).wp(2),
                        ),
                        Container(
                          width: ResponsiveFlutter.of(context).wp(60),
                          color: Colors.grey[50],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                e.item.titleEn,
                                // overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color:
                                        e.isRemoved ? Colors.red : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveFlutter.of(context)
                                        .fontSize(1.9)),
                              ),
                              e.isAvailable
                                  ? Text(
                                      e.isRemoved
                                          ? 'Removed By User'
                                          : e.item.volume,
                                      style: TextStyle(
                                          color: e.isRemoved
                                              ? Colors.pink
                                              : Colors.grey,
                                          fontSize: 16),
                                    )
                                  : Text(
                                      e.isRemoved
                                          ? 'Removed By User'
                                          : 'Out of Stock',
                                      style: TextStyle(color: Colors.pink),
                                    ),
                              e.isAvailable
                                  ? Row(
                                      children: <Widget>[
                                        Text(
                                          '${e.item.defaultPrice}',
                                          style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14),
                                        ),
                                        Text(
                                          ' x ${e.quantity}',
                                          style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          ' = ${e.total.toStringAsFixed(2)} QAR',
                                          style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  : e.isRemoved
                                      ? SizedBox()
                                      : RaisedButton(
                                          color: Colors.green,
                                          textColor: Colors.white,
                                          child: Text(' Select Alternative'),
                                          onPressed: () async {
                                            Item item =
                                                await Get.to(AlternativeItems(
                                              item: e.item,
                                              isReturnItem: true,
                                            ));

                                            if (item != null) {
                                              bool res = await _orderService
                                                  .setAlternativeItem(
                                                      order: _order,
                                                      item: item,
                                                      cartItem: e);
                                              print(res);

                                              print(item.barcode);
                                            }
                                          },
                                        ),
                            ],
                          ),
                        ),

                        IconButton(
                          splashRadius: 10,
                          icon: Icon(
                            e.isRemoved
                                ? Icons.remove_circle
                                : Icons.check_circle,
                            color: e.isPicked
                                ? e.isRemoved ? Colors.red : Colors.green[800]
                                : e.isRemoved ? Colors.red : Colors.grey[400],
                          ),
                          onPressed: e.isRemoved
                              ? null
                              : () async {
                                  print(e.id);
                                  if (e.isAvailable || e.altItem != null) {
                                    bool res =
                                        await _orderService.setItemIsPicked(
                                            orderId: _order.id,
                                            val: !e.isPicked,
                                            itemId: e.id);
                                    print(res);
                                  }
                                },
                        ),
                        // Spacer(),
                        // e.isRemoved
                        //     ? SizedBox(
                        //         width: Get.width * 0.2,
                        //       )
                        //     : Container(
                        //         width: Get.width * 0.2,
                        //         // color: Colors.green,
                        //         child: IconButton(
                        //           icon: Icon(FontAwesomeIcons.ellipsisH),
                        //           color: Colors.grey,
                        //           onPressed: () async {
                        //             await Get.to(
                        //                 PickerItemDetails(
                        //                   cartItem: e,
                        //                   order: _order,
                        //                 ),
                        //                 duration: Duration(milliseconds: 100));
                        //             // Get.bottomSheet(_bottomSheet(e));
                        //             print('hello');
                        //           },
                        //         ))
                      ],
                    ),
                    (!e.isAvailable && e.altItem != null && !e.isRemoved)
                        ? Container(
                            width: Get.width * 0.8,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.grey[300]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  e.altItem.titleEn,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                        '${e.altQuantity} x ${e.altItem.defaultPrice} QAR'),
                                    Text(
                                      '${e.altTotal} QAR',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            )),
        SizedBox(
          height: 50,
        ),
      ],
    );
  }

  Widget _bottomNavigation() {
    if (_itemsToSelect != null) {
      return Container(
        padding: EdgeInsets.all(ResponsiveFlutter.of(context).scale(10)),
        height: _itemsToSelect == 0
            ? ResponsiveFlutter.of(context).scale(150)
            : ResponsiveFlutter.of(context).scale(90),

        decoration: BoxDecoration(
            border: Border.symmetric(
                vertical: BorderSide(width: 1, color: Colors.grey[400])),
            color: Colors.grey[200],
            shape: BoxShape.rectangle
            // RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)));
            ),
        // color: Colors.green,
        child: Column(
          children: <Widget>[
            _order.confirmedTotal > 0
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Selected Total : ${_order.confirmedTotal.toStringAsFixed(2)} QAR',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize:
                              ResponsiveFlutter.of(context).fontSize(1.9)),
                    ))
                : SizedBox(),
            (_order.total != _order.confirmedTotal)
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total : ${_order.total.toStringAsFixed(2)} QAR',
                      style: TextStyle(
                          color: Colors.black,
                          decoration: _order.confirmedTotal > 0
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize:
                              ResponsiveFlutter.of(context).fontSize(1.9)),
                    ))
                : SizedBox(),
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Convenience Fee : ${_order.convenienceFee.toStringAsFixed(2)} QAR',
                  style: TextStyle(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold,
                      fontSize: ResponsiveFlutter.of(context).fontSize(1.9)),
                )),
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _order.confirmedTotal > 0
                      ? 'SubTotal : ${(_order.convenienceFee + _order.confirmedTotal).toStringAsFixed(2)} QAR'
                      : 'SubTotal : ${(_order.convenienceFee + _order.total).toStringAsFixed(2)} QAR',
                  style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveFlutter.of(context).fontSize(2)),
                )),
            _itemsToSelect == 0
                ? Center(
                    child: Container(
                    margin: EdgeInsets.only(
                        top: ResponsiveFlutter.of(context).scale(10)),
                    width: ResponsiveFlutter.of(context).wp(95),
                    height: ResponsiveFlutter.of(context).moderateScale(55),
                    child: FlatButton(
                        color: Colors.green[800],
                        textColor: Colors.white,
                        child: Text(
                          'Finalize',
                          style: TextStyle(
                              fontSize:
                                  ResponsiveFlutter.of(context).fontSize(2.5)),
                        ),
                        onPressed: _itemsToSelect == 0
                            ? (_isBusy ||
                                    _order.statusMessage ==
                                        'Customer Accepted' ||
                                    _order.statusMessage == 'Picker Updated' ||
                                    _order.statusMessage == 'Picker Confirmed')
                                ? null
                                : () async {
                                    _isBusy = true;
                                    setState(() {});
                                    await _orderService.setPickerFinalised(
                                        order: _order);

                                    Get.back();
                                  }
                            : null),
                  ))
                : SizedBox(),
          ],
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Widget _bottomSheet(CartItem item) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5), topRight: Radius.circular(5)),
      ),
      child: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Container(
            width: Get.width * 0.9,
            child: Center(
              child: Text(
                item.item.titleEn,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Divider(
            thickness: 1,
          ),
          SizedBox(
            height: 5,
          ),
          Card(
            child: ListTile(
              title: Text(item.isAvailable
                  ? 'Mark As Out of Stock'
                  : 'Mark as In Stock'),
              subtitle: Text(
                item.isAvailable ? 'In Stock' : 'Out of Stock',
                style: TextStyle(
                    color:
                        item.isAvailable ? Colors.green[800] : Colors.red[800]),
              ),
              onTap: () async {
                Get.back();
                bool res = await _orderService.setOutOfStock(
                    val: item.isAvailable, order: _order, item: item);

                print(res);
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Change Quantity'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Adjust Price'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Change Volume'),
            ),
          ),
        ],
      ),
    );
  }
}
