import 'package:baqaala/src/common/utils.dart';
import 'package:baqaala/src/models/service_area.dart';
import 'package:baqaala/src/models/slot.dart';
import 'package:baqaala/src/widgets/admin/admin_add_store_area.dart';
import 'package:baqaala/src/widgets/admin/admin_select_slot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminStoreAreaDetails extends StatefulWidget {
  final ServiceArea area;
  final String storeId;
  final String storeTypeId;
  AdminStoreAreaDetails({Key key, this.area, this.storeId, this.storeTypeId})
      : super(key: key);

  @override
  _AdminStoreAreaDetailsState createState() => _AdminStoreAreaDetailsState();
}

class _AdminStoreAreaDetailsState extends State<AdminStoreAreaDetails> {
  ServiceArea _area;
  List<LatLng> latlngList = [];
  GoogleMapController _controller;
  final Set<Polyline> _polyline = {};
  String polyPath = '';

  List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  TextEditingController _feeController = TextEditingController();
  bool _isBusy = false;
  String _fee = '';

  var _initialLocation = CameraPosition(
    target: LatLng(25.3557021, 51.2372571),
    zoom: 14,
    // tilt: 20,
  );

  @override
  void initState() {
    super.initState();
    if (widget.area != null) {
      setState(() {
        _area = widget.area;
        latlngList = Utils.stringToLatLngList(widget.area.polygonData);
        polyPath = widget.area.polygonData;
        if (_area.convenienceFee != null) {
          _feeController.text = _area.convenienceFee?.toString();
          _fee = _area.convenienceFee.toString();
        }

        _initialLocation = CameraPosition(
          target: latlngList[0],
          zoom: 14,
          // tilt: 20,
        );
        // _makePolyLine();
      });
    }
    _getArea();
  }

  void _getArea() {
    Firestore.instance
        .collection('service_areas')
        .document(widget.area.id)
        .snapshots()
        .listen((doc) {
      ServiceArea area = ServiceArea.fromSnapShot(doc);
      setState(() {
        _area = area;
        latlngList = Utils.stringToLatLngList(_area.polygonData);
        if (_area.convenienceFee != null) {
          _feeController.text = _area.convenienceFee?.toString();
          _fee = _area.convenienceFee.toString();
        }
      });

      _feeController.addListener(() {
        setState(() {
          _fee = _feeController.text;
        });
      });
    });
  }

