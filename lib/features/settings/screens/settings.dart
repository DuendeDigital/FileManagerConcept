import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/material.dart';
import 'package:keepit/constants/hide_notification.dart';
import 'package:keepit/constants/utils/files.dart';
import 'package:keepit/features/home/dashboard.dart';
import 'package:keepit/main.dart';
import 'package:keepit/models/list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:keepit/providers/category_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:keepit/common/subscriptions.dart';
import 'package:keepit/constants/custom_toast.dart' as CustomToast;

import '../../../constants/global_variables.dart';

class Settings extends StatefulWidget {
  static const String routeName = '/settings';
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  List<ListModel> items = [
    ListModel(Colors.blue, const Icon(Icons.notifications, color: Colors.white),
        'New File Notification'),
    ListModel(
        Colors.blue,
        const Icon(Icons.hide_image_sharp, color: Colors.white),
        'Show Hidden Files'),
    ListModel(Colors.blue, const Icon(Icons.settings, color: Colors.white),
        'Reset Keepit Statuses'),
  ];

  bool isSwitchedFT = false;

  @override
  void initState() {
    super.initState();
    checkSub();
    getSwitchValues();
    // setTask(false);
    initialiseNotification();

  }

  getSwitchValues() async {
    isSwitchedFT = await getSwitchState();
    setState(() {});
  }

