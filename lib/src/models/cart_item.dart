import 'package:baqaala/src/models/item.dart';

class CartItem {
  String id; // Product Id
  Item item;
  int quantity;
  double total;
  Item altItem;
  int altQuantity;
  double altTotal;
  double updatedTotal;
  String updatedVolume;
  AdditionalPrice additionalPrice;
  bool isQCApproved; // is QC Approved
  bool isPicked;
  bool isAvailable;
  bool isRemoved;

  CartItem({
    this.id,
    this.item,
    this.quantity,
    this.total,
    this.altItem,
    this.altQuantity,
    this.altTotal,
    this.updatedTotal,
    this.updatedVolume,
    this.additionalPrice,
    this.isQCApproved,
    this.isPicked,
    this.isAvailable,
    this.isRemoved,
  });

  CartItem.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    item = data["item"] != null ? Item.fromJson(data["item"]) : null;
    altItem = data["altItem"] != null ? Item.fromJson(data["altItem"]) : null;
    additionalPrice = data["additionalPrice"] != null
        ? AdditionalPrice.fromJson(data["additionalPrice"])
        : null;
    quantity = data['quantity'];
    total = data['total'];
    altQuantity = data['altQuantity'];
    altTotal = data['altTotal'];
    updatedTotal = data['updatedTotal'];
    updatedVolume = data['updatedVolume'];
    isQCApproved = data['isQCApproved'];
    isPicked = data['isPicked'] ?? false;
    isAvailable = data['isAvailable'] ?? true;
    isRemoved = data['isRemoved'] ?? false;
  }

  Map<String, dynamic> toJSON() => {
        'id': id,
        'item': item?.toJSON(),
        'quantity': quantity,
        'total': total,
        'altItem': altItem?.toJSON(),
        'altQuantity': altQuantity,
        'altTotal': altTotal,
        'updatedTotal': updatedTotal,
        'updatedVolume': updatedVolume,
        'additionalPrice': additionalPrice?.toJSON(),
        'isQCApproved': isQCApproved,
        'isPicked': isPicked,
        'isAvailable': isAvailable,
        'isRemoved': isRemoved,
      };
}
