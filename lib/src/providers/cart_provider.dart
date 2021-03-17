import 'dart:async';
import 'dart:convert';

import 'package:baqaala/src/models/cart_item.dart';
import 'package:baqaala/src/models/item.dart';
import 'package:baqaala/src/models/order.dart';
import 'package:baqaala/src/models/slot.dart';
import 'package:baqaala/src/models/store.dart';
import 'package:baqaala/src/models/store_category.dart';
import 'package:baqaala/src/models/user.dart';
import 'package:baqaala/src/providers/base_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CartProvider extends BaseProvider {
  // List<Item> _items = [];
  Firestore _db = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  static CartProvider instance = CartProvider();
  Map<String, CartItem> _items = {};
  Map<String, CartItem> _itemsFromJson = {};
  int _totalItems = 0;
  Store _store;
  StoreCategory _storeCategory;
  String _storeId;
  String _paymentMode;
  List<String> _outOfStockItems = [];

  List<Order> _orders = [];

  List<Slot> _slots = [];
  Slot _selectedSlot;

  Slot get selectedSlot => _selectedSlot;
  String get paymentMode => _paymentMode;
  List<Slot> get slots => _slots;
  List<Order> get orders => _orders;
  List<String> get outOfStockItems => _outOfStockItems;

  void setSelectedSlot(Slot slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  void clearAll() {
    _items = {};
    _itemsFromJson = {};
    _totalItems = 0;
    _store = null;
    _storeCategory = null;
    _storeId = null;
    _paymentMode = null;
    _orders = [];
    _slots = [];
    _selectedSlot = null;

    notifyListeners();
  }

  void setPaymentMode(String mode) {
    _paymentMode = mode;
    notifyListeners();
  }

  CartProvider() {
    getOrders();
  }

  void getOutOfStockItems() async {
    if (_storeId == null) {
      return;
    } else {
      _db
          .collection('stores')
          .document(storeId)
          .collection('outOfStock')
          .document('items')
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          _outOfStockItems =
              doc['itemIds'] != null ? List<String>.from(doc['itemIds']) : [];
          print('OutofStock Items');
          print(_outOfStockItems);
          // notifyListeners();
        }
      });
    }
  }

  void getOrders() async {
    if (_user == null) {
      _user = await _auth.currentUser();
      if (_user == null) return;
    }
    clearAll();

    _db
        .collection('orders')
        .where('customerId', isEqualTo: _user.uid)
        .where('orderStatus', isEqualTo: 'Pending')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.documents.length > 0) {
        _orders = [];
        snapshot.documents.forEach((doc) {
          _orders.add(Order.fromSnapShot(doc));
        });
        notifyListeners();
        print('Has Orders');
      } else {
        _orders = [];
        notifyListeners();
      }
    });
  }

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  void setStoreId(String id) async {
    if (_user == null) {
      _user = await _auth.currentUser();
      notifyListeners();
    }

    _storeId = id;
    _items = {};
    _totalItems = 0;
    getCart();
    var doc = await _db.collection('stores').document(id).get();
    if (doc.exists) {
      _store = Store.fromSnapShot(doc);
      print(_store.storeName);

      notifyListeners();
    }
    getOutOfStockItems();

    getSlots();

    setBusy(false);
  }

  List<CartItem> get cartItems {
    List<CartItem> ci = [];
    _items.forEach((key, value) {
      ci.add(value);
    });
    return ci;
  }

  String get storeId => _storeId;

  void getCart() async {
    if (_user == null) {
      _user = await _auth.currentUser();
      notifyListeners();
    } else {
      var data = await _db
          .collection('users')
          .document(_user.uid)
          .collection('carts')
          .document(_storeId)
          .get();

      if (data.exists) {
        List<dynamic> i = jsonDecode(data.data['cart']);

        if (i.length > 0) {
          _totalItems = 0;
          i.forEach((element) {
            CartItem item = CartItem.fromJson(element);
            if (item.isAvailable == null) {
              item.isAvailable = true;
            }
            if (item.isAvailable) {
              _itemsFromJson.putIfAbsent(
                item.item.barcode,
                () => item,
              );
              _totalItems += item.quantity;
              print(item.item.barcode);
            }
          });
          print(_itemsFromJson);

          // if (_items == null) {
          if (_itemsFromJson != null) {
            _items = _itemsFromJson;
            notifyListeners();
          }
          // }
        }
      }
    }
  }

  Future<bool> saveOrder(User user) async {
    setBusy(true);
    List<CartItem> cartItems = [];
    _items.forEach((key, value) {
      cartItems.add(value);
    });
    Order order = Order(
      slot: _selectedSlot,
      storeId: _storeId,
      storeManager: store.storeManager,
      customer: user,
      address: user.defaultAddress,
      customerId: user.uid,
      items: cartItems,
      total: totalAmount,
      storeCode: store.storeCode,
      storeName: store.storeName,
      totalItems: _totalItems,
      createdAt: DateTime.now(),
      orderStatus: 'Pending',
      paymentMethod: _paymentMode,
      orderNumber: store.storeCode + 'T000001',
      status: OrderStatus.waiting_for_store_to_accept.index,
      statusMessage: 'Pending Confirmation',
    );
    try {
      var doc = await _db.collection('orders').add(order.toJson());
      if (doc != null) {
        _items = {};
        _totalItems = 0;
        _selectedSlot = null;
        _paymentMode = null;
        await _db
            .collection('users')
            .document(user.uid)
            .collection('carts')
            .document(storeId)
            .delete();
        setBusy(false);
        notifyListeners();
      }
      return true;
    } catch (e) {
      setBusy(false);
      print(e);
      return false;
    }
  }

  void getSlots() async {
    _db
        .collection('stores')
        .document(_storeId)
        .collection('slots')
        .orderBy('startTime', descending: false)
        .snapshots()
        .listen((event) {
      if (event.documents.length > 0) {
        _slots = [];
        event.documents.forEach((element) {
          Slot slot = Slot.fromSnapShot(element);
          if (slot.isEnable) {
            List<String> time = slot.closeTime.split(':');

            // TimeOfDay disableTime =
            //     TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]));
            DateTime currentTime = DateTime.now();
            DateTime disableTime = DateTime(currentTime.year, currentTime.month,
                currentTime.day, int.parse(time[0]), int.parse(time[1]));

            if (disableTime.isAfter(currentTime)) {
              // print(slot.title);
              _slots.add(slot);
            }
          }
        });
        notifyListeners();
        checkSlots();
      }
    });
  }

  void checkSlots() {
    print(_slots.length);
    // Timer.periodic(Duration(minutes: 1), (timer) {
    List<Slot> newSlots = [];
    _slots.forEach((slot) {
      List<String> time = slot.closeTime.split(':');

      DateTime currentTime = DateTime.now();
      DateTime disableTime = DateTime(currentTime.year, currentTime.month,
          currentTime.day, int.parse(time[0]), int.parse(time[1]));

      String today = DateFormat('EEEE').format(currentTime);

      if (slot.days.contains(today)) {
        if (disableTime.isAfter(currentTime)) {
          print(slot.title);
          newSlots.add(slot);
        }
      }
    });
    _slots = newSlots;
    notifyListeners();
    // });
  }

  void updateCart() async {
    if (_user == null) {
      _user = await _auth.currentUser();
      notifyListeners();
    } else {
      try {
        // Map<String, dynamic> itms = {};
        // items.forEach((key, value) {
        //   itms.addAll(value.toJSON());
        // });
        var itms = [];
        items.forEach((key, value) {
          itms.add(value.toJSON());
        });
        print('hello');

        var it = jsonEncode(itms);

        // print(it);

        await _db
            .collection('users')
            .document(_user.uid)
            .collection('carts')
            .document(_storeId)
            .setData({'cart': it});
      } catch (e) {
        print(e);
      }
    }

    // getCart();
  }

  Store get store => _store;
  StoreCategory get storeCategory => _storeCategory;

  int get totalItem => _totalItems;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      // if (cartItem.isAvailable)
      total += cartItem.item.defaultPrice * cartItem.quantity;
    });
    return total;
  }

  void addItem(Item item) {
    if (_items.containsKey(item.barcode)) {
      _items.update(
          item.barcode,
          (value) => CartItem(
                id: value.id,
                item: value.item,
                quantity: value.quantity + 1,
                total: value.total + item.defaultPrice,
              ));
    } else {
      _items.putIfAbsent(
        item.barcode,
        () => CartItem(
          id: item.barcode,
          item: item,
          quantity: 1,
          total: item.defaultPrice,
        ),
      );
    }

    updateCart();
    _totalItems++;
    print(_items);
    print('Total : $totalAmount');

    notifyListeners();
  }

  bool isInCart(String id) {
    return _items.containsKey(id);
  }

  CartItem getCartItem(Item item) {
    if (!_items.containsKey(item.barcode)) {
      return null;
    } else {
      if (_storeId != null) {
        var data = item.storeAttributes[_storeId];
        if (data != null) {
          bool isAvailable = data['isAvailable'];
          if (!isAvailable) {
            print('Remove Item From Cart : ${_items[item.barcode].quantity}');
            removeOutOfStockItem(item);
          }
          print('Product available $isAvailable');
        }
      }
      return _items[item.barcode];
    }
  }

  // void removeItem(String id) {
  //   _items.remove(id);
  //   notifyListeners();
  // }

  void removeOutOfStockItem(Item item) {
    if (_items.containsKey(item.barcode)) {
      _totalItems = _totalItems - _items[item.barcode].quantity;
      _items.remove(item.barcode);

      updateCart();
    }
  }

  void removeItem(Item item) {
    if (!_items.containsKey(item.barcode)) {
      return;
    }

    if (_items[item.barcode].quantity > 1) {
      _items.update(
        item.barcode,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          item: existingCartItem.item,
          total: existingCartItem.total - item.defaultPrice,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(item.barcode);
    }

    updateCart();
    _totalItems--;
    print(_items);
    print('Total : $totalAmount');
    notifyListeners();
  }
}
