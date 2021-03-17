import 'dart:async';

import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/services/payfort_integration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PayfortRedirect extends StatefulWidget {
  final double amount;
  final String cardType;
  PayfortRedirect({Key key, this.amount, this.cardType}) : super(key: key);

  @override
  _PayfortRedirectState createState() => _PayfortRedirectState();
}

class _PayfortRedirectState extends State<PayfortRedirect> {
  double progress = 0;
  var isRunningWebView = false;

  String _returnUrl =
      'https://us-central1-baqaala-new.cloudfunctions.net/successPayment';

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
        print('Success');
      }

//      print("initState,onStateChanged,url: " + url);

      if (mounted) {
        isRunningWebView = true;

        // Uri uri = Uri.dataFromString(widget.purchaseResult.secureUrl);
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
          print(progress);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      withJavascript: true,
      appCacheEnabled: true,
      mediaPlaybackRequiresUserGesture: false,
      withZoom: true,
      withLocalStorage: true,
      initialChild: Container(
        height: Get.height,
        width: Get.width,
        // color: Colors.green,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      url:
          new Uri.dataFromString(_loadHTML(), mimeType: 'text/html').toString(),
    );
  }

  String _loadHTML() {
    final AuthModel auth = Provider.of<AuthModel>(context, listen: false);
    PayfortIntegration payfort = PayfortIntegration();

    List<Map<String, dynamic>> attributes = [];
    String reference = payfort.generateMerchantReference();

    attributes.add({'language': 'en'});
    attributes.add({'access_code': 'PavNwhVGTE9abvW5UW5E'});
    attributes.add({'merchant_identifier': '660e542b'});
    attributes.add({'merchant_reference': reference});
    attributes.add({'command': 'PURCHASE'});
    attributes
        .add({'amount': payfort.convertToFortAmount(widget.amount, 'QAR')});
    attributes.add({'payment_option': 'NAPS'});
    attributes.add({'currency': 'QAR'});
    attributes.add({'customer_email': auth.fUser.email});
    // attributes.add({'order_description': 'Top Up'});
    // attributes.add({'merchant_extra': auth.fUser.uid});
    // attributes.add({'merchant_extra1': 'wallet'});
    // attributes.add({'merchant_extra2': creditTo});
    // attributes.add({'remember_me': 'YES'});
    // attributes.add({'return_url': _returnUrl});

    String html = '<html>';
    html += '<body onload="document.form1.submit();">';
    html += '<div><h3>Please Wait...</h3></div>';
    html +=
        '<form id="form1" name="form1" method="post" action="https://sbcheckout.payfort.com/FortAPI/paymentPage">';

    html += ' <input type="hidden" name="command" value="PURCHASE" />';
    html +=
        ' <input type="hidden" name="access_code" value="PavNwhVGTE9abvW5UW5E" />';
    html +=
        ' <input type="hidden" name="merchant_identifier" value="660e542b" />';
    html +=
        ' <input type="hidden" name="merchant_reference" value="$reference" />';
    html +=
        ' <input type="hidden" name="amount" value="${payfort.convertToFortAmount(widget.amount, 'QAR')}" />';
    html += ' <input type="hidden" name="currency" value="QAR" />';
    html += ' <input type="hidden" name="language" value="en" />';
    html +=
        ' <input type="hidden" name="customer_email" value="${auth.fUser.email}" />';
    // html +=
    // ' <input type="hidden" name="merchant_extra" value="${auth.fUser.uid}" />';
    // html += ' <input type="hidden" name="merchant_extra1" value="wallet" />';
    // html += ' <input type="hidden" name="order_description" value="Top Up" />';
    html +=
        ' <input type="hidden" name="signature" value="${payfort.calculateSignature(attributes)}" />';

    html += ' <input type="hidden" name="payment_option" value="NAPS" />';
    // html += ' <input type="hidden" name="return_url" value="$_returnUrl" />';
    html += ' <input type="submit" name="" value="Pay" id="" />';

    html += '</form></body></html>';

    return html;

    return r'''
      <html>
        <body onload="document.f.submit();">
          <form id="f" name="f" method="post" action="YOUR_POST_URL">
            <input type="hidden" name="PARAMETER" value="VALUE" />
          </form>
        </body>
      </html>
    ''';
  }
}
