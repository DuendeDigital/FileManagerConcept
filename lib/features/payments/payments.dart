import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:keepit/constants/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:keepit/constants/error_handling.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:keepit/main.dart' as workmanager;

import '../home/dashboard.dart';

class PaymentScreen extends StatefulWidget {
  static const String routeName = '/payments';
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  //Globals
  bool hasInternet = false;
  bool successfulTransaction = true;

  @override
  void initState() {
    super.initState();
    workmanager.KeepApp().pause_task();
  }

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  showToast(String message) {
    Color toastColour;

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Color.fromARGB(255, 58, 58, 58),
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void checkInternetconnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          hasInternet = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        hasInternet = false;
      });
    }
  }

  sendData(ref, plan, amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('id');
    String? email = prefs.getString('email');

    setState(() {
      successfulTransaction = false;
    });

    http.Response res = await http.post(
      Uri.parse('$uri/api/v1/subscription.php'),
      body: jsonEncode({
        'reference': ref,
        'email': email,
        'user_id': uid,
        'plan_id': plan,
        'sub_amount': amount,
      }),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (res.statusCode != 200) {
      showSnackBar(
        context,
        'Error! Please try again later',
      );
      setState(() {
        successfulTransaction = true;
      });
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }

    httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          setState(() {
            successfulTransaction = true;
          });
          showSnackBar(
            context,
            'Subscription Activated!',
          );
          await prefs.setString('sub_plan', jsonDecode(res.body)['sub_plan']);
          await prefs.setString(
              'sub_signup_date', jsonDecode(res.body)['sub_signup_date']);
          await prefs.setString(
              'sub_end_date', jsonDecode(res.body)['sub_end_date']);
          await prefs.setString(
              'sub_active', jsonDecode(res.body)['sub_active']);
          await prefs.setString(
              'customer_id', jsonDecode(res.body)['customer_id']);

          Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
        });
  }

  Future<bool> enable_ads() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.reload();
    prefs.setBool('AppActive', true);
    print('Ads Enabled for payment screen');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    print("chewie ${arguments['payment_type']}");

    return WillPopScope(
      onWillPop: () async {
        workmanager.KeepApp().enable_task();
        return successfulTransaction;
      },
      child: GestureDetector(
        onHorizontalDragUpdate: (updateDetails) {},
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Text("${arguments['title']}"),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Builder(
              builder: (BuildContext context) {
                return WebView(
                    initialUrl: arguments['url'],
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller.complete(webViewController);
                    },
                    userAgent: 'Flutter;Webview',
                    navigationDelegate: (navigation) {
                      checkInternetconnection();
                      // if(hasInternet){
                      //Listen for callback URL
                      // check if navigation url contains parameter
                      if (navigation.url.contains('reference')) {
                        setState(() {
                          successfulTransaction = false;
                        });
                        // get parameter value
                        var reference = navigation.url.split('reference=')[1];
                        print("Request successful");
                        //Allow back button
                        sendData(reference, arguments['plan_id'],
                            arguments['amount']);
                      }
                      return NavigationDecision.navigate;
                      // }else{
                      //   Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                      //   return NavigationDecision.prevent;
                      // }
                    },
                    onProgress: (int progress) {
                      print("progress $progress%");
                    },
                    javascriptChannels: <JavascriptChannel>{
                      _toasterJavascriptChannel(context)
                    },
                    onWebResourceError: (e) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);
                      showToast("No Internet Connection");
                    });
              },
            ),
          ),
        ),
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          showSnackBar(context, message.toString());
        });
  }
}
