import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/models/order.dart';
import 'package:baqaala/src/models/user.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/services/order_service.dart';
import 'package:baqaala/src/widgets/admin/admin_store_drivers.dart';
import 'package:baqaala/src/widgets/admin/admin_store_pickers.dart';
import 'package:baqaala/src/widgets/user/alternative_items.dart';
import 'package:baqaala/src/widgets/user/home.dart';
import 'package:baqaala/src/widgets/user/search_product_delegate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerSupportOrderDetails extends StatefulWidget {
  final Order order;
  final String orderId;
  CustomerSupportOrderDetails({Key key, this.order, this.orderId})
      : super(key: key);

  @override
  _CustomerSupportOrderDetailsState createState() =>
      _CustomerSupportOrderDetailsState();
}

class _CustomerSupportOrderDetailsState
    extends State<CustomerSupportOrderDetails> {
  Order _order;
  bool _isBusy = false;
  Color textColor;
  TextEditingController _quantityController = TextEditingController();
  OrderService _orderService = OrderService.instance;

  @override
  void initState() {
    super.initState();
    getOrder();
  }

  void getOrder() async {
    if (widget.orderId != null) {
      Firestore.instance
          .collection('orders')
          .document(widget.orderId)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          _order = Order.fromSnapShot(doc);
          setState(() {});
        }
      });
    } else if (widget.order != null) {
      _order = widget.order;
      switch (_order.statusMessage) {
        case 'Pending Confirmation':
          textColor = Colors.pink[900];
          break;
        case 'Order Confirmed':
          textColor = Colors.green[800];
          break;
        default:
          textColor = Colors.purple;
          break;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthModel auth = Provider.of<AuthModel>(context);
    if (!auth.checkRole('customer_support')) {
      if (mounted) Get.offAll(Home());
    }

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Item item = await showSearch(
                context: context, delegate: SearchProduct(isReturnItem: true));
            if (item != null) {
              var quantity = await Get.defaultDialog(
                radius: 10,
                title: item.titleEn,
                content: Container(
                  width: Get.width,
                  child: Column(
                    children: [
                      SizedBox(
                        width: Get.width,
                        height: 60,
                        child: Row(
                          children: [
                            Text('Quantity : '),
                            SizedBox(
                              width: Get.width * 0.2,
                              child: TextField(
                                controller: _quantityController,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(' x ${item.defaultPrice} QAR'),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 60,
                        width: Get.width,
                        child:
                            // FlatButton.icon(
                            //     textColor: Colors.red,
                            //     onPressed: () {
                            //       Get.back();
                            //     },
                            //     icon: Icon(Icons.cancel),
                            //     label: Text('Cancel')),
                            FlatButton.icon(
                                textColor: Colors.green,
                                onPressed: () {
                                  Get.back(result: _quantityController.text);
                                },
                                icon: Icon(Icons.check_circle),
                                label: Text('OK')),
                      )
                    ],
                  ),
                ),
              );

              int q = 1;

              if (quantity != null && quantity != '') {
                print('Quantity Selected');
                q = int.tryParse(quantity);
                var result = await _orderService.addItemToOrder(
                    orderId: _order.id, item: item, quantity: q);

                print(result);
              }
            }
          },
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            _order != null ? 'Order # ${_order?.orderNumber}' : 'Order',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: _order != null
              ? Column(
                  children: <Widget>[
                    // _timeSlot(),

                    _userCard(),

                    _order?.customer?.defaultAddress != null
                        ? _address()
                        : Text('No Address'),

                    Card(
                      child: ListTile(
                        title: Text('Time Slot'),
                        subtitle: Text(_order?.slot?.title),
                      ),
                    ),

                    SizedBox(
                      height: 5,
                    ),
                    Card(
                      child: ListTile(
                        title: Text(
                          'Status',
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),
                        subtitle: Text(
                          _order?.statusMessage,
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 5,
                    ),
                    _storeCard(),

                    SizedBox(
                      height: 5,
                    ),
                    _pickerCard(),

                    SizedBox(
                      height: 5,
                    ),
                    _driverCard(),

                    SizedBox(
                      height: 5,
                    ),

                    _itemList(),
                    SizedBox(
                      height: 10,
                    ),
                    _totalCard(),
                    SizedBox(
                      height: 10,
                    ),
                    _confirmationButtons(),
                    SizedBox(
                      height: 50,
                    ),

                    // _paymentMode(),
                  ],
                )
              : Container(
                  height: Get.height,
                  child: Center(child: CircularProgressIndicator())),
        ));
  }

  Widget _confirmationButtons() {
    return Column(
      children: [
        SizedBox(
          width: Get.width,
          height: 50,
          child: FlatButton(
            color: Colors.green[100],
            textColor: Colors.green[900],
            child: Text('Send Notification To Store/Picker'),
            onPressed: () {
              Get.rawSnackbar(
                  title: 'Success',
                  message: 'Notification Sent to Store/Picker',
                  snackPosition: SnackPosition.TOP,
                  snackStyle: SnackStyle.FLOATING,
                  margin: EdgeInsets.all(10));
            },
          ),
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          width: Get.width,
          height: 50,
          child: FlatButton(
            color: Colors.blue[100],
            textColor: Colors.blue[900],
            child: Text('Send Notification To User'),
            onPressed: () {
              Get.rawSnackbar(
                  title: 'Success',
                  message: 'Notification Sent to User',
                  snackPosition: SnackPosition.TOP,
                  snackStyle: SnackStyle.FLOATING,
                  margin: EdgeInsets.all(10));
            },
          ),
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          width: Get.width,
          height: 50,
          child: FlatButton(
            color: Colors.red[100],
            textColor: Colors.red[900],
            child: Text('Enable User to Edit for 15 Mins'),
            onPressed: () async {
              var res = await _orderService.setPickerUpdated(order: _order);
              if (res) {
                if (mounted)
                  Get.rawSnackbar(
                      title: 'Success',
                      message: 'Enabled For User to Edit Order',
                      snackPosition: SnackPosition.TOP,
                      snackStyle: SnackStyle.FLOATING,
                      margin: EdgeInsets.all(10));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _itemList() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Text(
          'Items',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10,
        ),
        ..._order?.items?.map((e) => Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              width: Get.width,
              // height: Get.width * 0.25,
              child: GestureDetector(
                onTap: e.isRemoved ? null : () async {},
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
                              !e.isRemoved
                                  ? Text(
                                      e.isRemoved
                                          ? 'Item Removed'
                                          : e.item.volume,
                                      style: TextStyle(
                                          color: e.isRemoved
                                              ? Colors.pink
                                              : Colors.grey,
                                          fontSize: 16),
                                    )
                                  : Text(
                                      e.isRemoved
                                          ? 'Item Removed'
                                          : 'Out of Stock',
                                      style: TextStyle(color: Colors.pink),
                                    ),
                              !e.isRemoved
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
                            e.isRemoved ? Icons.remove_circle : Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: e.isRemoved
                              ? null
                              : () async {
                                  var res = await Get.defaultDialog(
                                      title: 'Are You Sure?',
                                      content: Text(
                                          'Do you want to delete this Item?'),
                                      textConfirm: 'Delete',
                                      buttonColor: Colors.grey[300],
                                      confirmTextColor: Colors.red,
                                      onCancel: () {},
                                      onConfirm: () {
                                        Get.back(result: true);
                                      });
                                  print(res);
                                  if (res != null) {
                                    if (res) {
                                      var result =
                                          await _orderService.removeItem(
                                              itemId: e.id, orderId: _order.id);

                                      setState(() {});
                                    }
                                  }

                                  // if (e.isAvailable || e.altItem != null) {
                                  //   bool res =
                                  //       await _orderService.setItemIsPicked(
                                  //           orderId: _order.id,
                                  //           val: !e.isPicked,
                                  //           itemId: e.id);
                                  //   print(res);
                                  // }
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
            ))
      ],
    );
  }

  Widget _pickerCard() {
    var rf = ResponsiveFlutter.of(context);

    return _order.driver != null
        ? Card(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(rf.scale(10)),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: rf.wp(55),
                        child: Text('Picker : ' + _order.picker.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: rf.fontSize(2.2))),
                      ),
                      Text('+${_order.picker.mobile}'),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      launch(
                          'tel:${_order.picker.mobile.toString().substring(3)}');
                    },
                    icon: Icon(FontAwesomeIcons.phone,
                        color: Colors.green[800], size: rf.fontSize(3)),
                  ),
                  IconButton(
                    onPressed: () {
                      launch(
                          'https://api.whatsapp.com/send?phone=+${_order.picker.mobile}&text=Order%20%23${_order?.orderNumber}%20:');
                    },
                    icon: Icon(FontAwesomeIcons.whatsapp,
                        color: Colors.green[800], size: rf.fontSize(3.5)),
                  ),
                ],
              ),
            ),
          )
        : Card(
            child: ListTile(
              title: Text('Picker Not Assigned'),
            ),
          );
  }

  Widget _driverCard() {
    var rf = ResponsiveFlutter.of(context);

    return _order.driver != null
        ? Card(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(rf.scale(10)),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: rf.wp(55),
                        child: Text(
                          'Driver : ' + _order.driver.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: rf.fontSize(2.2)),
                        ),
                      ),
                      Text('+${_order.driver.mobile}'),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      launch(
                          'tel:${_order.driver.mobile.toString().substring(3)}');
                    },
                    icon: Icon(FontAwesomeIcons.phone,
                        color: Colors.green[800], size: rf.fontSize(3)),
                  ),
                  IconButton(
                    onPressed: () {
                      launch(
                          'https://api.whatsapp.com/send?phone=+${_order.driver.mobile}&text=Order%20%23${_order?.orderNumber}%20:');
                    },
                    icon: Icon(FontAwesomeIcons.whatsapp,
                        color: Colors.green[800], size: rf.fontSize(3.5)),
                  ),
                ],
              ),
            ),
          )
        : Card(
            child: ListTile(
              title: Text('Driver Not Assigned'),
            ),
          );
  }

  Widget _storeCard() {
    var rf = ResponsiveFlutter.of(context);
    return _order.storeManager != null
        ? Card(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(rf.scale(10)),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: rf.wp(55),
                        child: Text(
                          'Store: ' + _order.storeManager.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: rf.fontSize(2.2)),
                        ),
                      ),
                      Text('+${_order.storeManager.mobile}'),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      launch(
                          'tel:${_order.storeManager.mobile.toString().substring(3)}');
                    },
                    icon: Icon(
                      FontAwesomeIcons.phone,
                      color: Colors.green[800],
                      size: rf.fontSize(3),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      launch(
                          'https://api.whatsapp.com/send?phone=+${_order.storeManager.mobile}&text=Order%20%23${_order?.orderNumber}%20:');
                    },
                    icon: Icon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.green[800],
                      size: rf.fontSize(3.5),
                    ),
                  ),
                ],
              ),
            ),
          )
        : SizedBox(
            child:
                Text('Store " ${_order.storeName} " doesnt have store manager'),
          );
  }

  Widget _userCard() {
    var rf = ResponsiveFlutter.of(context);

    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(rf.scale(10)),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: rf.wp(50),
                  child: Text(
                    'Customer : ' + _order?.customer?.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: rf.fontSize(2.2)),
                  ),
                ),
                Text('+${_order?.customer?.mobile}'),
              ],
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                launch(
                    'tel:${_order?.customer?.mobile.toString().substring(3)}');
              },
              icon: Icon(FontAwesomeIcons.phone,
                  color: Colors.green[800], size: rf.fontSize(3)),
            ),
            IconButton(
              onPressed: () {
                launch(
                    'https://api.whatsapp.com/send?phone=+${_order?.customer?.mobile}&text=Order%20%23${_order?.orderNumber}%20:');
              },
              icon: Icon(FontAwesomeIcons.whatsapp,
                  color: Colors.green[800], size: rf.fontSize(3.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _address() {
    return GestureDetector(
      child: Container(
        width: double.infinity,
        // height: 200,
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.grey[300]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: 20,
              child: Text(
                'Street : ${_order?.customer?.defaultAddress?.streetNumber}, Building : ${_order?.customer?.defaultAddress?.building}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalCard() {
    return Container(
      padding: EdgeInsets.all(ResponsiveFlutter.of(context).scale(10)),

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
          Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total : ${_order.total.toStringAsFixed(2)} QAR',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveFlutter.of(context).fontSize(1.9)),
              )),
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
                'SubTotal : ${(_order.convenienceFee + _order.total).toStringAsFixed(2)} QAR',
                style: TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveFlutter.of(context).fontSize(2)),
              )),
        ],
      ),
    );
  }
}
