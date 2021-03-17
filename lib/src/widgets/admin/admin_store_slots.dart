import 'dart:convert';

import 'package:baqaala/src/models/slot.dart';
import 'package:baqaala/src/models/store.dart';
import 'package:baqaala/src/widgets/admin/admin_add_slot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminStoreSlots extends StatefulWidget {
  final Store store;
  AdminStoreSlots({Key key, this.store}) : super(key: key);

  @override
  _AdminStoreSlotsState createState() => _AdminStoreSlotsState();
}

class _AdminStoreSlotsState extends State<AdminStoreSlots> {
  Store _store;
  Firestore _db = Firestore.instance;
  List<Slot> _slots;
  List<Slot> _newSlots;
  bool _isSlotAutoDisable = false;
  TextEditingController _maxValue = TextEditingController();
  TextEditingController _maxOrders = TextEditingController();
  bool _isBusy = false;
  List<String> days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  List<String> selectedDays = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _store = widget.store;
      _isSlotAutoDisable = _store.isSlotAutoDisable;
      _slots = allSlots;
      _maxOrders.text = _store.maxOrderPerSlot.toString();
      _maxValue.text = _store.maxValuePerSlot.toString();
    });
  }

  _getStore() {
    _db
        .collection('stores')
        .document(widget.store.id)
        .snapshots()
        .listen((doc) {
      setState(() {
        _store = Store.fromSnapShot(doc);
      });
    });
  }

  _getSlots() {
    _db
        .collection('stores')
        .document(widget.store.id)
        .collection('slots')
        .snapshots()
        .listen((event) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Get.to(
              AdminAddSlot(
                store: widget.store,
              ),
              transition: Transition.cupertino);
        },
      ),
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Slots',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            _slotList(),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('stores')
          .document(widget.store.id)
          .collection('slots')
          .orderBy('startTime', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:

          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            if (snapshot.hasData) {
              if (snapshot.data.documents.length != 0)
                return Column(children: slotList(snapshot, context));
              else
                return Center(
                  child: Text(
                    'No Slots Found',
                    style: TextStyle(fontSize: 18),
                  ),
                );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            return null;
        }
      },
    );
  }

  List<Widget> slotList(AsyncSnapshot snapshot, BuildContext context) {
    return snapshot.data.documents.map<Widget>((document) {
      Slot slot = Slot.fromSnapShot(document);
      return _slotCard(slot);
    }).toList();
  }

  Widget _slotCard(Slot slot) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(
          slot.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Get.to(AdminAddSlot(
            slot: slot,
            store: widget.store,
          ));
        },
      ),
    );
  }

  Widget _auotDisableSettings() {
    return Column(
      children: <Widget>[
        TextField(
          controller: _maxOrders,
          onChanged: (val) {
            setState(() {});
          },
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Max Orders',
              hintText: 'Maximum Orders to Disable Slot'),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: _maxValue,
          onChanged: (val) {
            setState(() {});
          },
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Max Value',
              hintText: 'Maximum Orders Value to Disable Slot'),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          width: double.infinity,
          height: 50,
          child: RaisedButton(
            color: Colors.green,
            child: Text('Save',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            onPressed: (_maxValue.text?.length > 0 &&
                    _maxOrders.text?.length > 0 &&
                    !_isBusy)
                ? () async {
                    setState(() {
                      _isBusy = true;
                    });
                    await _db
                        .collection('stores')
                        .document(_store.id)
                        .updateData({
                      'maxOrderPerSlot': int.parse(_maxOrders.text),
                      'maxValuePerSlot': int.parse(_maxValue.text)
                    });

                    Get.snackbar('Success', 'Successfully Updated',
                        backgroundColor: Colors.green, colorText: Colors.white);

                    setState(() {
                      _isBusy = false;
                    });
                  }
                : null,
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
