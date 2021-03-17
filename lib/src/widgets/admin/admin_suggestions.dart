import 'package:baqaala/src/models/suggest_item.dart';
import 'package:baqaala/src/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminSuggestions extends StatefulWidget {
  AdminSuggestions({Key key}) : super(key: key);

  @override
  _AdminSuggestionsState createState() => _AdminSuggestionsState();
}

class _AdminSuggestionsState extends State<AdminSuggestions> {
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
          .collection('suggestions')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .getDocuments();
    } else {
      data = await _db
          .collection('suggestions')
          .orderBy('createdAt', descending: true)
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
      print('no content');
      scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: Text('No More Users'),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Suggestions',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 1,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        brightness: Brightness.light,
      ),
      body: ListView.builder(
          controller: listScrollController,
          itemCount: _data.length + 1,
          itemBuilder: (_, int index) {
            if (index < _data.length) {
              final DocumentSnapshot document = _data[index];
              SuggestItem _item = SuggestItem.fromSnapShot(document);
              return _suggestionCard(_item, context);
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
    );
  }

  Widget _suggestionCard(SuggestItem item, BuildContext context) {
    final timeFormat = DateFormat("dd-MMM-yy hh:mm a");

    return GestureDetector(
      onTap: () {},
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
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.itemName,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 0.9,
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      item.itemDescription,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    (item.createdAt != null)
                        ? Text(
                            '${timeFormat.format(item.createdAt)}',
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
