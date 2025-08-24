import 'dart:convert';
import 'dart:isolate';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:byte_converter/byte_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:keepit/features/auth/screens/auth_screen.dart';
import 'package:keepit/features/auth/services/auth_service.dart';
import 'package:keepit/models/ads_model.dart';
import 'package:keepit/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:keepit/features/splash/screens/splash_screen.dart';
import 'package:keepit/features/home/dashboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:keepit/providers/user_provider.dart';
import 'package:keepit/providers/category_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keepit/constants/utils/check_permission.dart';
import 'package:workmanager/workmanager.dart';
import 'package:logger/logger.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:keepit/constants/utils/controls.dart' as controls;
import 'package:disk_space/disk_space.dart';
import 'package:keepit/constants/utils/files.dart';
import 'package:keepit/features/home/keepit_log.dart';
import 'package:http/http.dart' as http;
import 'package:keepit/common/subscriptions.dart';
import 'package:keepit/constants/navigator_key.dart';
import 'package:keepit/common/ads.dart';
import 'package:is_lock_screen/is_lock_screen.dart';
import 'constants/utils/shared_p.dart';
import 'package:path/path.dart' as p;
import 'isolates/fileWatcherisolate.dart';
void _deleteCacheDir() async {
  final cacheDir = await getTemporaryDirectory();
  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true);
  }
}
Future run_ad() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.reload();
  prefs.setBool("trigger_ad", true);
  print("Bool has been set to true");
  print("After set to true ${prefs.getBool("trigger_ad").toString()}");
}
@pragma('vm:entry-point')
callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    AwesomeNotifications().initialize(
      'resource://drawable/logo',
      [
        NotificationChannel(
            channelKey: "Key1",
            channelName: "Keepit",
            channelDescription: "Awesome Notification",
            defaultColor: GlobalVariables.secondaryColor,
            enableLights: true,
            ledColor: Colors.white,
            playSound: true)
      ],
      // debug: true
    );
    var _fileCount = await CategoryProvider().getAllFilesForIsolate();
    // count files in fileCount
    int fileCountInt = _fileCount.length;
    print("Workmanager filecount is $fileCountInt");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tempStorage = (prefs.getString('tempStorage') ?? "0");
    String fileCount = fileCountInt.toString();
    bool hideNotifications = (prefs.getBool("hideNotifications") ?? false);
    bool _reloadPage = (prefs.getBool("_reloadPage") ?? false);
    switch (taskName) {
      case "StorageSize":
        print('Current temp storage ${tempStorage.toString()}');
        if (tempStorage.isEmpty) {
          prefs.setString("tempStorage", fileCount.toString());
        } else {
          int tempStorageInt = int.parse(tempStorage);
          int fileCountInt = int.parse(fileCount);
          // check if file count is greater than temp storage
          if (fileCountInt > tempStorageInt) {
            prefs.setString("tempStorage", fileCount.toString());
            try {
              if (!hideNotifications) {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: 10,
                    channelKey: "Key1",
                    title: "New Files Added?",
                    body:
                        "Looks like you've added some new files, would you like to sort them?",
                    // bigPicture: 'assets/newfiles.png',
                    notificationLayout: NotificationLayout.BigText,
                  ),
                  actionButtons: <NotificationActionButton>[
                    NotificationActionButton(key: 'yes', label: 'All Files'),
                    NotificationActionButton(key: 'no', label: 'Dismiss'),
                  ],
                );
              } else {}
            } catch (err) {
              Logger().e(err.toString());
              throw Exception(err);
            }
          } else {
            prefs.setString("tempStorage", fileCount.toString());
          }
        }
        print("Switch 1 Ran task: $taskName");
        break;
      case "execute_keep_for":
        bool execute = await KeepFiles().move_to_bin();
        if (execute == true) {
          print("Switch 2 added files to bin. Add notification here");
          try {
            if (!hideNotifications) {
              AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: 11,
                  channelKey: "Key1",
                  title: "We moved some files to the keepit bin!",
                  body:
                      "Some files are set to delete soon. Check your keepit bin to manage them.",
                  notificationLayout: NotificationLayout.BigText,
                ),
                // actionButtons: <NotificationActionButton>[
                //   NotificationActionButton(key: 'bin', label: 'Go to bin'),
                //   NotificationActionButton(key: 'no', label: 'Dismiss'),
                // ],
              );
            } else {}
          } catch (err) {
            Logger().e(err.toString());
            throw Exception(err);
          }
        }
        print("Switch 2 Ran task: $taskName");
        break;
      case "delete_from_bin":
        KeepFiles().clearBin();
        print("Switch 3 Ran task: $taskName");
        break;
      case "clear_cache":
        _deleteCacheDir();
        print("Switch 4 Ran task: $taskName");
        break;
      case "take_over_ad":
        print('Came to trigger take_over_ad');
        // await AwesomeNotifications().createNotification(
        //     content: NotificationContent(
        //   id: 10,
        //   channelKey: "Key1",
        //   title: "Ads Triggered?",
        //   body:
        //       "Ads Triggered?",
        //   notificationLayout: NotificationLayout.BigText,
        // ));
        await run_ad();
        break;
      default:
        //ToDo
        break;
    }
    return Future.value(true);
  });
}
Future<void> main() async {
  await dotenv.load(fileName: '.env');
  ShareP.preferences = await SharedPreferences.getInstance();
  // var watcher = DirectoryWatcher(p.absolute("/storage/emulated/0/DCIM/"));
  // watcher.events.listen((event) {
  //   print('The new files are ${event.toString()}');
  // });
  AwesomeNotifications().initialize(
    'resource://drawable/logo',
    [
      NotificationChannel(
          channelKey: "Key1",
          channelName: "Keepit",
          channelDescription: "Awesome Notification",
          defaultColor: GlobalVariables.secondaryColor,
          enableLights: true,
          ledColor: Colors.white,
          playSound: true)
    ],
    // debug: true
  );
  WidgetsFlutterBinding.ensureInitialized();
  // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().initialize(callbackDispatcher);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => CategoryProvider()),
  ], child: const KeepApp()));
}
class KeepApp extends StatefulWidget {
  const KeepApp({Key? key}) : super(key: key);
  @override
  State<KeepApp> createState() => _KeepAppState();
  //Pause a task in payment and subscription page
  void pause_task() {
    Workmanager().cancelByUniqueName("taskFive");
    print('Task has been paused');
  }
  Future<bool> enable_task() async {
    Workmanager().registerPeriodicTask("taskFive", "take_over_ad",
        frequency: Duration(minutes: 15), initialDelay: Duration(seconds: 15));
    print('Task has been enabled');
    return true;
  }
}
class _KeepAppState extends State<KeepApp> with WidgetsBindingObserver {
  final AuthService authService = AuthService();
  bool _initState = false;
  checkNotificationPermission() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      } else {
        // AwesomeNotifications().createNotification(
        //   content: NotificationContent(
        //     id: 10,
        //     channelKey: "Key1",
        //     title: "New Files Added?",
        //     body:
        //         "Looks like you've added some new files, would you like to sort them?",
        //     notificationLayout: NotificationLayout.BigText,
        //   ),
        //   actionButtons: <NotificationActionButton>[
        //     NotificationActionButton(key: 'yes', label: 'All Files'),
        //     NotificationActionButton(key: 'no', label: 'Dismiss'),
        //   ],
        // );
      }
    });
  }
  void _checkPermission(BuildContext context) async {
    var result = await check_permission().checkPermission();
    if (result[0] == "success") {
      if (_initState == false) {
        checkInternetconnection();
        checkSubscription();
        checkNotificationPermission();
        AwesomeNotifications().actionStream.listen(
          (ReceivedAction receivedAction) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            bool _reloadPage = (prefs.getBool("_reloadPage") ?? false);
            if (receivedAction.buttonKeyPressed == 'yes') {
              //Your code goes here
              print(
                  "keep me notification is ${receivedAction.buttonKeyPressed}");
              _reloadPage = true;
              prefs.setBool("_reloadPage", _reloadPage);
            } else if (receivedAction.buttonKeyPressed == 'no') {
              //Your code goes here
              print(
                  "keep me notification is ${receivedAction.buttonKeyPressed}");
            }
            print(
                "keep me notification is no button ${receivedAction.buttonKeyPressed}");
            _reloadPage = true;
            prefs.setBool("_reloadPage", _reloadPage);
            //Here if the user clicks on the notification itself
            //without any button
          },
        );
        // AwesomeNotifications().actionStream.listen((notification) {
        //   print("keep me notification is $notification");
        //   Navigator.pushNamed(context, '/all_files').then((_) {
        //     setState(() {
        //       // Provider.of<CategoryProvider>(context, listen: false)
        //       //     .getImages('image');
        //     });
        //   });
        // });
        //Workmanager().cancelAll();
        Workmanager().registerPeriodicTask(
          "taskOne",
          "StorageSize",
          frequency: Duration(minutes: 15),
          initialDelay: Duration(seconds: 10),
        );
        Workmanager().registerPeriodicTask(
          "taskTwo",
          "execute_keep_for",
          frequency: Duration(minutes: 25),
          initialDelay: Duration(seconds: 20),
        );
        Workmanager().registerPeriodicTask(
          "taskThree",
          "delete_from_bin",
          frequency: Duration(hours: 1),
          initialDelay: Duration(seconds: 30),
        );
        Workmanager().registerPeriodicTask(
          "taskFour",
          "clear_cache",
          frequency: Duration(hours: 12),
          initialDelay: Duration(seconds: 40),
        );
        Workmanager().registerPeriodicTask(
          "taskFive",
          "take_over_ad",
          frequency: Duration(minutes: 20),
          initialDelay: Duration(seconds: 50),
        );
        // Workmanager().registerOneOffTask(
        //   "taskFive",
        //   "take_over_ad",
        //   initialDelay: Duration(minutes: 1),
        // );
        Subscription().checkSubscription();
        _initState = true;
      }
    } else {
      try {
        SystemNavigator.pop();
      } catch (e) {
        print("$e");
      }
    }
  }
  var ActiveConnection = false;
  checkInternetconnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          ActiveConnection = true;
        });
        return true;
      }
    } on SocketException catch (_) {
      setState(() {
        ActiveConnection = false;
      });
      return false;
    }
  }
  Future call_ads() async {
    //CHECK VIDEO AD BOOLEAN
    final prefs = await SharedPreferences.getInstance();
    prefs.reload();
    String trigger_ad = prefs.getBool("trigger_ad").toString();
    bool AppStatus = prefs.getBool("AppActive") ?? false;
    if (trigger_ad == "true") {
      final subscription_status = await Subscription().checkSubscription();
      if (subscription_status == false) {
        if (AppStatus) {
          print('App is Active');
          prefs.reload();
          await prefs.setBool("trigger_ad", false);
          ads().check_internet();
        } else {
          print('App is Inactive');
        }
      }
      print('Back to false');
    } else {
      print('Trigger ad is empty');
    }
    // print("Trigger now ${trigger_ad}");
  }
  Future initial_value_ad() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("trigger_ad", false);
    print('Initial set ${prefs.getBool("trigger_ad")}');
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
              http.Response res = await http.post(
                Uri.parse('$uri/api/v1/subscription.php'),
                body: jsonEncode({
                  'user_id': uid,
                  'customer_id': customer_id,
                }),
                headers: {
                  'Content-Type': 'application/json; charset=UTF-8',
                },
              );
              print("Server response is: ${res.body}");
              if (res.statusCode != 200) {
                if (DateTime.parse(sub_end_date).isBefore(DateTime.now())) {
                  prefs.setString('sub_active', 'false');
                  print("Subscription internet server returned: ${sub_active}");
                  return false;
                } else {
                  prefs.setString('sub_active', 'true');
                  print("Subscription internet server returned: ${sub_active}");
                  return true;
                }
              } else {
                await prefs.setString(
                    'sub_end_date', jsonDecode(res.body)['sub_end_date']);
                String sub_end_date = prefs.getString('sub_end_date') ?? "none";
                if (DateTime.parse(sub_end_date).isBefore(DateTime.now())) {
                  prefs.setString('sub_active', 'false');
                  print("Subscription internet: ${sub_active}");
                  return false;
                } else {
                  prefs.setString('sub_active', 'true');
                  print("Subscription internet: ${sub_active}");
                  return true;
                }
              }
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
  Timer? timer_ads;
  void startBackgroundservices() async {
    FlutterBackgroundAndroidConfig androidConfig =
        const FlutterBackgroundAndroidConfig();
    bool success =
        await FlutterBackground.initialize(androidConfig: androidConfig);
    bool success2 = await FlutterBackground.enableBackgroundExecution();
    if (success) {
      print("The event being watched is SUCCESSFUL BG IMPLEMENTED");
      startFilewatcherIsolate();
    }
  }
  @override
  void initState() {
    super.initState();
    authService.getUserData(context: context);
    initial_value_ad();
    // startTimer();
    timer_ads = Timer.periodic(Duration(seconds: 20), (Timer t) => call_ads());
    WidgetsBinding.instance.addObserver(this);
    KeepFiles().createKeepLists();
    startBackgroundservices();
    initiateAppstate();
  }
  @override
  void dispose() {
    timer_ads?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void initiateAppstate() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.reload();
        prefs.setBool('AppActive', true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('app resumed');
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.reload();
      await prefs.setBool('AppActive', true);
    }else{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.reload();
      await prefs.setBool('AppActive', false);
    }
  }
  @override
  Widget build(BuildContext context) {
    _checkPermission(context);
    return MaterialApp(
      title: 'Kepp It App',
      theme: ThemeData(
          scaffoldBackgroundColor: GlobalVariables.backgroundColor,
          colorScheme: const ColorScheme.light(
            primary: GlobalVariables.secondaryColor,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0.0,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
          primarySwatch: Colors.blue,
          fontFamily: 'JosefinSans'),
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigatorKey.navKey,
      onGenerateRoute: (settings) => generateRoute(settings),
      home: Provider.of<UserProvider>(context).user.token.isNotEmpty
          ? const HomeScreen()
          : const SplashScreen(),
    );
  }
}
void Notify(String title, String body) async {
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 1, channelKey: "Key1", title: title, body: body));
}