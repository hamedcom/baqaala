import 'package:baqaala/src/common/assets.dart';
import 'package:baqaala/src/models/store.dart';
import 'package:baqaala/src/models/user.dart';
import 'package:baqaala/src/widgets/admin/admin_user_select.dart';
import 'package:baqaala/src/widgets/admin/user_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminStorePickers extends StatefulWidget {
  final String storeId;
  final bool isSelectPicker;
  AdminStorePickers({Key key, this.storeId, this.isSelectPicker})
      : super(key: key);

  @override
  _AdminStorePickersState createState() => _AdminStorePickersState();
}

class _AdminStorePickersState extends State<AdminStorePickers> {
  ScrollController listScrollController;
  DocumentSnapshot _lastVisibe;
  bool _isLoading;
  List<DocumentSnapshot> _data = List<DocumentSnapshot>();
  Firestore _db = Firestore.instance;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    listScrollController = ScrollController();
    listScrollController.addListener(_scrollListener);
    _isLoading = true;
    _getData();
    super.initState();
  }

  Future<Null> _getData() async {
    QuerySnapshot data;
    if (_lastVisibe == null) {
      data = await _db
          .collection('stores')
          .document(widget.storeId)
          .collection('pickers')
          .orderBy('name', descending: true)
          .limit(10)
          .getDocuments();
    } else {
      data = await _db
          .collection('stores')
          .document(widget.storeId)
          .collection('pickers')
          .orderBy('name', descending: true)
          .startAfter([_lastVisibe['name']])
          .limit(10)
          .getDocuments();
    }

    if (data != null && data.documents.length > 0) {
      _lastVisibe = data.documents[data.documents.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _data.addAll(data.documents);
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print('No Pickers');
      scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: Text('No More Pickers'),
      ));
    }
    return null;
  }

  _scrollListener() {
    print(listScrollController.offset);
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _isLoading = true;
      });
      _getData();
      // print('Fetching New Data...');
    }
  }

  @override
  void dispose() {
    listScrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        floatingActionButton: FloatingActionButton(
          child: Icon(FontAwesomeIcons.plus),
          onPressed: () async {
            User picker = await Get.to(AdminUserSelect(
              role: 'picker',
            ));

            if (picker != null) {
              Firestore.instance
                  .collection('stores')
                  .document(widget.storeId)
                  .collection('pickers')
                  .document(picker.uid)
                  .setData(picker.toJSON(), merge: true)
                  .then((value) {
                _getData();
                Firestore.instance
                    .collection('stores')
                    .document(widget.storeId)
                    .updateData({
                  'pickerIds': FieldValue.arrayUnion([picker.uid])
                });
                Firestore.instance
                    .collection('users')
                    .document(picker.uid)
                    .updateData({
                  'storeIds': FieldValue.arrayUnion([widget.storeId]),
                  'storeId': widget.storeId,
                });
              }).catchError((onError) {});
            }
            print(picker);
          },
        ),
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                size: 30,
              ),
              onPressed: () async {
                await showSearch(
                    context: context, delegate: UserSearch(widget.storeId));
              },
            ),
          ],
          brightness: Brightness.light,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.blue[900]),
          title: Text('Pickers',
              style: TextStyle(
                color: Colors.black,
              )),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _isLoading = false;
              _data.clear();
              _lastVisibe = null;
            });

            await _getData();
          },
          child: ListView.builder(
              controller: listScrollController,
              itemCount: _data.length + 1,
              itemBuilder: (_, int index) {
                if (index < _data.length) {
                  final DocumentSnapshot document = _data[index];
                  User _truckProvider = User.fromSnapShot(document);
                  return _providerCard(_truckProvider, context);
                }
                return Center(
                    child: new Opacity(
                  opacity: _isLoading ? 1.0 : 0.0,
                  child: new SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: new CircularProgressIndicator()),
                )

                    // children: userList(snapshot, context),
                    );
              }),
        ));
  }

  List<Widget> userList(AsyncSnapshot snapshot, BuildContext context) {
    User _truckProvider;
    return snapshot.data.documents.map<Widget>((document) {
      _truckProvider = User.fromSnapShot(document);
      return _providerCard(_truckProvider, context);
    }).toList();
  }

  Widget _providerCard(User provider, BuildContext context) {
    String providerType = 'User';
    final timeFormat = DateFormat("dd-MMM-yy hh:mm a");

    if (provider.roles['manager'] ?? false) {
      providerType = 'Manager';
    }
    if (provider.roles['admin'] ?? false) {
      providerType = 'Admin';
    }
    if (provider.roles['store_manager'] ?? false) {
      providerType = 'Store Manager';
    }
    if (provider.roles['driver'] ?? false) {
      providerType = 'Driver';
    }
    if (provider.roles['picker'] ?? false) {
      providerType = 'Picker';
    }
    if (provider.roles['qc'] ?? false) {
      providerType = 'Quality Controller';
    }
    if (provider.roles['investor'] ?? false) {
      providerType = 'Investor';
    }
    if (provider.roles['customer_support'] ?? false) {
      providerType = 'Customer Support';
    }

    return GestureDetector(
      onTap: () {
        if (widget.isSelectPicker ?? false) {
          Get.back(result: provider);
        }
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => UserDetails(
        //               uid: provider.uid,
        //             )));
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 5, left: 5, right: 5, top: 5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[300], blurRadius: 5, offset: Offset(0, 3)),
            ]),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                provider.displayPicture != null
                    ? CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        minRadius: 30,
                        maxRadius: 30,
                        backgroundImage: NetworkImage(
                          provider.displayPicture,
                        ),
                      )
                    : Image.asset(
                        Assets.defaultProfilePic,
                        width: 60,
                      ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      provider.name,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 0.9,
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      provider.mobile.toString().substring(3),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          providerType,
                          style: TextStyle(color: Colors.pink),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        (provider.joinedAt != null)
                            ? Text(
                                'Joined:  ${timeFormat.format(provider.joinedAt)}',
                              )
                            : SizedBox(),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: provider.status != 'verified'
                              ? Colors.grey[500]
                              : Colors.green[800]),
                      child: Text(
                        provider.status != 'verified'
                            ? 'Not Verified'
                            : 'Verified',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    (provider.lastLogin != null)
                        ? Text(
                            'Last Login:  ${timeFormat.format(provider.lastLogin)}',
                          )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserSearch extends SearchDelegate<User> {
  final String storeId;

  UserSearch(this.storeId);
  @override
  String get searchFieldLabel => 'Enter Mobile Number.';

  @override
  // TextInputType get keyboardType => TextInputType.number;
  TextInputType get keyboardType =>
      TextInputType.numberWithOptions(signed: true, decimal: false);

  @override
  TextInputAction get textInputAction => TextInputAction.search;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  Stream<QuerySnapshot> getOrder(int ref) {
    Firestore _db = Firestore.instance;
    return _db
        .collection('stores')
        .document(storeId)
        .collection('pickers')
        .where('mobile', isEqualTo: ref)
        .snapshots();
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    String mobile = '974$query';
    num ref = num.tryParse(mobile);
    return StreamBuilder<QuerySnapshot>(
      stream: getOrder(ref),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('None');
          case ConnectionState.waiting:
            return Text('Waiting');
          case ConnectionState.active:
            if (snapshot.hasData) {
              if (snapshot.data.documents.length > 0) {
                User order = User.fromSnapShot(snapshot.data.documents[0]);
                return _providerCard(order, context);
              } else {
                return Text('No User Found for $query');
              }
            } else {
              return Text('No User Found for $query');
            }

            return Text('Active');
          case ConnectionState.done:
            return Text('Done');
          default:
            return Text('Default');
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length > 7) {
      String mobile = '974$query';
      num ref = num.tryParse(mobile);
      return StreamBuilder<QuerySnapshot>(
        stream: getOrder(ref),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('None');
            case ConnectionState.waiting:
              return Text('Searching for User # $query');
            case ConnectionState.active:
              if (snapshot.hasData) {
                if (snapshot.data.documents.length > 0) {
                  User order = User.fromSnapShot(snapshot.data.documents[0]);
                  return _providerCard(order, context);
                } else {
                  return Text('No User Found for $query');
                }
              } else {
                return Text('No User Found for $query');
              }

              return Text('Active');

            case ConnectionState.done:
              return Text('Done');
            default:
              return Text('Default');
          }
        },
      );
    } else {
      return Text('Enter Mobile Number');
    }
  }

  Widget _providerCard(User provider, BuildContext context) {
    String userRole = 'User';

    if (provider.roles['manager'] ?? false) {
      userRole = 'Manager';
    }
    if (provider.roles['admin'] ?? false) {
      userRole = 'Admin';
    }
    if (provider.roles['store_manager'] ?? false) {
      userRole = 'Store Manager';
    }
    if (provider.roles['driver'] ?? false) {
      userRole = 'Driver';
    }
    if (provider.roles['picker'] ?? false) {
      userRole = 'Picker';
    }
    if (provider.roles['qc'] ?? false) {
      userRole = 'Quality Controller';
    }
    if (provider.roles['investor'] ?? false) {
      userRole = 'Investor';
    }
    if (provider.roles['customer_support'] ?? false) {
      userRole = 'Customer Support';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserDetails(
                      uid: provider.uid,
                    )));
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 5, left: 5, right: 5, top: 5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[300], blurRadius: 5, offset: Offset(0, 3)),
            ]),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                provider.displayPicture != null
                    ? CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        minRadius: 30,
                        maxRadius: 30,
                        backgroundImage: NetworkImage(
                          provider.displayPicture,
                        ),
                      )
                    : Image.asset(
                        Assets.defaultProfilePic,
                        width: 60,
                      ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      provider.name,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 0.9,
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      provider.mobile.toString().substring(3),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userRole,
                      style: TextStyle(color: Colors.pink),
                    ),
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: provider.status != 'verified'
                              ? Colors.grey[500]
                              : Colors.green[800]),
                      child: Text(
                        provider.status != 'verified'
                            ? 'Not Verified'
                            : 'Verified',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