  _makePolyLine() {
    _polyline.add(Polyline(
      polylineId: PolylineId('area'),
      visible: true,
      width: 2,
      //latlng is List<LatLng>
      points: latlngList,
      color: Colors.blue,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          Slot slot = await Get.to(AdminSelectSlot(
            storeId: _area.storeId,
          ));

          if (slot != null) {
            print(slot.title);
            try {
              await Firestore.instance
                  .collection('service_areas')
                  .document(_area.id)
                  .collection('slots')
                  .document(slot.id)
                  .setData(slot.toJson(), merge: true);
            } catch (e) {
              print(e);
            }
          }
        },
      ),
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          widget.area != null ? _area.title : 'Area Details',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: <Widget>[
            _mapArea(),
            SizedBox(
              height: 10,
            ),
            _convenienceFee(),
            SizedBox(
              height: 10,
            ),
            _daysToDisplay(),
            Divider(
              color: Colors.grey[400],
              thickness: 1,
            ),
            Text(
              'SLOTS',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            _slotList(),
            SizedBox(
              height: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('service_areas')
          .document(_area.id)
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
                    'No Slots Added',
                    style: TextStyle(fontSize: 16),
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
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        width: Get.width,
        child: Card(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5),
                height: 40,
                width: Get.width,
                color: Colors.grey[300],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      slot.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: slot.isEnable,
                      onChanged: (val) async {
                        try {
                          Firestore.instance
                              .collection('service_areas')
                              .document(_area.id)
                              .collection('slots')
                              .document(slot.id)
                              .updateData({'isEnable': val});
                        } catch (e) {
                          print(e);
                        }
                      },
                    ),
                  ],
                ),
              ),
              slot.isEnable ? _daysButtons(slot) : SizedBox(),
            ],
          ),
        ),
      ),
      secondaryActions: <Widget>[
        // IconSlideAction(
        //   caption: 'Edit',
        //   color: Colors.black45,
        //   icon: Icons.edit,
        //   // onTap: () => _showSnackBar('More'),
        // ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            Firestore.instance
                .collection('service_areas')
                .document(_area.id)
                .collection('slots')
                .document(slot.id)
                .delete();
          },
        ),
      ],
    );
  }

  Widget _daysButtons(Slot slot) {
    return Container(
      padding: EdgeInsets.only(left: 5),
      width: Get.width,
      child: Wrap(
        spacing: 2,
        children: <Widget>[
          _dayButton('Sunday', slot),
          _dayButton('Monday', slot),
          _dayButton('Tuesday', slot),
          _dayButton('Wednesday', slot),
          _dayButton('Thursday', slot),
          _dayButton('Friday', slot),
          _dayButton('Saturday', slot),
        ],
      ),
    );
  }

  Widget _dayButton(String day, Slot slot) {
    return FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      child: Text(
        day,
        style: TextStyle(
            color: slot.days.contains(day) ? Colors.pink : Colors.grey),
      ),
      color: slot.days.contains(day) ? Colors.pink[50] : Colors.grey[100],
      onPressed: () async {
        try {
          await Firestore.instance
              .collection('service_areas')
              .document(_area.id)
              .collection('slots')
              .document(slot.id)
              .updateData({
            'days': slot.days.contains(day)
                ? FieldValue.arrayRemove([day])
                : FieldValue.arrayUnion([day]),
          });
        } catch (e) {
          print(e);
        }
        print(day);
      },
    );
  }

  Widget _daysToDisplay() {
    return SizedBox(
      height: 60,
      width: Get.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
              width: Get.width * 0.6,
              child: Text(
                'Select Days To Display',
                style: TextStyle(
                  fontSize: 16,
                ),
              )),
          SizedBox(
            width: Get.width * 0.25,
            height: 60,
            child: DropdownButtonFormField(
              value: _area.daysToDisplay,
              decoration:
                  InputDecoration(filled: true, fillColor: Colors.grey[300]),
              onChanged: (val) async {
                try {
                  if (val > 0) {
                    await Firestore.instance
                        .collection('service_areas')
                        .document(_area.id)
                        .updateData({'daysToDisplay': val});

                    Get.rawSnackbar(
                      message: 'Successfully Updated',
                      margin: EdgeInsets.all(10),
                      borderRadius: 10,
                      // backgroundColor: Colors.green[800],
                      snackStyle: SnackStyle.FLOATING,
                    );
                    setState(() {});
                  }
                } catch (e) {
                  print(e);
                }
                print(val);
              },
              items: [
                DropdownMenuItem<int>(
                  value: 1,
                  child: Text('1'),
                ),
                DropdownMenuItem<int>(
                  value: 2,
                  child: Text('2'),
                ),
                DropdownMenuItem<int>(
                  value: 3,
                  child: Text('3'),
                ),
                DropdownMenuItem<int>(
                  value: 4,
                  child: Text('4'),
                ),
                DropdownMenuItem<int>(
                  value: 5,
                  child: Text('5'),
                ),
                DropdownMenuItem<int>(
                  value: 6,
                  child: Text('6'),
                ),
                DropdownMenuItem<int>(
                  value: 7,
                  child: Text('7'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _convenienceFee() {
    return SizedBox(
      height: 60,
      width: Get.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
              width: Get.width * 0.68,
              height: 55,
              child: TextField(
                controller: _feeController,
                keyboardType: TextInputType.number,
                onSubmitted: (_) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  // FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  fillColor: Colors.grey[300],
                  filled: true,
                  suffixText: 'QAR',
                  labelText: 'Convenience Fee',
                ),
              )),
          SizedBox(
            width: Get.width * 0.25,
            height: 55,
            child: RaisedButton(
              color: Colors.amber,
              child: Text('Update'),
              onPressed: (_fee.length > 0 && !_isBusy)
                  ? () async {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');

                      setState(() {
                        _isBusy = true;
                      });

                      try {
                        double val = double.tryParse(_fee);
                        if (val > 0) {
                          await Firestore.instance
                              .collection('service_areas')
                              .document(_area.id)
                              .updateData({'convenienceFee': val});

                          Get.rawSnackbar(
                            message: 'Successfully Updated',
                            margin: EdgeInsets.all(10),
                            borderRadius: 10,
                            // backgroundColor: Colors.green[800],
                            snackStyle: SnackStyle.FLOATING,
                          );
                          setState(() {});
                        }
                      } catch (e) {
                        print(e);
                      }

                      setState(() {
                        _isBusy = false;
                      });
                    }
                  : null,
            ),
          )
        ],
      ),
    );
  }

  Widget _mapArea() {
    return Container(
      width: Get.width,
      height: 250,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: <Widget>[
          GoogleMap(
            polygons: latlngList.length > 2
                ? Set<Polygon>.of(<Polygon>[
                    Polygon(
                        polygonId: PolygonId('area'),
                        points: latlngList.length > 2 ? latlngList : [],
                        geodesic: true,
                        strokeColor: Colors.purple.withOpacity(0.6),
                        strokeWidth: 2,
                        fillColor: Colors.purple.withOpacity(0.1),
                        visible: true),
                  ])
                : Set<Polygon>.of(<Polygon>[]),
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _controller = controller;
              });

              Future.delayed(Duration(milliseconds: 400), () {
                if (widget.area == null) {
                } else {
                  moveToPolyLocation();
                }
              });
            },

            onTap: (loc) async {
              await Get.to(AdminAddStoreArea(
                storeId: _area.storeId,
                area: _area,
                storeTypeId: _area.storeTypeId,
              ));
              moveToPolyLocation();
            },
            rotateGesturesEnabled: false,
            scrollGesturesEnabled: false,
            zoomGesturesEnabled: false,
            mapType: MapType.normal,
            myLocationButtonEnabled: false,

            zoomControlsEnabled: false,

            // myLocationButtonEnabled: true,
            initialCameraPosition: _initialLocation,
            myLocationEnabled: false,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                'Click on Map to Edit',
                style: TextStyle(shadows: [
                  Shadow(
                      color: Colors.grey, offset: Offset(0, 0), blurRadius: 5),
                  Shadow(
                      color: Colors.white,
                      offset: Offset(0, 0),
                      blurRadius: 10),
                ]),
              ),
            ),
          )
        ],
      ),
    );
  }

  void moveToPolyLocation() {
    if (_controller != null && latlngList.isNotEmpty)
      _controller.animateCamera(
          CameraUpdate.newLatLngBounds(_createBounds(latlngList), 30)
          // CameraUpdate.newCameraPosition(CameraPosition(
          //   target: LatLng(latlngList[0]?.latitude, latlngList[0]?.longitude),
          //   zoom: 14))

          );
  }

  LatLngBounds _createBounds(List<LatLng> positions) {
    final southwestLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value < element ? value : element); // smallest
    final southwestLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value < element ? value : element);
    final northeastLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value > element ? value : element); // biggest
    final northeastLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value > element ? value : element);
    return LatLngBounds(
        southwest: LatLng(southwestLat, southwestLon),
        northeast: LatLng(northeastLat, northeastLon));
  }
}
