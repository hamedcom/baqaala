import 'package:baqaala/src/models/cart_item.dart';
import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  static OrderService instance = OrderService();
  final db = Firestore.instance;

  OrderService();

  Future<bool> setAlternativeItem({
    Order order,
    CartItem cartItem,
    Item item,
  }) async {
    var docRef = db.collection('orders').document(order.id);
    print(order.id);
    double ctotal = 0;
    order.items.forEach((it) {
      if (it.id == cartItem.id) {
        it.altItem = item;
        it.altQuantity = it.quantity;
        it.altTotal = it.quantity * item.defaultPrice;
        it.isPicked = true;
      }
      it.total = it.quantity * it.item.defaultPrice;

      if (it.isPicked && !it.isRemoved) {
        if (it.isAvailable) {
          ctotal = ctotal + it.total;
        } else if (it.altTotal != null) {
          ctotal = ctotal + it.altTotal;
        }
      }
    });
    order.confirmedTotal = ctotal;
    order.isOrderModified = true;

    await docRef.updateData(order.toJson());

    return true;
  }

  Future<bool> updateCartItem({
    Order order,
    CartItem item,
    int newQuantity,
    String newVolume,
    double updatedTotal,
  }) async {
    var docRef = db.collection('orders').document(order.id);
    if (updatedTotal == null) {
      updatedTotal = 0;
    }
    double ctotal = 0;
    order.items.forEach((it) {
      if (it.id == item.item.barcode) {
        if (it.altItem != null) {
          it.altQuantity = newQuantity;
        } else {
          it.quantity = newQuantity;
        }

        it.updatedVolume = newVolume;
        if (updatedTotal > 0) {
          it.updatedTotal = updatedTotal;
        }

        print(it.id);
      }

      if (!it.isRemoved) {
        if (it.altItem != null) {
          if (it.updatedTotal != null) {
            ctotal = ctotal + it.updatedTotal;
          } else {
            ctotal = ctotal + (it.altItem.defaultPrice * it.altQuantity);
          }
        } else {
          if (it.updatedTotal != null) {
            ctotal = ctotal + it.updatedTotal;
          } else {
            ctotal = ctotal + (it.item.defaultPrice * it.quantity);
          }
        }
      }
    });

    order.total = ctotal;

    await docRef.updateData(order.toJson());

    return true;

    // print(ctotal);
  }

  Future<bool> setPickerFinalised({Order order}) async {
    var docRef = db.collection('orders').document(order.id);
    String message = 'Picker Confirmed';
    if (order.isOrderModified) {
      message = 'Picker Updated';
    }
    await docRef.updateData({
      'isPickerConfirmed': true,
      'statusMessage': message,
      'pickerUpdatedAt': FieldValue.serverTimestamp()
    });
    return true;
  }

  Future<bool> setPickerUpdated({Order order}) async {
    var docRef = db.collection('orders').document(order.id);

    await docRef.updateData({'pickerUpdatedAt': FieldValue.serverTimestamp()});

    return true;
  }

  Future<bool> setOutOfStock({
    bool val,
    Order order,
    CartItem item,
  }) async {
    await db.collection('globalItems').document(item.item.barcode).updateData({
      'storeAttributes': {
        order.storeId: {
          'isAvailable': !val,
        }
      }
    });
    var docRef = db.collection('orders').document(order.id);
    double ctotal = 0;
    order.items.forEach((it) {
      if (it.id == item.id) {
        it.isAvailable = !val;
        it.isPicked = !val;
      }
      it.total = it.quantity * it.item.defaultPrice;

      if (it.isAvailable) {
        it.altItem = null;
        it.altTotal = null;
        it.altQuantity = null;
      }

      if (it.isPicked && !it.isRemoved) {
        if (it.isAvailable) {
          ctotal = ctotal + it.total;
        } else if (it.altTotal != null) {
          ctotal = ctotal + it.altTotal;
        }
      }
    });
    order.isOrderModified = true;
    order.confirmedTotal = ctotal;

    await docRef.updateData(order.toJson());
    if (val) {
      await db
          .collection('stores')
          .document(order.storeId)
          .collection('outOfStock')
          .document('items')
          .setData({
        'itemIds': FieldValue.arrayUnion([item.item.id]),
        'totalOutOfStock': FieldValue.increment(1),
      }, merge: true);

      await db
          .collection('stores')
          .document(order.storeId)
          .collection('outOfStock')
          .document('items')
          .collection('items')
          .document(item.item.id)
          .setData(item.item.toJSON(), merge: true);
    } else {
      await db
          .collection('stores')
          .document(order.storeId)
          .collection('outOfStock')
          .document('items')
          .setData({
        'itemIds': FieldValue.arrayRemove([item.item.id]),
        'totalOutOfStock': FieldValue.increment(-1),
      }, merge: true);

      await db
          .collection('stores')
          .document(order.storeId)
          .collection('outOfStock')
          .document('items')
          .collection('items')
          .document(item.item.id)
          .delete();
    }

    return true;
  }

  Future<bool> setItemAccepted({String itemId, String orderId}) async {
    var docRef = db.collection('orders').document(orderId);
    var doc = await docRef.get();
    Order order = Order.fromSnapShot(doc);
    if (order.items.length > 0) {
      bool itemFound = false;
      double ctotal = 0;
      order.items.forEach((item) {
        if (item.id == itemId) {
          item.item = item.altItem;
          item.total = item.altTotal;
          item.quantity = item.altQuantity;
          item.isPicked = true;
          item.isAvailable = true;
          item.altItem = null;
          item.altQuantity = null;
          item.altTotal = null;
          itemFound = true;
        }

        item.total = item.quantity * item.item.defaultPrice;

        if (item.isPicked && !item.isRemoved) {
          if (item.isAvailable) {
            ctotal = ctotal + item.total;
          } else if (item.altTotal != null) {
            ctotal = ctotal + item.altTotal;
          }
        }
      });
      order.confirmedTotal = ctotal;
      if (itemFound) {
        await docRef.updateData(order.toJson());
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> removeItem({
    String itemId,
    String orderId,
  }) async {
    var docRef = db.collection('orders').document(orderId);
    var doc = await docRef.get();
    Order order = Order.fromSnapShot(doc);
    if (order.items.length > 0) {
      bool itemFound = false;
      double ctotal = 0;
      order.items.forEach((item) {
        if (item.id == itemId) {
          item.isRemoved = true;
          itemFound = true;
        }

        item.total = item.quantity * item.item.defaultPrice;

        if (!item.isRemoved) {
          if (item.isAvailable) {
            ctotal = ctotal + item.total;
          } else if (item.altTotal != null) {
            ctotal = ctotal + item.altTotal;
          }
        }
      });
      order.total = ctotal;
      if (itemFound) {
        await docRef.updateData(order.toJson());
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> userAcceptOrder(String orderId) async {
    var docRef = db.collection('orders').document(orderId);
    var doc = await docRef.get();
    if (doc.exists) {
      await docRef.updateData({'statusMessage': 'Customer Accepted'});
      return true;
    } else {
      return false;
    }
  }

  Future<bool> setItemRemoved({
    String itemId,
    String orderId,
  }) async {
    var docRef = db.collection('orders').document(orderId);
    var doc = await docRef.get();
    Order order = Order.fromSnapShot(doc);
    if (order.items.length > 0) {
      bool itemFound = false;
      double ctotal = 0;
      order.items.forEach((item) {
        if (item.id == itemId) {
          item.isRemoved = true;
          item.isPicked = false;
          itemFound = true;
        }

        item.total = item.quantity * item.item.defaultPrice;

        if (item.isPicked && !item.isRemoved) {
          if (item.isAvailable) {
            ctotal = ctotal + item.total;
          } else if (item.altTotal != null) {
            ctotal = ctotal + item.altTotal;
          }
        }
      });
      order.confirmedTotal = ctotal;
      if (itemFound) {
        await docRef.updateData(order.toJson());
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> addItemToOrder({String orderId, Item item, int quantity}) async {
    var docRef = db.collection('orders').document(orderId);
    var doc = await docRef.get();
    Order order = Order.fromSnapShot(doc);
    if (order.items.length > 0) {
      bool itemFound = false;
      bool isItemRemoved = false;
      double ctotal = 0;
      order.items.forEach((it) {
        print(' Item Id : ${it.id} : Search with : ${item.barcode}');
        if (it.id == item.barcode) {
          itemFound = true;
          if (it.isRemoved) {
            it.quantity = quantity;
            it.isRemoved = false;
            it.isPicked = false;
          } else {
            it.quantity = it.quantity + quantity;
            it.isPicked = false;
          }
        }

        it.total = it.quantity * it.item.defaultPrice;
        if (!it.isRemoved) {
          if (it.isAvailable) {
            ctotal = ctotal + it.total;
          } else if (it.altTotal != null) {
            ctotal = ctotal + it.altTotal;
          }
        }
      });

      order.total = ctotal;

      if (!itemFound) {
        CartItem newItem = CartItem(
          id: item.barcode,
          item: item,
          quantity: quantity,
          isAvailable: true,
          isRemoved: false,
          total: quantity * item.defaultPrice,
        );
        order.items.add(newItem);

        ctotal = 0;

        order.items.forEach((it) {
          it.total = it.quantity * it.item.defaultPrice;
          if (!it.isRemoved) {
            if (it.isAvailable) {
              ctotal = ctotal + it.total;
            } else if (it.altTotal != null) {
              ctotal = ctotal + it.altTotal;
            }
          }
        });

        order.total = ctotal;

        print('Item Found In Order');
        if (isItemRemoved) {
          print('Item Found But Removed');
        }
        await docRef.updateData(order.toJson());
        return true;
      } else {
        await docRef.updateData(order.toJson());
        return true;
      }
    } else {
      return false;
    }
    // print('Item Added to Order');
    // return true;
  }

  Future<bool> setItemIsPicked({
    bool val,
    String orderId,
    String itemId,
    bool barcodeScanned,
  }) async {
    var docRef = db.collection('orders').document(orderId);
    var doc = await docRef.get();
    Order order = Order.fromSnapShot(doc);
    if (order.items.length > 0) {
      bool itemFound = false;
      double ctotal = 0;
      order.items.forEach((item) {
        if (item.id == itemId) {
          item.isPicked = val;
          if (barcodeScanned != null) {
            item.isAvailable = true;
          }

          itemFound = true;
        }

        item.total = item.quantity * item.item.defaultPrice;

        if (item.isPicked && !item.isRemoved) {
          if (item.isAvailable) {
            ctotal = ctotal + item.total;
          } else if (item.altTotal != null) {
            ctotal = ctotal + item.altTotal;
          }
        }
      });
      order.confirmedTotal = ctotal;
      if (itemFound) {
        await docRef.updateData(order.toJson());
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
