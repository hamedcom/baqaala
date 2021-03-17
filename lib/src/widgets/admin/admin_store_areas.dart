import 'package:baqaala/src/models/service_area.dart';
import 'package:baqaala/src/models/store.dart';
import 'package:baqaala/src/widgets/admin/admin_add_store_area.dart';
import 'package:baqaala/src/widgets/admin/admin_store_area_details.dart';
import 'package:baqaala/src/widgets/common/select_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminStoreAreas extends StatefulWidget {
  final String storeId;
  final String storeTypeId;
  final Store store;
  AdminStoreAreas({Key key, this.storeId, this.storeTypeId, this.store})
      : super(key: key);

  @override
  _AdminStoreAreasState createState() => _AdminStoreAreasState();
}

class _AdminStoreAreasState extends State<AdminStoreAreas> {
  bool _isEnableRadius = false;
  LatLng storeLocation;
  double radius = 1000;
  Store _store;
  List<ServiceArea> _areas;
  Firestore _db = Firestore.instance;

  @override
  void initState() {
    super.initState();
    setState(() {
      _store = widget.store;
      storeLocation = _store.location;
      _isEnableRadius = !_store.isServiceByArea;
      radius = _store.radius ?? 1000;
      print(storeLocation);
      print(radius);
    });
  }

  // _getStore() async {
  //   var doc = await _db.collection('stores').document(widget.storeId).get();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isEnableRadius
          ? SizedBox()
          : FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AdminAddStoreArea(
                          storeId: widget.storeId,
                          storeTypeId: widget.storeTypeId,
                        )));
                print('Hello');
              },
            ),
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Delivery Areas',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: Get.height,
          width: Get.width,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: <Widget>[
              Card(
                child: ListTile(
                  title: Text('Enable Radius'),
                  subtitle: Text('Switch Between Radius or Areas'),
                  trailing: Switch(
                      value: _isEnableRadius,
                      onChanged: (val) {
                        _db
                            .collection('stores')
                            .document(_store.id)
                            .setData({'isServiceByArea': !val}, merge: true);
                        setState(() {
                          _isEnableRadius = val;
                        });
                      }),
                ),
              ),
              _isEnableRadius ? _radiusOptions() : _storeAreas()
            ],
          ),
        ),
      ),
    );
  }

  Widget _storeAreas() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Text('Service Areas'),
        SizedBox(
          height: 10,
        ),
        Divider(),
        StreamBuilder(
          stream: Firestore.instance
              .collection('service_areas')
              .where('storeId', isEqualTo: widget.storeId)
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
                    return Column(children: areaList(snapshot, context));
                  else
                    return Center(
                      child: Text(
                        'No Areas Found. Click + for Add New',
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
        )
      ],
    );
  }

  List<Widget> areaList(AsyncSnapshot snapshot, BuildContext context) {
    return snapshot.data.documents.map<Widget>((document) {
      ServiceArea store = ServiceArea.fromSnapShot(document);

      return _areaCard(store);
    }).toList();
  }

  Widget _areaCard(ServiceArea area) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: () {
          // Get.to(AdminAddStoreArea(
          //   storeId: area.storeId,
          //   area: area,
          //   storeTypeId: area.storeTypeId,
          // ));
          if (area.isActive)
            Get.to(AdminStoreAreaDetails(
              storeId: area.id,
              area: area,
              storeTypeId: area.storeTypeId,
            ));
        },
        title: Text(area.title),
        subtitle: Text(
          area.isActive
              ? 'Delivery to This Area Enabled'
              : 'Delivery To This Area Disabled',
          style: TextStyle(color: area.isActive ? Colors.green : Colors.orange),
        ),
        trailing: Switch(
          value: area.isActive,
          onChanged: (val) {
            _db
                .collection('service_areas')
                .document(area.id)
                .updateData({'isActive': val});
          },
        ),
      ),
    );
  }

  Widget _radiusOptions() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        Card(
          child: ListTile(
            trailing: Icon(Icons.chevron_right),
            title: Text(storeLocation == null
                ? 'Select Store Location.'
                : 'Edit Store Location'),
            subtitle: Text('Store Location Must be Selected'),
            onTap: () async {
              var loc = await Get.to(SelectLocation());
              if (loc != null) {
                setState(() {
                  storeLocation = loc;
                });
              }
              // print(loc);
            },
          ),
        ),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('Select Radius : (${radius.floor() / 1000} Km)'),
              ),
              Slider(
                min: 1000,
                max: 50000,
                divisions: 49,
                value: radius,
                onChanged: (val) {
                  setState(() {
                    radius = val;
                  });
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.all(5),
          width: double.infinity,
          height: 60,
          child: RaisedButton(
            color: Colors.green,
            child: Text(
              'Save',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              if (storeLocation != null) {
                _store.location = storeLocation;
              }
              _store.radius = radius;
              await _db.collection('stores').document(_store.id).setData({
                'location': storeLocation.toJson(),
                'radius': radius,
              }, merge: true);

              Get.back();
            },
          ),
        )
      ],
    );
  }
}
