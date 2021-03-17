import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/providers/cart_provider.dart';
import 'package:baqaala/src/providers/wallet_provider.dart';
import 'package:baqaala/src/widgets/admin/admin_home.dart';
import 'package:baqaala/src/widgets/auth/login.dart';
import 'package:baqaala/src/widgets/auth/verify_mobile.dart';
import 'package:baqaala/src/widgets/customer_support/customer_support_home.dart';
import 'package:baqaala/src/widgets/driver/driver_home.dart';
import 'package:baqaala/src/widgets/picker/picker_home.dart';
import 'package:baqaala/src/widgets/store_manager/store_console.dart';
import 'package:baqaala/src/widgets/user/contact_us.dart';
import 'package:baqaala/src/widgets/user/favourites.dart';
import 'package:baqaala/src/widgets/user/orders.dart';
import 'package:baqaala/src/widgets/user/suggest_item.dart';
import 'package:baqaala/src/widgets/user/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class UserSideMenu extends StatelessWidget {
  const UserSideMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final AuthModel auth = Provider.of<AuthModel>(context);
    final CartProvider cart = Provider.of<CartProvider>(context);
    final WalletProvider wallet = Provider.of<WalletProvider>(context);
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/bg.jpg'),
              fit: BoxFit.fitHeight,
              alignment: Alignment.center)),
      child: ListView(children: <Widget>[
        auth.fUser == null
            ? SizedBox(
                height: 200,
              )
            : Center(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      // generateBluredImage(auth.fUser.profilePicture),
                      _profileImage(auth.fUser.displayPicture, size),

                      Padding(
                        padding: EdgeInsets.only(top: 10, left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              auth.fUser.name,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Color(0xFF323643),
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            (auth.fUser.status == 'verified' ||
                                    auth.fUser.status == 'active')
                                ? Icon(
                                    Icons.verified_user,
                                    size: 17,
                                    color: Colors.green[800],
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '+${auth.fUser.mobile.toString()}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            (auth.fUser.status == 'unverified')
                                ? FilterChip(
                                    backgroundColor:
                                        Colors.orangeAccent.withOpacity(0.5),
                                    label: Text(
                                      'Not Verified',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onSelected: (bool) {
                                      Get.back();

                                      Get.to(VerifyMobile());
                                      return false;
                                    },
                                  )
                                // : (auth.fUser.status == 'verified' ||
                                //         auth.fUser.status == 'active')
                                //     ? FilterChip(
                                //         backgroundColor:
                                //             Colors.green.withOpacity(0.5),
                                //         label: Text('Active'),
                                //         onSelected: (bool) {},
                                //       )
                                : SizedBox(
                                    height: 10,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        Divider(),
        _roleLink(auth),

        ListTile(
          leading: Icon(
            Icons.shopping_cart,
            color: Colors.blueGrey[300],
            size: 30,
          ),
          title: Text(
            'My Orders',
            style: TextStyle(fontSize: 18, color: Color(0xFF323643)),
          ),
          onTap: () {
            Get.back();
            auth.fUser == null ? Get.to(Login()) : Get.to(UserOrders());
          },
        ),
        ListTile(
          leading: Icon(
            Icons.credit_card,
            color: Colors.blueGrey[300],
            size: 30,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wallet',
                style: TextStyle(fontSize: 18, color: Color(0xFF323643)),
              ),
              wallet.isFetching
                  ? SpinKitThreeBounce(color: Colors.orange, size: 13)
                  : Text(
                      '${wallet.balance.toStringAsFixed(2)} QAR',
                      style: TextStyle(fontSize: 16, color: Colors.green[600]),
                    ),
            ],
          ),
          onTap: () {
            Get.back();

            auth.fUser == null ? Get.to(Login()) : Get.to(Wallet());
          },
        ),
        ListTile(
          leading: Icon(
            Icons.favorite,
            color: Colors.blueGrey[300],
            size: 30,
          ),
          title: Text(
            'Favourites',
            style: TextStyle(fontSize: 18, color: Color(0xFF323643)),
          ),
          onTap: () {
            Get.back();

            auth.fUser == null ? Get.to(Login()) : Get.to(UserFavourites());
          },
        ),
        ListTile(
          leading: Icon(
            Icons.image,
            color: Colors.blueGrey[300],
            size: 30,
          ),
          title: Text(
            'Suggest an Item',
            style: TextStyle(fontSize: 18, color: Color(0xFF323643)),
          ),
          onTap: () {
            Get.back();

            auth.fUser == null ? Get.to(Login()) : Get.to(UserSuggestItem());
          },
        ),
        ListTile(
          leading: Icon(
            Icons.call,
            color: Colors.blueGrey[300],
            size: 30,
          ),
          title: Text(
            'Contact Us',
            style: TextStyle(fontSize: 18, color: Color(0xFF323643)),
          ),
          onTap: () {
            Get.back();

            auth.fUser == null ? Get.to(Login()) : Get.to(UserContactUs());
          },
        ),
        ListTile(
          leading: Icon(
            Icons.share,
            color: Colors.blueGrey[300],
            size: 30,
          ),
          title: Text(
            'Share',
            style: TextStyle(fontSize: 18, color: Color(0xFF323643)),
          ),
          onTap: () {
            Get.back();
            Share.share(
                'Try Baqaala app for delivery in Qatar! You can download the app from \nwww.baqaala.com');
          },
        ),
        // ListTile(
        //   leading: Icon(
        //     Icons.my_location,
        //     color: Colors.blueGrey[300],
        //     size: 30,
        //   ),
        //   title: Text(
        //     'My Addresses',
        //     style: TextStyle(fontSize: 18, color: Color(0xFF323643)),
        //   ),
        //   onTap: () {
        //     Get.back();

        //      auth.fUser == null ? Get.to(Login()) : Get.to(page)
        //   },
        // ),
        Divider(),
        // ListTile(
        //   leading: Icon(
        //     Icons.settings,
        //     color: Colors.blueGrey[300],
        //     size: 30,
        //   ),
        //   title: Text(
        //     'Settings',
        //     style: TextStyle(fontSize: 18, color: Color(0xFF323643)),
        //   ),
        //   onTap: () {
        //     Get.back();
        //   },
        // ),
        ListTile(
          leading: Icon(
            auth.fUser == null ? Icons.lock : Icons.exit_to_app,
            color: Colors.blueGrey[300],
            size: 30,
          ),
          title: Text(
            auth.fUser == null ? 'Login' : 'Logout',
            style: TextStyle(fontSize: 18, color: Color(0xFF323643)),
          ),
          onTap: () async {
            Get.back();
            if (auth.fUser == null) {
              Get.to(Login());
            } else {
              await auth.signOut();
              cart.clearAll();
              Get.offAll(Login());
            }
          },
        ),
      ]),
    );
  }

  Widget generateLink({String title, Widget page}) {
    return ListTile(
      leading: Icon(
        Icons.exit_to_app,
        color: Colors.blueGrey[300],
        size: 30,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 18, color: Color(0xFF323643)),
      ),
      onTap: () {
        // Get.back();
        Get.offAll(page);
      },
    );
  }

  Widget _roleLink(AuthModel auth) {
    // final AuthModel auth = Provider.of<AuthModel>(context);
    if (auth.checkRole('admin')) {
      return generateLink(title: 'Admin Console', page: AdminHome());
    } else if (auth.checkRole('manager')) {
      return generateLink(title: 'Manager Console', page: AdminHome());
    } else if (auth.checkRole('store_manager')) {
      return generateLink(title: 'Store Console', page: StoreConsole());
    } else if (auth.checkRole('picker')) {
      return generateLink(title: 'Picker Console', page: PickerHome());
    } else if (auth.checkRole('driver')) {
      return generateLink(title: 'Driver Console', page: DriverHome());
    } else if (auth.checkRole('customer_support')) {
      return generateLink(
          title: 'Support Console', page: CustomerSupportHome());
    } else if (auth.checkRole('qc')) {
      return generateLink(title: 'Quality Console', page: AdminHome());
    } else if (auth.checkRole('investor')) {
      return generateLink(title: 'Investor Console', page: AdminHome());
    } else
      return SizedBox();
  }

  Widget _profileImage(String imagePath, Size size) {
    // String image = imagePath ?? Assets.defaultProfilePic;
    return InkWell(
      onTap: () {
        print(imagePath);
        // print('Image');
      },
      child: Stack(
        children: [
          // (imagePath != null)
          //     ? ClipRRect(
          //         borderRadius: BorderRadius.circular(100),
          //         child: CachedNetworkImage(
          //           fadeInDuration: Duration(milliseconds: 100),
          //           imageUrl: imagePath,
          //           width: size.width * 0.2,
          //           height: size.width * 0.2,
          //           fit: BoxFit.contain,
          //         ),
          //       ) :
          Image.asset(
            'assets/images/default_profile_pic.png',
            width: size.width * 0.2,
            height: size.width * 0.2,
            fit: BoxFit.contain,
          ),
          // Positioned(
          //   bottom: 0,
          //   right: 0,
          //   child: Icon(
          //     Icons.camera_alt,
          //     color: Colors.blueGrey,
          //   ),
          // ),
        ],
      ),
    );
  }
}
