import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<dynamic> showDialogNotInternet(BuildContext context) {
  return showDialog(
      context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Center(
          child: Row(
            children: <Widget>[
              Icon(
                Icons.warning,
              ),
              Text('No Internet Connection'),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text('Please Check Internet Connection'),
        ),
        actions: <Widget>[
          // FlatButton(
          //   onPressed: AppSettings.openWIFISettings,
          //   child: Text(S.of(context).settings),
          // )
        ],
      );
    },
  );
}
