import 'package:baqaala/src/models/cart_item.dart';
import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/models/order.dart';
import 'package:baqaala/src/services/order_service.dart';
import 'package:baqaala/src/widgets/user/alternative_items.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class PickerItemDetails extends StatefulWidget {
  final Order order;
  final CartItem cartItem;
  PickerItemDetails({Key key, this.order, this.cartItem}) : super(key: key);

  @override
  _PickerItemDetailsState createState() => _PickerItemDetailsState();
}

class _PickerItemDetailsState extends State<PickerItemDetails> {
  Order _order;
  OrderService _orderService = OrderService.instance;
  CartItem _cartItem;
  bool _isBusy = false;
  TextEditingController _volumeController = TextEditingController();
  TextEditingController _totalController = TextEditingController();
  double _total = 0;
  int _quantity = 1;
  double _updatedTotal;
  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _cartItem = widget.cartItem;
    if (_cartItem.altItem != null) {
      _quantity = _cartItem.altQuantity;
    } else {
      _quantity = _cartItem.quantity;
    }

    if (_cartItem.altItem != null) {
      _volumeController.text = _cartItem.altItem.volume.toString();
    } else {
      _volumeController.text = _cartItem.item.volume.toString();
    }

    setState(() {});
    getOrder();
  }

  void getOrder() {
    Firestore.instance
        .collection('orders')
        .document(widget.order.id)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _order = Order.fromSnapShot(doc);
        if (_order.items.length > 0) {
          _order.items.forEach((element) {
            // print(element.id);
            if (element.id == widget.cartItem.id) {
              _cartItem = element;
              if (_cartItem.altItem != null) {
                _quantity = _cartItem.altQuantity;
              } else {
                _quantity = _cartItem.quantity;
              }

              if (_cartItem.altItem != null) {
                _volumeController.text = _cartItem.altItem.volume.toString();
              } else {
                _volumeController.text = _cartItem.item.volume.toString();
              }

              // print(element.item.titleEn);
            }
          });
        }

        Future.delayed(Duration(milliseconds: 0), () {
          if (mounted) setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _bottomButton(),
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'Update Item',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: ListView(
          padding: EdgeInsets.all(10),
          children: [
            Card(
              child: ListTile(
                title: Text(_cartItem.isAvailable
                    ? 'Mark As Out of Stock'
                    : 'Mark as In Stock'),
                trailing: Switch(
                    value: _cartItem.isAvailable,
                    onChanged: _isBusy
                        ? null
                        : (val) async {
                            setState(() {
                              _isBusy = true;
                            });
                            await _orderService.setOutOfStock(
                                val: _cartItem.isAvailable,
                                order: _order,
                                item: _cartItem);
                            setState(() {
                              _isBusy = false;
                            });
                          }),
                subtitle: Text(
                  _cartItem.isAvailable ? 'In Stock' : 'Out of Stock',
                  style: TextStyle(
                      color: _cartItem.isAvailable
                          ? Colors.green[800]
                          : Colors.red[800]),
                ),
              ),
            ),
            _itemWidget(_cartItem),
            SizedBox(
              height: 10,
            ),
            _quantityRow(),
            SizedBox(
              height: 20,
            ),
            _volumeRow(),
            SizedBox(
              height: 10,
            ),
            _updatedTotalWidget(),
          ],
        ));
  }

  Widget _itemWidget(CartItem e) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      width: Get.width,
      // height: Get.width * 0.25,
      child: GestureDetector(
        onTap: () async {
          // var item = await Get.to(AlternativeItems(
          //   storeId: _order.storeId,
          //   item: _cartItem.item,
          //   subCategory: _cartItem.item.subCategory,
          //   isReturnItem: true,
          // ));
          // // Get.bottomSheet(_bottomSheet(e));
          // print(item);
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
                      image: new CachedNetworkImageProvider(e.item.image.thumb),
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
                            color: e.isRemoved ? Colors.red : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                ResponsiveFlutter.of(context).fontSize(1.9)),
                      ),
                      e.isAvailable
                          ? SizedBox()
                          : RaisedButton(
                              color: Colors.green,
                              textColor: Colors.white,
                              child: Text(' Select Alternative'),
                              onPressed: () async {
                                Item item = await Get.to(AlternativeItems(
                                  item: e.item,
                                  isReturnItem: true,
                                ));

                                if (item != null) {
                                  bool res =
                                      await _orderService.setAlternativeItem(
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
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                                e.altItem.image.thumb),
                          ),
                        ),
                        // child: CachedNetworkImage(
                        //   imageUrl: item.item.image.thumb,
                        //   width: 150,
                        //   height: 150,
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                      Container(
                        width: Get.width * 0.6,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey[300]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              e.altItem.titleEn,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _volumeRow() {
    return (_cartItem.altItem != null || _cartItem.isAvailable)
        ? Container(
            height: 50,
            width: Get.width,
            child: Row(
              children: [
                Text('Volume : '),
                Spacer(),
                Container(
                    width: Get.width * 0.3,
                    child: TextField(
                      controller: _volumeController,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      // keyboardType: TextInputType.number,
                    )),
              ],
            ),
          )
        : SizedBox();
  }

  Widget _updatedTotalWidget() {
    return (_cartItem.altItem != null || _cartItem.isAvailable)
        ? Container(
            height: 50,
            width: Get.width,
            child: Row(
              children: [
                Text('Updated Total : '),
                Spacer(),
                Container(
                    width: Get.width * 0.5,
                    child: TextField(
                      controller: _totalController,
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          suffixText: ' QAR',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      // keyboardType: TextInputType.number,
                    )),
              ],
            ),
          )
        : SizedBox();
  }

  Widget _quantityRow() {
    if (_cartItem.altItem != null) {
      _total = _cartItem.altItem.defaultPrice * _quantity;
      setState(() {});
    } else {
      _total = _cartItem.item.defaultPrice * _quantity;

      setState(() {});
    }
    return (_cartItem.altItem != null || _cartItem.isAvailable)
        ? Column(
            children: [
              Container(
                height: 50,
                width: Get.width,
                child: Row(
                  children: [
                    Text('Quantity : '),
                    Spacer(),
                    Text(_cartItem.altItem != null
                        ? ' QAR ${_cartItem.altItem.defaultPrice}    x    '
                        : ' QAR ${_cartItem.item.defaultPrice}    x    '),
                    Container(
                      padding: EdgeInsets.all(0),
                      width: 143,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      // color: Colors.grey[300],
                      child: Row(
                        children: <Widget>[
                          MaterialButton(
                            minWidth: 45,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            // color: Colors.red[100],
                            padding: EdgeInsets.all(0),
                            child: Center(
                              child: Text(
                                '-',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _quantity--;
                                if (_quantity <= 0) _quantity = 1;
                              });
                            },
                          ),
                          Container(
                            width: 45,
                            height: 30,
                            // color: Colors.white,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.all(1),
                            child: Center(
                                child: Text(
                              _quantity.toString(),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                          ),
                          MaterialButton(
                            minWidth: 45,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            // color: Colors.green[100],
                            padding: EdgeInsets.all(0),
                            child: Center(
                                child: Text('+',
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.pink))),
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total : ${_total.toStringAsFixed(2)} QAR',
                  style: TextStyle(
                      fontSize: ResponsiveFlutter.of(context).fontSize(3)),
                ),
              )
            ],
          )
        : SizedBox();
  }

  Widget _bottomButton() {
    return Container(
      height: 65,
      width: double.infinity,
      child: RaisedButton(
        color: Colors.green[100],
        textColor: Colors.green[900],
        child: Text(
          'Update',
          style: TextStyle(fontSize: 18),
        ),
        onPressed: _isBusy
            ? null
            : () async {
                setState(() {
                  _isBusy = true;
                });
                var res = await _orderService.updateCartItem(
                    order: _order,
                    item: _cartItem,
                    newQuantity: _quantity,
                    newVolume: _volumeController.text,
                    updatedTotal: double.tryParse(_totalController.text));

                setState(() {
                  _isBusy = false;
                });

                if (res) {
                  Get.back();
                }

                print('Update');
              },
      ),
    );
  }
}
