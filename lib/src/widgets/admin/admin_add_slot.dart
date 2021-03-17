import 'package:baqaala/src/common/utils.dart';
import 'package:baqaala/src/models/slot.dart';
import 'package:baqaala/src/models/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAddSlot extends StatefulWidget {
  final Store store;
  final Slot slot;
  AdminAddSlot({Key key, this.store, this.slot}) : super(key: key);

  @override
  _AdminAddSlotState createState() => _AdminAddSlotState();
}

class _AdminAddSlotState extends State<AdminAddSlot> {
  TimeOfDay _startTime, _endTime, _closeTime;
  List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  TextEditingController _maxValue = TextEditingController();
  TextEditingController _maxOrders = TextEditingController();
  bool _isBusy = false;
  bool _applyForAllStores = false;

  @override
  void initState() {
    super.initState();
    getSlot();
  }

  void orderDays() {
    List<String> newDays = [];
    if (_days.isNotEmpty) {
      if (_days.contains('Sunday')) newDays.add('Sunday');
      if (_days.contains('Monday')) newDays.add('Monday');
      if (_days.contains('Tuesday')) newDays.add('Tuesday');
      if (_days.contains('Wednesday')) newDays.add('Wednesday');
      if (_days.contains('Thursday')) newDays.add('Thursday');
      if (_days.contains('Friday')) newDays.add('Friday');
      if (_days.contains('Saturday')) newDays.add('Saturday');
    }
    setState(() {
      _days = newDays;
    });
  }

  void getSlot() async {
    if (widget.slot != null) {
      _startTime = Utils.getTimefromString(widget.slot.startTime);
      _endTime = Utils.getTimefromString(widget.slot.endTime);
      _closeTime = Utils.getTimefromString(widget.slot.closeTime);
      _days = widget.slot.days;
      if (widget.slot.maxValue != null)
        _maxValue.text = widget.slot.maxValue.toString();
      if (widget.slot.maxOrders != null)
        _maxOrders.text = widget.slot.maxOrders.toString();

      if (widget.store.isAllSlotsMaxOrderAndValue) {
        setState(() {
          _applyForAllStores = true;
        });
        _maxValue.text = widget.store.maxValuePerSlot.toString();
        _maxOrders.text = widget.store.maxOrderPerSlot.toString();
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          widget.slot != null ? 'Edit Slot' : 'Add Slot',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: <Widget>[
            _timeSelection(),
            _maxValueFields(),
            Divider(),
            _daysSelection(),
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              height: 75,
              child: RaisedButton(
                color: Colors.green,
                child: Text(widget.slot != null ? 'Update' : 'Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                onPressed: (_startTime != null &&
                        _endTime != null &&
                        _closeTime != null &&
                        !_isBusy)
                    ? () async {
                        setState(() {
                          _isBusy = true;
                        });

                        String title =
                            '${Utils.formatTimeOfDay(_startTime)} - ${Utils.formatTimeOfDay(_endTime)}';
                        Slot newSlot = Slot(
                            title: title,
                            days: _days,
                            isEnable: true,
                            startTime: Utils.getStringFromTime(_startTime),
                            endTime: Utils.getStringFromTime(_endTime),
                            closeTime: Utils.getStringFromTime(_closeTime));
                        if (_maxValue.text.length > 0) {
                          newSlot.maxValue = int.tryParse(_maxValue.text);
                        }
                        if (_maxOrders.text.length > 0) {
                          newSlot.maxOrders = int.tryParse(_maxOrders.text);
                        }

                        if (widget.slot != null) {
                          try {
                            Firestore.instance
                                .collection('stores')
                                .document(widget.store.id)
                                .collection('slots')
                                .document(widget.slot.id)
                                .updateData(newSlot.toJson());

                            Get.snackbar('Success', 'Slot Updated Successfully',
                                backgroundColor: Colors.green,
                                colorText: Colors.white);

                            Get.back();
                          } catch (e) {
                            print(e);
                          }
                        } else {
                          try {
                            Firestore.instance
                                .collection('stores')
                                .document(widget.store.id)
                                .collection('slots')
                                .add(newSlot.toJson());

                            Get.snackbar('Success', 'Slot Added Successfully',
                                backgroundColor: Colors.green,
                                colorText: Colors.white);

                            Get.back();
                          } catch (e) {
                            print(e);
                          }
                        }

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
        ),
      ),
    );
  }

  Widget _maxValueFields() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          TextField(
            enabled: !_applyForAllStores,
            style: TextStyle(
                color: _applyForAllStores ? Colors.grey[500] : Colors.black),
            controller: _maxOrders,
            onChanged: (val) {
              setState(() {});
            },
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Max Orders',
                hintText: 'Maximum Orders to Disable Slot'),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            enabled: !_applyForAllStores,
            style: TextStyle(
                color: _applyForAllStores ? Colors.grey[500] : Colors.black),
            controller: _maxValue,
            onChanged: (val) {
              setState(() {});
            },
            keyboardType: TextInputType.number,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Max Value',
                hintText: 'Maximum Orders Value to Disable Slot'),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Apply Max Orders, Max Value to All Slots'),
              Switch(
                value: _applyForAllStores,
                onChanged: (val) {
                  if (_maxOrders.text.length > 0 && _maxValue.text.length > 0) {
                    try {
                      Firestore.instance
                          .collection('stores')
                          .document(widget.store.id)
                          .updateData({
                        'isAllSlotsMaxOrderAndValue': val,
                        'maxOrderPerSlot': int.parse(_maxOrders.text),
                        'maxValuePerSlot': int.parse(_maxValue.text)
                      });

                      Get.snackbar('Success', 'Applied Successfully',
                          backgroundColor: Colors.green,
                          colorText: Colors.white);

                      setState(() {
                        _applyForAllStores = val;
                      });
                    } catch (e) {
                      print(e);
                    }
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _daysSelection() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            'Select Days',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(
            height: 10,
          ),
          _dayTile('Sunday'),
          _dayTile('Monday'),
          _dayTile('Tuesday'),
          _dayTile('Wednesday'),
          _dayTile('Thursday'),
          _dayTile('Friday'),
          _dayTile('Saturday'),
        ],
      ),
    );
  }