  Future<bool> saveSwitchState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("showHidden", value);
    print('showHidden Value saved $value');
    return prefs.setBool("showHidden", value);
  }

  Future<bool> getSwitchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isSwitchedFT = prefs.getBool('showHidden') ?? false;
    print(isSwitchedFT);

    return isSwitchedFT;
  }

  bool hideNotis = false;
  setTask(bool doTask) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("hideNotifications", doTask);
    hideNotis = doTask;
    print("Notis is $doTask");
  }

  initialiseNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hideNotis = prefs.getBool("hideNotifications")!;
    });
  }

  bool subbed = true;
  checkSub() async {
    setState(() async {
      subbed = await Subscription().checkSubscription();
    });
  }

   Widget loader(){
   return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
     children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 180.0),
            child: Column(
              children: [
                CircularProgressIndicator(
                    backgroundColor: Colors.blue[900],
                    color: Colors.yellow[600],
                    strokeWidth: 10,
                ),
                const SizedBox(height: 20.0),
                const Text('Please wait...',textAlign: TextAlign.center,style: TextStyle(color: Color.fromRGBO(22,86,176,1,))),
              ],
            ),
          ),
        )
     ],
   );     
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        //Navigator.pushNamed(context, '/home');
        Provider.of<CategoryProvider>(context, listen: false)
            .getImages('image');
        Navigator.pop(context);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(43, 104, 210, 1),
          elevation: 0,
          leading: ExpandTapWidget(
              tapPadding: EdgeInsets.all(155.0),
              onTap: () {
                Provider.of<CategoryProvider>(context, listen: false)
                    .getImages('image');
                Navigator.pop(context);
                //Navigator.pushNamed(context, '/home');
              },
              child: Container(width: 200.0, child: Icon(Icons.arrow_back))),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Settings'),
              Image.asset(
                "assets/logo_screens.png",
                width: 40,
                height: 40,
              )
            ],
          ),
        ),
        body: Container(
            child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromRGBO(43, 104, 210, 1),
                  ),
                  child: Icon(Icons.audio_file, color: Colors.white),
                  alignment: Alignment.center,
                ),
                title: Row(
                  children: [
                    Text('Show Hidden Files',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(78, 78, 78, 1))),
                    SizedBox(width: 10),
                    subbed ? Container() : Image.asset('assets/badge.png', width: 40, height: 40),
                  ],
                ),
                trailing: Switch(
                  value: isSwitchedFT,
                  onChanged: (bool value) async {
                    var isSubbed = await Subscription().checkSubscription();
                    if (isSubbed == true) {
                      setState(() {
                        isSwitchedFT = value;
                        saveSwitchState(value);
                        print('Saved state is $isSwitchedFT');
                        Provider.of<CategoryProvider>(context, listen: false)
                            .getImages('image');
                        //switch works
                      });
                    } else {
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
                        builder: (context) => CustomToast.CustomToast()
                            .CustomToastNotification(
                                Colors.red,
                                Colors.amber,
                                "assets/close.png",
                                "Subscription Required",
                                "Please subscribe to continue using this feature",
                                context),
                      );
                    }
                    print(isSwitchedFT);
                  },
                  activeTrackColor: Color.fromARGB(255, 81, 141, 245),
                  activeColor: const Color.fromRGBO(43, 104, 210, 1),
                ),
                onTap: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromRGBO(43, 104, 210, 1),
                  ),
                  child: Icon(Icons.notifications, color: Colors.white),
                  alignment: Alignment.center,
                ),
                title: Text('Hide Notifications',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(78, 78, 78, 1))),
                trailing: Switch(
                  value: hideNotis,
                  onChanged: (bool value) {
                    setState(() {
                      setTask(value);

                      // isSwitchedFT = value;
                      // saveSwitchState(value);
                      // print('Saved state is $isSwitchedFT');
                      //switch works
                    });
                    print(isSwitchedFT);
                  },
                  activeTrackColor: Color.fromARGB(255, 81, 141, 245),
                  activeColor: const Color.fromRGBO(43, 104, 210, 1),
                ),
                onTap: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromRGBO(43, 104, 210, 1),
                  ),
                  child: Icon(Icons.settings, color: Colors.white),
                  alignment: Alignment.center,
                ),
                title: Text('Reset Keepit Statuses',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(78, 78, 78, 1))),
                trailing: ElevatedButton(
                    onPressed: () {
                      TextEditingController _textFieldController =
                          TextEditingController();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Reset Keepit Statuses',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(22, 86, 176, 1))),
                              content: Text(
                                  "Keepit statuses will be reset and will no longer show in sorted files.\nFiles in the bin will be moved to a folder called 'Restored.'"),
                              actions: [
                                GestureDetector(
                                  child: const Icon(Icons.cancel_rounded,
                                      color: Colors.red, size: 40.0),
                                  onTap: () {
                                    print('Close Sign');
                                    _textFieldController.clear();
                                    Navigator.pop(context);
                                  },
                                ),
                                GestureDetector(
                                  child: ElevatedButton(
                                      onPressed: () async {
                                      
                                        showModalBottomSheet(
                                            context: context,
                                            enableDrag: false,
                                            isDismissible: false,
                                            isScrollControlled: false,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20.0),
                                            )),
                                            // backgroundColor: Colors.transparent,
                                            builder: (context) => Padding(
                                              padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                                              child: loader(),
                                            ),
                                          );

                                        bool status = await KeepFiles().resetList();
                                        if (status) {
                                            Future.delayed(Duration(seconds: 2), () {
                                               Navigator.of(context).pop();
                                               Navigator.of(context).pop();
                                              showModalBottomSheet(
                                                context: context,
                                                enableDrag: true,
                                                isDismissible: true,
                                                isScrollControlled: true,
                                                backgroundColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                  top: Radius.circular(20.0),
                                                )),
                                                constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      25,
                                                ),
                                                builder: (context) => CustomToast
                                                        .CustomToast()
                                                    .CustomToastNotification(
                                                        Colors.green,
                                                        Colors.amber,
                                                        "assets/check.png",
                                                        "Statuses Cleared",
                                                        "Keepit Statuses has successfully reset and files have been restored from the bin",
                                                        context),
                                              );
                                            });

                                          // KeepFiles().resetList();
                                          Provider.of<CategoryProvider>(context,
                                                  listen: false)
                                              .getImages('image');
                                        } else {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          showModalBottomSheet(
                                            context: context,
                                            enableDrag: true,
                                            isDismissible: true,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                              top: Radius.circular(20.0),
                                            )),
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  25,
                                            ),
                                            builder: (context) => CustomToast
                                                    .CustomToast()
                                                .CustomToastNotification(
                                                    Colors.red,
                                                    Colors.amber,
                                                    "assets/close.png",
                                                    "Keepit Statuses Empty",
                                                    "There are no set Keepit statuses",
                                                    context),
                                          );
                                        }
                                      },
                                      child: Text("Okay")),

                                  // const Icon(Icons.add,
                                  // color: GlobalVariables.secondaryColor, size: 40.0),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    KeepFiles().resetList();
                                    KeepFiles().resetListbinAction();
                                  },
                                ),
                              ],
                            );
                          });
                    },
                    child: Text("Reset")),
                onTap: () {},
              ),
            ),
          ],
        )),
      ),
    );
  }
}
