import 'dart:async';

import 'package:baqaala/src/models/credit_card.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/services/payfort_integration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';

class PayfortTokenPage extends StatefulWidget {
  final PurchaseResult purchaseResult;
  final CreditCard cc;
  PayfortTokenPage({Key key, this.purchaseResult, this.cc}) : super(key: key);

  @override
  _PayfortTokenPageState createState() => _PayfortTokenPageState();
}

class _PayfortTokenPageState extends State<PayfortTokenPage> {
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
      Uri uri = Uri.dataFromString(url);
      print(uri);

      if (url.contains(
          'https://us-central1-baqaala-new.cloudfunctions.net/successPayment')) {
        print(url);
        // Get.back(result: 'Success');
      }

//      print("initState,onStateChanged,url: " + url);

      if (mounted) {
        isRunningWebView = true;

        // String paymentId = uri.queryParameters["paymentId"];
        // var request = MFPaymentStatusRequest(paymentId: paymentId);
        // sdkListener.fetchPaymentStatusByAPI(invoiceId, request);

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
          url: new Uri.dataFromString(_loadHTML(), mimeType: 'text/html')
              .toString(),
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

  String _loadHTML() {
    final AuthModel auth = Provider.of<AuthModel>(context, listen: false);
    PayfortIntegration payfort = PayfortIntegration();

    List<Map<String, dynamic>> attributes = [];
    String card = widget.cc.number.replaceAll(' ', '');

    List<String> ex = widget.cc.expiryDate.split('/');
    String expiry = '${ex[1]}${ex[0]}';
    String reference = payfort.generateMerchantReference();

    attributes.add({'language': 'en'});
    attributes.add({'access_code': 'PavNwhVGTE9abvW5UW5E'});
    attributes.add({'merchant_identifier': '660e542b'});
    attributes.add({'merchant_reference': reference});
    attributes.add({'service_command': 'TOKENIZATION'});
    // attributes.add({'return_url': _returnUrl});

    String html = '<html>';
    html += '<body onload="document.f.submit();">';
    html += '<div><h3>Please Wait...</h3></div>';
    html +=
        '<form id="f" name="f" method="post" action="https://sbcheckout.payfort.com/FortAPI/paymentPage">';

    html +=
        ' <input type="hidden" name="service_command" value="TOKENIZATION" />';
    html +=
        ' <input type="hidden" name="access_code" value="PavNwhVGTE9abvW5UW5E" />';
    html +=
        ' <input type="hidden" name="merchant_identifier" value="660e542b" />';
    html +=
        ' <input type="hidden" name="merchant_reference" value="$reference" />';
    html += ' <input type="hidden" name="language" value="en" />';
    html += ' <input type="hidden" name="expiry_date" value="$expiry" />';
    html +=
        ' <input type="hidden" name="card_holder_name" value="${widget.cc.cardHolderName}" />';
    html += ' <input type="hidden" name="card_number" value="$card" />';
    html +=
        ' <input type="hidden" name="card_security_code" value="${widget.cc.securityCode}" />';
    html += ' <input type="hidden" name="remember_me" value="YES" />';
    html +=
        ' <input type="hidden" name="signature" value="${payfort.calculateSignature(attributes)}" />';

    html += '</form></body></html>';

    return html;
  }
}
