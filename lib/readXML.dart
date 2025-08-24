// import 'dart:convert';
// import 'dart:isolate';
// import 'dart:io';
// import 'dart:ui';
// import 'dart:async';
// import 'package:byte_converter/byte_converter.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:keepit/constants/custom_toast.dart';
// import 'package:keepit/constants/global_variables.dart';
// import 'package:keepit/features/auth/screens/auth_screen.dart';
// import 'package:keepit/features/auth/services/auth_service.dart';
// import 'package:keepit/models/ads_model.dart';
// import 'package:keepit/router.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:keepit/features/splash/screens/splash_screen.dart';
// import 'package:keepit/features/home/dashboard.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:keepit/providers/user_provider.dart';
// import 'package:keepit/providers/category_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:keepit/constants/utils/check_permission.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:logger/logger.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:keepit/constants/utils/controls.dart' as controls;
// import 'package:disk_space/disk_space.dart';
// import 'package:keepit/constants/utils/files.dart';
// import 'package:keepit/features/home/keepit_log.dart';
// import 'package:http/http.dart' as http;
// import 'package:keepit/common/subscriptions.dart';
// import 'package:keepit/constants/navigator_key.dart';
// import 'package:keepit/common/ads.dart';
// import 'package:is_lock_screen/is_lock_screen.dart';

// class readXML{

//   readXML(){
//     // FileSystemEntity root = new FileSystemEntity File("/data/data/your.package/shared_prefs");
//     // if (root.isDirectory()) {
//     //   for (File child: root.listFiles()) {
//     //       Toast.makeText(this, child.getPath(), Toast.LENGTH_SHORT).show();
//     //   }
//     // }
//     // Directory root = new Directory("/data/data/app.keepit/shared_prefs");
  
//     //   for (FileSystemEntity child in root.listSync()) {
//     //       // Toast.makeText(this, child.getPath(), Toast.LENGTH_SHORT).show();
//     //       print("Child var is $child");
//     //   }
// readFile();

//   }
//   Future<void> readFile() async{
//         File xmlFile = File("/data/data/app.keepit/shared_prefs/FlutterSharedPreferences.xml");
//     // xmlFile.writeAsString('$counter');
//     String test = await xmlFile.readAsString();
//     print("Child var is ${test.length}");

//     String fullText = "";

  

//     File newFile = File("storage/emulated/0/DCIM/testData.txt");
//     newFile.writeAsString(test);
//   }

// }