import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:keepit/constants/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HideNotification {
  setValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _runOnce = prefs.getString('_runOnce') ?? 'false';

    if (_runOnce == 'false') {
      await prefs.setString('_runOnce', 'true');
      return true;
    } else {
      return false;
    }
  }
}
