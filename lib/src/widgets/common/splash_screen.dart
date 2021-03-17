import 'package:baqaala/app.dart';
import 'package:baqaala/app_init.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController _controller;
  double _opacity = 0;
  Size _size = Size(100, 100);

  @override
  void initState() {
    super.initState();
    print('Splash loaded');

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Lottie.asset('assets/lottie/home-delivery-man.json',
              // width: 300, height: 300,
              // fit: BoxFit.fitHeight,
              // controller: _controller,
              onLoaded: (comp) {
            setState(() {
              _opacity = 1.0;
            });
            Future.delayed(Duration(seconds: 3), () {
              Get.offAll(AppInit());
              // Get.snackbar('TimeUp', 'Time Up');
            });
            // _controller
            //   ..duration = comp.duration
            //   ..forward();
          }),
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(milliseconds: 1000),
              child: Text(
                'baqaala',
                style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 50),
              ),
            ),
          )
        ],
      ),
    );
  }
}