  _dayTile(String day) {
    return Card(
      color: _days.contains(day) ? Colors.green[100] : Colors.grey[300],
      child: ListTile(
        title: Text(
          day,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: Icon(Icons.alarm),
        trailing: Icon(
          Icons.check_circle,
          color: _days.contains(day) ? Colors.green[800] : Colors.grey[300],
        ),
        onTap: () {
          if (_days.contains(day)) {
            _days.remove(day);
          } else {
            _days.add(day);
          }

          // setState(() {});
          orderDays();
          // print(_days);
        },
      ),
    );
  }

  Widget _timeSelection() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Select Timings : ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _startTimeSelector(),
              _endTimeSelector(),
              _closeTimeSelector()
            ],
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Widget _startTimeSelector() {
    return GestureDetector(
      child: Card(
        elevation: 2,
        child: Column(
          children: <Widget>[
            Container(
                height: 50,
                color: Colors.grey[300],
                width: Get.width * 0.28,
                padding: EdgeInsets.all(10),
                child: Center(
                    child: Text(
                  _startTime == null
                      ? 'Select Time'
                      : Utils.formatTimeOfDay(_startTime),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _startTime == null
                          ? Colors.red[800]
                          : Colors.green[800],
                      fontSize: 17),
                ))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Start Time',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        TimeOfDay tod = await showTimePicker(
          context: context,
          initialTime: _startTime != null
              ? _startTime
              : TimeOfDay(hour: TimeOfDay.now().hour, minute: 0),
          builder: (BuildContext context, Widget child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child,
            );
          },
        );
        print(Utils.getStringFromTime(tod));
        if (tod != null)
          setState(() {
            _startTime = tod;
          });
      },
    );
  }

  Widget _closeTimeSelector() {
    return GestureDetector(
      child: Card(
        elevation: 2,
        child: Column(
          children: <Widget>[
            Container(
                height: 50,
                color: Colors.grey[300],
                width: Get.width * 0.28,
                padding: EdgeInsets.all(10),
                child: Center(
                    child: Text(
                  _closeTime == null
                      ? 'Select Time'
                      : Utils.formatTimeOfDay(_closeTime),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _closeTime == null
                          ? Colors.red[800]
                          : Colors.green[800],
                      fontSize: 17),
                ))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Close Time',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        TimeOfDay tod = await showTimePicker(
          context: context,
          initialTime: _closeTime != null
              ? _closeTime
              : TimeOfDay(hour: TimeOfDay.now().hour, minute: 0),
          builder: (BuildContext context, Widget child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child,
            );
          },
        );
        if (tod != null)
          setState(() {
            _closeTime = tod;
          });
      },
    );
  }

  Widget _endTimeSelector() {
    return GestureDetector(
      child: Card(
        elevation: 2,
        child: Column(
          children: <Widget>[
            Container(
                height: 50,
                color: Colors.grey[300],
                width: Get.width * 0.28,
                padding: EdgeInsets.all(10),
                child: Center(
                    child: Text(
                  _endTime == null
                      ? 'Select Time'
                      : Utils.formatTimeOfDay(_endTime),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _endTime == null
                          ? Colors.red[800]
                          : Colors.green[800],
                      fontSize: 17),
                ))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'End Time',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        TimeOfDay tod = await showTimePicker(
          context: context,
          initialTime: _endTime != null
              ? _endTime
              : TimeOfDay(hour: TimeOfDay.now().hour, minute: 0),
          builder: (BuildContext context, Widget child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child,
            );
          },
        );
        if (tod != null)
          setState(() {
            _endTime = tod;
          });
      },
    );
  }
}
