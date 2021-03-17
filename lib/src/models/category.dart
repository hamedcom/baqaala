import 'package:baqaala/src/models/v_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String id;
  String parentId;
  String slug;
  String nameEn;
  String nameAr;
  int itemCount;
  VImage image;

  Category({
    this.id,
    this.parentId,
    this.slug,
    this.itemCount,
    this.nameEn,
    this.nameAr,
    this.image,
  });

  factory Category.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data;
    return Category(
      id: doc.documentID,
      parentId: data['parentId'],
      itemCount: data['itemCount'] ?? 0,
      slug: data['slug'],
      nameEn: data['nameEn'],
      nameAr: data['nameAr'],
      image: data['image'] != null
          ? VImage.fromJson(Map.from(data['image']))
          : null,
    );
  }

  Category.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    parentId = data['parentId'];
    itemCount = data['itemCount'] ?? 0;
    slug = data['slug'];
    nameEn = data['nameEn'];
    nameAr = data['nameAr'];
    image =
        data['image'] != null ? VImage.fromJson(Map.from(data['image'])) : null;
  }

  Map<String, dynamic> toJSON() => {
        'id': id,
        'parentId': parentId,
        'itemCount': itemCount,
        'slug': slug,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'image': image.toJSON(),
      };
}
