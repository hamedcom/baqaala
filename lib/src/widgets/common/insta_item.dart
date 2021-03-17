import 'package:baqaala/src/models/cart_item.dart';
import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/providers/cart_provider.dart';
import 'package:baqaala/src/widgets/user/alternative_items.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class InstantItem extends StatefulWidget {
  final double width;
  final double height;
  final int count;
  final Item product;
  final String storeId;
  final double elevation;
  final bool isReturnItem;
  InstantItem(
      {Key key,
      this.width,
      this.height,
      this.count,
      this.product,
      this.elevation,
      this.isReturnItem,
      this.storeId})
      : super(key: key);

  @override
  _InstantItemState createState() => _InstantItemState();
}

class _InstantItemState extends State<InstantItem>
    with TickerProviderStateMixin {
  double width;
  double height;
  int count;
  double elevation;
  CartItem cartItem;
  bool _isAvailable = true;
  bool _isreturnItem = false;

  Animation _arrowAnimation, _heartAnimation;
  AnimationController _arrowAnimationController, _heartAnimationController;

  @override
  void initState() {
    super.initState();
    _isreturnItem = widget.isReturnItem ?? false;
    print('isReturnItem $_isreturnItem');
    print(widget.storeId);
    if (widget.width != null) width = widget.width;
    if (widget.height != null) height = widget.height;
    count = widget.count ?? 0;
    elevation = count > 0 ? 3 : 3; // widget.elevation ?? 0;
    if (widget.storeId != null) {
      var data = widget.product.storeAttributes[widget.storeId];
      if (data != null) {
        _isAvailable = data['isAvailable'] ?? true;
      }
      print(data);
    }
    setState(() {});

    _heartAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _heartAnimation = Tween(begin: 35.0, end: 42.0).animate(
        CurvedAnimation(curve: Curves.ease, parent: _heartAnimationController));

    _heartAnimationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _heartAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CartProvider cart = Provider.of<CartProvider>(context);
    var rf = ResponsiveFlutter.of(context);
    if (cart.isInCart(widget.product.barcode) && !_isreturnItem) {
      if (cartItem == null) {
        cartItem = cart.getCartItem(widget.product);
        if (cartItem != null) {
          if (cartItem.isAvailable == null) {
            cartItem.isAvailable = true;
          }

          if (cartItem.isAvailable) count = cartItem.quantity;
          elevation = 3;
        }
      }
      setState(() {});
    }
    return GestureDetector(
      onTapDown: (details) {
        if (_isreturnItem) {
          Get.back(result: widget.product);
          return;
        }
        setState(() {
          elevation = 1;
        });
        Future.delayed(Duration(milliseconds: 200), () {
          if (mounted)
            setState(() {
              elevation = widget.elevation ?? 3;

              if (count > 0) {
                elevation = 3;
              } else {
                elevation = 3;
              }
              // elevation = widget.elevation ?? 3;
            });
        });
      },
      child: Card(
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: elevation,
        child: Stack(
          children: <Widget>[
            Container(
              width: rf.wp(48),
              // height: rf.scale(400),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[100],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: rf.scale(110),
                    width: rf.wp(48),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      color: Colors.grey[400],
                    ),
                    child: Stack(
                      children: <Widget>[
                        CachedNetworkImage(
                            imageUrl: widget.product.image.thumb,
                            fit: BoxFit.cover,
                            width: rf.wp(48)),
                        count > 0
                            ? Positioned(
                                top: 0,
                                left: 0,
                                child: IconButton(
                                  splashColor: Colors.transparent,
                                  color: Colors.red,
                                  icon: Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    cart.removeItem(widget.product);
                                    setState(() {
                                      count = count - 1;
                                      elevation = 1;
                                    });
                                    _heartAnimationController.forward();
                                    Future.delayed(Duration(milliseconds: 200),
                                        () {
                                      setState(() {
                                        if (count > 0) {
                                          elevation = 3;
                                        } else {
                                          elevation = 3;
                                        }
                                        // elevation = widget.elevation ?? 3;
                                      });
                                    });

                                    print(count.toString());
                                  },
                                ),
                              )
                            : SizedBox(),
                        count > 0
                            ? Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  child: Center(
                                    child: AnimatedBuilder(
                                        animation: _heartAnimation,
                                        builder: (context, child) {
                                          return Container(
                                            width: _heartAnimation.value,
                                            height: _heartAnimation.value,
                                            decoration: BoxDecoration(
                                                boxShadow: [
                                                  // BoxShadow(
                                                  //     color: Colors.grey[500],
                                                  //     spreadRadius: 2,
                                                  //     blurRadius: 3),
                                                  // BoxShadow(
                                                  //     color: Colors.grey[300],
                                                  //     spreadRadius: 1,
                                                  //     blurRadius: 3)
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Colors.amber),
                                            child: Center(
                                                child: Row(
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.baseline,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  'x',
                                                  style: TextStyle(
                                                    fontSize:
                                                        // _heartAnimation.value - 24,
                                                        11,
                                                  ),
                                                ),
                                                Text(
                                                  count.toString(),
                                                  style: TextStyle(
                                                      fontSize: count < 10
                                                          ? _heartAnimation.value -
                                                              18
                                                          // 19
                                                          : count < 99
                                                              ? _heartAnimation
                                                                      .value -
                                                                  20
                                                              : _heartAnimation
                                                                      .value -
                                                                  22,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            )),
                                          );
                                        }),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.infoCircle,
                              size: 20,
                            ),
                            color: Colors.white.withOpacity(0.3),
                            onPressed: () async {
                              showModalBottomSheet(
                                  elevation: 15,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                        builder: (context, state) {
                                      return Container(
                                        padding: EdgeInsets.all(15),
                                        height: 800,
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            CachedNetworkImage(
                                              width: Get.width,
                                              height: 200,
                                              fit: BoxFit.fitHeight,
                                              imageUrl:
                                                  widget.product.image.thumb,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              widget.product.titleEn,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            widget.product.descriptionEn != null
                                                ? Text(
                                                    widget
                                                        .product.descriptionEn,
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  )
                                                : SizedBox(),
                                            Row(
                                              children: <Widget>[
                                                FlatButton(
                                                  child: Text('+'),
                                                  onPressed: () {
                                                    cart.addItem(
                                                        widget.product);

                                                    state(() {
                                                      count++;
                                                    });
                                                  },
                                                ),
                                                Text(count.toString()),
                                                FlatButton(
                                                  child: Text('-'),
                                                  onPressed: () {
                                                    cart.removeItem(
                                                        widget.product);
                                                    state(() {
                                                      count--;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                  });
                              // Get.bottomSheet(
                              //   DraggableScrollableSheet(
                              //     minChildSize: 0.5,
                              //     initialChildSize: 0.7,
                              //     maxChildSize: 0.8,
                              //     expand: true,
                              //     builder: (context, controller) {
                              //       return Container(
                              //         padding: EdgeInsets.all(15),
                              //         width: Get.width,
                              //         decoration: BoxDecoration(
                              //             color: Colors.white,
                              //             borderRadius: BorderRadius.only(
                              //                 topLeft: Radius.circular(10),
                              //                 topRight: Radius.circular(10))),
                              //         child: Text('Details'),
                              //       );
                              //     },
                              //   ),
                              //   isDismissible: true,
                              // );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: Text(
                      widget.product.titleEn,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text('${widget.product.defaultPrice} QAR'),
                  ),
                ],
              ),
            ),
            _isAvailable
                ? SizedBox()
                : GestureDetector(
                    onTap: widget.isReturnItem
                        ? null
                        : () async {
                            print('alternatives');
                            Get.to(AlternativeItems(
                              item: widget.product,
                              storeId: widget.storeId,
                              isReturnItem: false,
                            ));
                          },
                    child: Container(
                      width: width ?? Get.width * 0.48,
                      height: height ?? 210,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5)),
                        color: Colors.black.withOpacity(0.6),
                      ),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Out Of Stock ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Click For Alternatives',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
      onTap: _isAvailable
          ? () {
              if (_isreturnItem) {
                Get.back(result: widget.product);
                return;
              }
              cart.addItem(widget.product);
              setState(() {
                count = count + 1;
              });
              _heartAnimationController.forward();

              print(count.toString());
            }
          : null,
    );
  }
}
