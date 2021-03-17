import 'package:baqaala/src/models/v_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreCategory {
  String id;
  String titleEn;
  String titleAr;
  VImage image;
  String slug;
  bool isActive;
  int order;
  int storeCount;

  StoreCategory({
    this.id,
    this.image,
    this.titleAr,
    this.titleEn,
    this.slug,
    this.isActive,
    this.order,
    this.storeCount,
  });

  factory StoreCategory.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data;
    return StoreCategory(
      id: doc.documentID,
      titleAr: data['titleAr'],
      titleEn: data['titleEn'],
      isActive: data['isActive'] ?? true,
      slug: data['slug'],
      storeCount: data['storeCount'] ?? 1,
      order: data['order'] ?? 1,
      image: data['image'] != null
          ? VImage.fromJson(Map.from(data['image']))
          : null,
    );
  }

  StoreCategory.fromJSON(Map<String, dynamic> data) {
    id = data['id'];
    slug = data['slug'];
    storeCount = data['storeCount'] ?? 0;
    order = data['order'] ?? 1;
    isActive = data['isActive'] ?? true;
    titleEn = data['titleEn'];
    titleAr = data['titleAr'];
    image =
        data['image'] != null ? VImage.fromJson(Map.from(data['image'])) : null;
  }

  Map<String, dynamic> toJSON() => {
        'id': id,
        'titleEn': titleEn,
        'titleAr': titleAr,
        'storeCount': storeCount,
        'order': order,
        'isActive': isActive,
        'slug': slug,
        'image': image.toJSON(),
      };
}
