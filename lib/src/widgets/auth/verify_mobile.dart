import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/services/navigation_service.dart';
import 'package:baqaala/src/services/snackbar_service.dart';
import 'package:baqaala/src/widgets/auth/login.dart';
import 'package:baqaala/src/widgets/user/home.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerifyMobile extends StatefulWidget {
  VerifyMobile({Key key}) : super(key: key);

  @override
  _VerifyMobileState createState() => _VerifyMobileState();
}

class _VerifyMobileState extends State<VerifyMobile> with CodeAutoFill {
  String _code = '';
  String signature = "{{ app signature }}";
  bool _isOtpSent = false;
  bool _isSubmit = false;
  SmsAutoFill autoFill;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    if (autoFill != null) {
      // autoFill.unregisterListener();
    }
    super.dispose();
  }

  @override
  void codeUpdated() {
    setState(() {
      _code = code;
    });
  }

  void sendOtp({String uid, int mobile}) async {
    autoFill = SmsAutoFill();
    String appId = await autoFill.getAppSignature;

    autoFill.listenForCode;
    setState(() {
      _isOtpSent = true;
    });
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'sendOtp',
    );
    try {
      var res = await callable.call(<String, dynamic>{
        'appId': appId,
        'uid': uid,
        'mobile': mobile,
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthModel>(context);
    if (auth.fUser == null) {
      NavigationService.instance
          .navigateToRoute(MaterialPageRoute(builder: (context) => Login()));
    } else if (auth.fUser.status == 'verified') {}
    return Scaffold(

        // resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
      child: Builder(builder: (BuildContext context) {
        SnackBarService.instance.buildContext = context;

        return Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 50,
                ),
                Container(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                        child: Text(
                          'Verify Mobile',
                          style: TextStyle(
                              fontSize: 40.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    padding:
                        EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                    child: Column(
                      children: <Widget>[
                        Text('OTP will send to +${auth.fUser.mobile}'),
                        SizedBox(height: 10.0),
                        _isOtpSent
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: PinFieldAutoFill(
                                  codeLength: 4,
                                  decoration: UnderlineDecoration(
                                      textStyle: TextStyle(
                                          fontSize: 20, color: Colors.black)),
                                  currentCode: _code,
                                  onCodeChanged: (val) async {
                                    if (_isOtpSent && val.length > 3) {
                                      if (!_isSubmit) {
                                        setState(() {
                                          _isSubmit = true;
                                          _code = val;
                                        });

                                        var res = await auth.verifyOTP(val);
                                        if (res) {
                                          Get.off(Home(
                                            autoRedirect: true,
                                          ));
                                          // NavigationService.instance.goBack();
                                        }
                                        print(res);
                                      }
                                      print('Submit');
                                    }
                                    print('changed $val');
                                  },
                                ),
                              )
                            : SizedBox(),
                        SizedBox(height: 50.0),
                        _isOtpSent
                            ? Container(
                                height: 50.0,
                                width: MediaQuery.of(context).size.width * .9,
                                child: RaisedButton(
                                  onPressed: _code.length == 4
                                      ? () async {
                                          var res = await auth.verifyOTP(_code);
                                          if (res) {
                                            NavigationService.instance.goBack();
                                          }
                                          print(res);
                                        }
                                      : null,
                                  // borderRadius: BorderRadius.circular(10.0),
                                  // shadowColor: Colors.greenAccent,
                                  color: Colors.green,
                                  elevation: 7.0,
                                  child: Text(
                                    'Verify',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat'),
                                  ),
                                ))
                            : auth.fUser.status == 'verified'
                                ? RaisedButton(
                                    child: Text('Already Verified'),
                                    color: Colors.green[700],
                                    onPressed: () {
                                      NavigationService.instance.goBack();
                                    },
                                  )
                                : Container(
                                    height: 50.0,
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    child: RaisedButton(
                                      color: Colors.orange,
                                      child: Text('Send OTP'),
                                      onPressed: () {
                                        sendOtp(
                                            uid: auth.fUser.uid,
                                            mobile: auth.fUser.mobile);
                                      },
                                    ),
                                  ),
                        SizedBox(height: 20.0),
                        Container(
                          height: 50.0,
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black,
                                    style: BorderStyle.solid,
                                    width: 1.0),
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(5)),
                            child: InkWell(
                              onTap: () {
                                Get.off(Home());
                                // Navigator.of(context).pop();
                              },
                              child: Center(
                                child: Text('Go Back',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat')),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                // SizedBox(height: 15.0),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     Text(
                //       'New to Spotify?',
                //       style: TextStyle(
                //         fontFamily: 'Montserrat',
                //       ),
                //     ),
                //     SizedBox(width: 5.0),
                //     InkWell(
                //       child: Text('Register',
                //           style: TextStyle(
                //               color: Colors.green,
                //               fontFamily: 'Montserrat',
                //               fontWeight: FontWeight.bold,
                //               decoration: TextDecoration.underline)),
                //     )
                //   ],
                // )
              ]),
        );
      }),
    ));
  }
}
