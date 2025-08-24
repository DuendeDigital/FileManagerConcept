import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:keepit/constants/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Subscription {
  checkInternetconnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  checkSubscription() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sub_active = prefs.getString('sub_active');
    String? sub_end_date = prefs.getString('sub_end_date');
    String? sub_plan = prefs.getString('sub_plan');
    String? sub_id = prefs.getString('sub_id');
    String? uid = prefs.getString('id');
    String? customer_id = prefs.getString('customer_id');
    if (sub_active == null) {
      prefs.setString('sub_active', 'false');
      print("Subscription: ${sub_active}");
      return false;
    } else {
      // Recheck the subscription in case the date server not checked for a while
      if (sub_end_date != null) {
        try {
          var intenetStatus = await checkInternetconnection();
          if (intenetStatus == true) {
            if (sub_end_date != "none") {
              if (DateTime.parse(sub_end_date).isBefore(DateTime.now())) {
                prefs.setString('sub_active', 'false');
                print("Subscription internet returned false: ${sub_active}");
                return false;
              } else {
                prefs.setString('sub_active', 'true');
                print("Subscription internet returned false: ${sub_active}");
                return true;
              }
              // http.Response res = await http.post(
              //   Uri.parse('$uri/api/v1/subscription.php'),
              //   body: jsonEncode({
              //     'user_id': uid,
              //     'customer_id': customer_id,
              //   }),
              //   headers: {
              //     'Content-Type': 'application/json; charset=UTF-8',
              //   },
              // );

              // print("The response is: ${res.body}");

              // if (res.statusCode != 200) {
              //   if (DateTime.parse(sub_end_date).isBefore(DateTime.now())) {
              //     prefs.setString('sub_active', 'false');
              //     print("Subscription internet returned false: ${sub_active}");
              //     return false;
              //   } else {
              //     prefs.setString('sub_active', 'true');
              //     print("Subscription internet returned false: ${sub_active}");
              //     return true;
              //   }
              // } else {
              //   await prefs.setString(
              //       'sub_end_date', jsonDecode(res.body)['sub_end_date']);
              //   String sub_end_date = prefs.getString('sub_end_date') ?? "none";

              //   if (DateTime.parse(sub_end_date).isBefore(DateTime.now())) {
              //     prefs.setString('sub_active', 'false');
              //     print("Subscription internet: ${sub_active}");
              //     return false;
              //   } else {
              //     prefs.setString('sub_active', 'true');
              //     print("Subscription internet: ${sub_active}");
              //     return true;
              //   }
              // }
            } else {
              return false;
            }
          } else {
            if (sub_end_date != "none") {
              if (DateTime.parse(sub_end_date).isBefore(DateTime.now())) {
                prefs.setString('sub_active', 'false');
                print("Subscription: ${sub_active}");
                return false;
              } else {
                prefs.setString('sub_active', 'true');
                print("Subscription: ${sub_active}");
                return true;
              }
            } else {
              return false;
            }
          }
        } catch (e) {
          if (DateTime.parse(sub_end_date).isBefore(DateTime.now())) {
            prefs.setString('sub_active', 'false');
            print("Subscription: ${sub_active}");
            return false;
          } else {
            prefs.setString('sub_active', 'true');
            print("Subscription: ${sub_active}");
            return true;
          }
        }
      }
    }
  }
}
