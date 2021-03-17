import 'package:after_layout/after_layout.dart';
import 'package:baqaala/src/models/store.dart';
import 'package:baqaala/src/models/store_category.dart';
import 'package:baqaala/src/providers/cart_provider.dart';
import 'package:baqaala/src/widgets/user/user_products.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:slugify2/slugify.dart';

class UserSelectCategory extends StatefulWidget {
  final Store store;
  final String storeId;
  final StoreCategory storeType;

  UserSelectCategory({Key key, this.store, this.storeType, this.storeId})
      : super(key: key);

  @override
  _UserSelectCategoryState createState() => _UserSelectCategoryState();
}

class _UserSelectCategoryState extends State<UserSelectCategory>
    with AfterLayoutMixin<UserSelectCategory> {
  List<String> categories = [
    'Baby Products',
    'Berries Grapes',
    'Beverages',
    'Breakfast',
    'Canned Items',
    'Cooking And Baking',
    'Cupboard Items',
    'Dairy And Eggs',
    'Dessert',
    'Exotics',
    'Family Pack',
    'Frozen Food',
    'Fruits And Vegetables',
    'General',
    'Honey',
    'Household',
    'Indian Vegetables',
    'Organic Food Products',
    'Packed Vegetables',
    'Personal Care',
    'Pet Food',
    'Rice',
    'Snacks',
    'Superfoods'
  ];
  bool isStoreIdSet = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final CartProvider cart = Provider.of<CartProvider>(context);
    if (!isStoreIdSet) {
      cart.setStoreId(widget.storeId);
      setState(() {
        isStoreIdSet = true;
      });
    }

    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'Select Category',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: GridView.count(
          crossAxisCount: 3,
          children: List.generate(
              categories.length, (index) => _categoryTile(categories[index])),
        ));
  }

  Widget _categoryTile(String cat) {
    Slugify slugify = Slugify();
    String slug = slugify.slugify(cat);
    String imagePath = "assets/categories/$slug.png";
    print(imagePath);
    return GestureDetector(
      onTap: () {
        print(slug);
        Get.to(UserProducts(
          storeId: widget.storeId,
          category: cat,
        ));
      },
      child: Container(
        width: Get.width * .3,
        margin: EdgeInsets.all(5),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey[300], blurRadius: 1, offset: Offset(1, 1))
          ],
          border: Border.all(
              width: 1,
              color:
                  Colors.grey[400] //                   <--- border width here
              ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: Get.width * .15,
              height: Get.width * .15,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: Get.width * .25,
              child: Center(
                child: Text(
                  cat,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    Get.to(UserProducts(
      storeId: widget.storeId,
    ));
  }
}
