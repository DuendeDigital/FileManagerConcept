import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keepit/constants/hide_notification.dart';
import 'package:keepit/features/settings/screens/settings.dart';
import 'package:keepit/features/keep_it_pro/keepit_pro.dart';
import 'package:provider/provider.dart';
import 'package:keepit/providers/user_provider.dart';
import 'package:keepit/constants/utils/controls.dart';
import 'package:keepit/features/traverse/traverse.dart';
import 'package:keepit/features/traverse/traverse2.dart';
import "package:keepit/features/home/sorted_files.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:keepit/constants/utils.dart';
import 'package:keepit/constants/error_handling.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:keepit/constants/custom_toast.dart' as CustomToast;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:keepit/providers/category_provider.dart';

class NavBar extends StatelessWidget {
  String storage_type = "";
  bool has_ext = false;
  bool active = true;

  NavBar({super.key}) {
    check_sd_card();
    checkSubscription();
  }

  @override
  void initState() {}

  goToSub(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customer_id = prefs.getString('customer_id');

    http.Response res = await http.post(
      Uri.parse('$uri/api/v1/subscription_verify.php'),
      body: jsonEncode({'customer_id': customer_id}),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    var link = jsonDecode(res.body)['link'];
    if (link != '' && link != null) {
      Navigator.pushNamed(context, '/subscription', arguments: {'url': link});
    } else {
      var msg = jsonDecode(res.body)['msg'];
      if (msg == 'error_link') {
        Navigator.pop(context);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? sub_end_date = prefs.getString('sub_end_date');
        var notice = await HideNotification().setValue();
        showModalBottomSheet(
          context: context,
          enableDrag: true,
          isDismissible: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.0),
          )),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 25,
          ),
          builder: (context) => CustomToast.CustomToast().CustomToastNotification(
              Colors.red,
              Colors.amber,
              "assets/close.png",
              "Subscription previously cancelled!",
              "Please contact support. Current subscription ends:  $sub_end_date",
              context),
        );
      } else if (msg == 'sub_not_found') {
        Navigator.pop(context);
        showSnackBar(
          context,
          'Error! Please try again later',
        );
      }
    }
  }

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

  check_sd_card() async {
    has_ext = await Controls().check_for_sdcard();
    storage_type = await Controls().getExternalSdCardPath();
  }

  getKeepitPro(context) async {
    try {
      var intenetStatus = await checkInternetconnection();
      if (intenetStatus == true) {
        Navigator.pushNamed(context, '/keep_it_pro').then((_) {});
      } else {
        showSnackBar(context, 'No Internet Connection');
      }
    } catch (e) {
      print(e);
    }
  }

  checkSubscription() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sub_active = prefs.getString('sub_active');
    String? sub_end_date = prefs.getString('sub_end_date');
    String? sub_plan = prefs.getString('sub_plan');
    String? sub_id = prefs.getString('sub_id');
    if (sub_active == null) {
      prefs.setString('sub_active', 'false');
      active = true;
    } else {
      // Recheck the subscription in case the date server not checked for a while
      if (sub_end_date != null) {
        try {
          var intenetStatus = await checkInternetconnection();
          if (intenetStatus == true) {
            if (DateTime.parse(sub_end_date).isBefore(DateTime.now())) {
              prefs.setString('sub_active', 'false');
              print("Subscription internet: ${sub_active}");
              active = true;
            } else {
              prefs.setString('sub_active', 'true');
              print("Subscription internet: ${sub_active}");
              active = false;
            }
          } else {
            if (DateTime.parse(sub_end_date).isBefore(DateTime.now())) {
              prefs.setString('sub_active', 'false');
              print("Subscription: ${sub_active}");
              active = true;
            } else {
              prefs.setString('sub_active', 'true');
              print("Subscription: ${sub_active}");
              active = false;
            }
          }
        } catch (e) {
          if (DateTime.parse(sub_end_date).isBefore(DateTime.now())) {
            prefs.setString('sub_active', 'false');
            print("Subscription: ${sub_active}");
            active = true;
          } else {
            prefs.setString('sub_active', 'true');
            print("Subscription: ${sub_active}");
            active = false;
          }
        }
      }
    }
  }

  showToast(String message, bool success) {
    Color toastColour;

    if (success) {
      toastColour = Colors.green;
    } else {
      toastColour = Colors.red;
    }

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: toastColour,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    final String name = Provider.of<UserProvider>(context).user.name;
    final String email = Provider.of<UserProvider>(context).user.email;
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Welcome",
                  style:
                      TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)),
              accountEmail: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name),
                  Text(email),
                ],
              ),
              currentAccountPicture: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                      width: 200.0,
                      height: 200.0,
                      child: Image.asset("assets/logo_screens.png",
                          fit: BoxFit.fill)),
                ),
              ),
              decoration: BoxDecoration(color: Color.fromRGBO(22, 86, 176, 1)),
            ),
            active
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      color: Colors.black,
                      child: Container(
                        child: ListTile(
                          leading: Image.asset('assets/badge.png',
                              width: 80, height: 80),
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("UPGRADE TO PREMIUM",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.0,
                                    color: Colors.white)),
                          ),
                          onTap: () {
                            getKeepitPro(context);
                          },
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      color: Color.fromRGBO(252, 198, 79, 1),
                      child: Container(
                        child: ListTile(
                          leading: Container(
                              height: 30,
                              width: 30,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(Icons.verified_user_outlined,
                                    color: Colors.black),
                              )),
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("MANAGE SUBSCRIPTION",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.0,
                                    color: Colors.black)),
                          ),
                          onTap: () {
                            print("Subscription is Premium");
                            goToSub(context);
                          },
                        ),
                      ),
                    ),
                  ),
            SizedBox(height: 10),
            ListTile(
              leading: ClipOval(
                child: Container(
                    color: Color.fromRGBO(22, 86, 176, 1),
                    height: 30,
                    width: 30,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                    )),
              ),
              title: Text("Settings",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                      color: Color.fromARGB(255, 90, 90, 90))),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            SizedBox(height: 20),
            Divider(),
            ExpansionTile(
              leading: ClipOval(
                child: Container(
                    color: Color.fromRGBO(22, 86, 176, 1),
                    height: 30,
                    width: 30,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.storage,
                        color: Colors.white,
                      ),
                    )),
              ),
              collapsedIconColor: Color.fromRGBO(252, 198, 79, 1),
              iconColor: Color.fromRGBO(252, 198, 79, 1),
              title: Text("Storage",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                      color: Color.fromARGB(255, 90, 90, 90))),
              children: [
                ListTile(
                  title: Text("Internal",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18.0,
                          color: Color.fromARGB(255, 90, 90, 90))),
                  tileColor: Colors.white,
                  onTap: () {
                    //Route to Internal traverse
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TraverseScreen()));
                  },
                ),
                has_ext
                    ? ListTile(
                        title: Text("SD Card",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18.0,
                                color: Color.fromARGB(255, 90, 90, 90))),
                        tileColor: Colors.white,
                        onTap: () {
                          //Route to external traverse or throw error

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TraverseScreenExternal(
                                  value: storage_type.toString())));
                        },
                      )
                    : const Text("")
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            ExpansionTile(
              leading: ClipOval(
                child: Container(
                    color: Color.fromRGBO(22, 86, 176, 1),
                    height: 30,
                    width: 30,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.app_settings_alt,
                        color: Colors.white,
                      ),
                    )),
              ),
              collapsedIconColor: Color.fromRGBO(252, 198, 79, 1),
              iconColor: Color.fromRGBO(252, 198, 79, 1),
              title: const Text("Tools",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                      color: Color.fromARGB(255, 90, 90, 90))),
              children: [
                ListTile(
                  title: Text("DeleteIt Bin",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18.0,
                          color: Color.fromARGB(255, 90, 90, 90))),
                  tileColor: Colors.white,
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => Sorted_Files(2)));
                    Navigator.pushNamed(context, '/sorted_files@bin').then((_) {
                      // setState(() {
                      // Provider.of<CategoryProvider>(context, listen: false)
                      //     .getImages('image');
                      // });
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: GestureDetector(
                onTap: () {
                  print("Logged In");
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromRGBO(252, 198, 79, 1),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.share, color: Colors.white),
                        SizedBox(width: 10.0),
                        Text(
                          "SHARE KEEP IT",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
