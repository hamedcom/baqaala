import 'dart:async';

import 'package:baqaala/src/services/payfort_integration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get/route_manager.dart';

class PaymentView extends StatefulWidget {
  final PurchaseResult purchaseResult;
  PaymentView({Key key, this.purchaseResult}) : super(key: key);

  @override
  _PaymentViewState createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  double progress = 0;
  var isRunningWebView = false;

  final flutterWebViewPlugin = FlutterWebviewPlugin();
  StreamSubscription<double> _onProgressChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  @override
  void initState() {
    super.initState();

    _onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      String url = state.url;

      print(url);
      if (url.contains(
          'https://us-central1-baqaala-new.cloudfunctions.net/successPayment')) {
        Get.back(result: 'Success');
      }

//      print("initState,onStateChanged,url: " + url);

      if (mounted) {
        if (widget.purchaseResult.secureUrl != null && !isRunningWebView) {
          isRunningWebView = true;

          Uri uri = Uri.dataFromString(widget.purchaseResult.secureUrl);
          // String paymentId = uri.queryParameters["paymentId"];
          // var request = MFPaymentStatusRequest(paymentId: paymentId);
          // sdkListener.fetchPaymentStatusByAPI(invoiceId, request);
        }
      }
    });

    _onProgressChanged =
        flutterWebViewPlugin.onProgressChanged.listen((double progress) {
      if (mounted) {
        setState(() {
          this.progress = progress;
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _onProgressChanged.cancel();
    _onStateChanged.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          '',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
        height: Get.height,
        width: Get.width,
        child: WebviewScaffold(
          url: widget.purchaseResult.secureUrl,
          withJavascript: true,
          mediaPlaybackRequiresUserGesture: false,
          withZoom: true,
          withLocalStorage: true,
          initialChild: Container(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
