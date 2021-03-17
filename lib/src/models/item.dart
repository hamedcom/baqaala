import 'package:cloud_firestore/cloud_firestore.dart';

import 'v_image.dart';

class Item {
  String id;
  String barcode; // barcode or unique productid
  String sku; // stock keeping unit
  String titleEn;
  String titleAr;
  String descriptionEn;
  String descriptionAr;
  List<String> categories;
  List<String> categoryIds;
  List<String> images;
  List<String> thumbs;
  String subCategory;
  String subCategoryId;
  VImage image; // item images
  double costPrice;
  double defaultPrice;
  double discountPrice;
  String volume; // 5 kg or 2 lt or 500 grams
  int quantity; // available quantity
  List<String> tags;
  List<AdditionalPrice> additionalPrices;
  List<AdditionalPrice> customPrices;
  bool isMultiSelectAdditionalPrices;
  bool isMultiSelectCustomPrices;
  List<String>
      availableStores; // this is for global search product available in multiple stores
  Map<String, dynamic> storeAttributes; // storeId , attr

  Item({
    this.id,
    this.barcode,
    this.sku,
    this.titleEn,
    this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    this.categories,
    this.categoryIds,
    this.subCategory,
    this.subCategoryId,
    this.image,
    this.images,
    this.thumbs,
    this.costPrice,
    this.defaultPrice,
    this.volume,
    this.quantity,
    this.tags,
    this.discountPrice,
    this.additionalPrices,
    this.customPrices,
    this.isMultiSelectAdditionalPrices,
    this.isMultiSelectCustomPrices,
    this.availableStores,
    this.storeAttributes,
  });

  factory Item.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data;
    return Item(
      id: doc.documentID,
      barcode: data["barcode"],
      sku: data["sku"],
      titleEn: data["titleEn"],
      titleAr: data["titleAr"],
      descriptionEn: data["descriptionEn"],
      descriptionAr: data["descriptionAr"],
      categories: data["categories"] != null
          ? List<String>.from(data['categories'])
          : [],
      categoryIds: data["categoryIds"] != null
          ? List<String>.from(data['categoryIds'])
          : [],
      images: data["images"] != null ? List<String>.from(data['images']) : [],
      thumbs: data["thumbs"] != null ? List<String>.from(data['thumbs']) : [],
      subCategory: data["subCategory"],
      subCategoryId: data["subCategoryId"],
      image: data["image"] != null ? VImage.fromJson(data["image"]) : null,
      costPrice: data["costPrice"],
      defaultPrice: data["defaultPrice"],
      volume: data["volume"],
      quantity: data["quantity"],
      tags: data["tags"] != null ? List<String>.from(data['tags']) : [],
      discountPrice: data["discountPrice"],
      additionalPrices: data["additionalPrices"],
      customPrices: data["customPrices"],
      isMultiSelectAdditionalPrices: data["isMultiSelectAdditionalPrices"],
      isMultiSelectCustomPrices: data["isMultiSelectCustomPrices"],
      availableStores: data["availableStores"] != null
          ? List<String>.from(data['availableStores'])
          : [],
      storeAttributes: data["storeAttributes"] != null
          ? Map.from(data['storeAttributes'])
          : {},
    );
  }

  Item.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    barcode = data["barcode"];
    sku = data["sku"];
    titleEn = data["titleEn"];
    titleAr = data["titleAr"];
    descriptionEn = data["descriptionEn"];
    descriptionAr = data["descriptionAr"];
    categories =
        data["categories"] != null ? List<String>.from(data['categories']) : [];
    categoryIds = data["categoryIds"] != null
        ? List<String>.from(data['categoryIds'])
        : [];
    images = data["images"] != null ? List<String>.from(data['images']) : [];
    thumbs = data["thumbs"] != null ? List<String>.from(data['thumbs']) : [];
    subCategory = data["subCategory"];
    subCategoryId = data["subCategoryId"];
    image = data["image"] != null ? VImage.fromJson(data["image"]) : null;
    costPrice = data["costPrice"]?.toDouble();
    defaultPrice = data["defaultPrice"]?.toDouble();
    volume = data["volume"];
    quantity = data["quantity"];
    tags = data["tags"] != null ? List<String>.from(data['tags']) : [];
    discountPrice = data["discountPrice"]?.toDouble();
    additionalPrices = data["additionalPrices"];
    customPrices = data["customPrices"];
    isMultiSelectAdditionalPrices = data["isMultiSelectAdditionalPrices"];
    isMultiSelectCustomPrices = data["isMultiSelectCustomPrices"];
    availableStores = data["availableStores"] != null
        ? List<String>.from(data['availableStores'])
        : [];
    storeAttributes = data["storeAttributes"] != null
        ? Map.from(data['storeAttributes'])
        : {};
  }

  Map<String, dynamic> toJSON() => {
        'id': id,
        'barcode': barcode,
        'sku': sku,
        'titleEn': titleEn,
        'titleAr': titleAr,
        'descriptionEn': descriptionEn,
        'descriptionAr': descriptionAr,
        'categories': categories,
        'thumbs': thumbs,
        'images': images,
        'categoryIds': categoryIds,
        'subCategory': subCategory,
        'subCategoryId': subCategoryId,
        'image': image?.toJSON(),
        'costPrice': costPrice,
        'defaultPrice': defaultPrice,
        'volume': volume,
        'quantity': quantity,
        'tags': tags,
        'discountPrice': discountPrice,
        'additionalPrices': additionalPrices,
        'customPrices': customPrices,
        'isMultiSelectAdditionalPrices': isMultiSelectAdditionalPrices,
        'isMultiSelectCustomPrices': isMultiSelectCustomPrices,
        'availableStores': availableStores,
        'storeAttributes': storeAttributes,
      };
}

class StoreAttribute {
  bool isAvailable;
  double costPrice;
  double defaultPrice;
  double discountPrice;

  StoreAttribute({
    this.isAvailable,
    this.costPrice,
    this.defaultPrice,
    this.discountPrice,
  });

  StoreAttribute.fromJson(Map<dynamic, dynamic> data) {
    isAvailable = data['isAvailable'] ?? true;
    costPrice = data['costPrice'] ?? 0;
    defaultPrice = data['defaultPrice'] ?? 0;
    discountPrice = data['discountPrice'] ?? 0;
  }

  Map<String, dynamic> toJSON() => {
        'isAvailable': isAvailable,
        'costPrice': costPrice,
        'defaultPrice': defaultPrice,
        'discountPrice': discountPrice,
      };
}

class AdditionalPrice {
  String titleEn;
  String titleAr;
  double price = 0;
  double discount = 0;

  AdditionalPrice({
    this.titleAr,
    this.titleEn,
    this.price,
    this.discount,
  });

  AdditionalPrice.fromJson(Map<dynamic, dynamic> data) {
    titleEn = data['titleEn'];
    titleAr = data['titleAr'];
    price = data['price'] ?? 0;
    discount = data['discount'] ?? 0;
  }

  Map<String, dynamic> toJSON() => {
        'titleEn': titleEn,
        'titleAr': titleAr,
        'price': price,
        'discount': discount,
      };
}
