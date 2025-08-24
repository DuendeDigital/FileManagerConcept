import 'dart:io';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class InternetCheck extends StatefulWidget {
  const InternetCheck({super.key});

  @override
  State<InternetCheck> createState() => _InternetCheckState();
}

class _InternetCheckState extends State<InternetCheck> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  var ActiveConnection = false;
  void checkInternetconnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          ActiveConnection = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        ActiveConnection = false;
      });
    }
  }


}