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

class SubscriptionScreen extends StatefulWidget {
  static const String routeName = '/subscription';
  const SubscriptionScreen({Key? key}) : super(key: key);
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
//Globals
  bool hasInternet = false;
  @override
  void initState() {
    super.initState();
    workmanager.KeepApp().pause_task();
  }

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

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    return WillPopScope(
      onWillPop: () async => workmanager.KeepApp().enable_task(),
      child: GestureDetector(
        onHorizontalDragUpdate: (updateDetails) {},
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Text("Keepit Pro | Manage Subscription"),
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
                      // checkInternetconnection();
                      // if (hasInternet) {
                      //Listen for callback URL
                      // check if navigation url contains parameter
                      if (navigation.url.contains('reference')) {
                        // get parameter value
                        var reference = navigation.url.split('reference=')[1];
                        print("Request successful");
                      }
                      return NavigationDecision.navigate;
                      // } else {
                      //   Navigator.pushNamedAndRemoveUntil(
                      //       context, HomeScreen.routeName, (route) => false);
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
