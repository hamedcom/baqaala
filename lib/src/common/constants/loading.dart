import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget kLoadingWidget(context) => Center(
      child: SpinKitFadingCube(
        color: Theme.of(context).primaryColor,
        size: 30.0,
      ),
    );
