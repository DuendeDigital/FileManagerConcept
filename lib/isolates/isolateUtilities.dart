import 'dart:io';
import 'dart:isolate';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watcher/watcher.dart';

  void sendNewfilesNotification() async{
    try{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    print("New files are: About to be checked ${prefs.getBool('AppActive')}");
    if( prefs.getBool('AppActive') == null ||  prefs.getBool('AppActive') == true){
      print("New files are: App Active");
    }else{
      if( prefs.getBool('hideNotifications') == true){
        print("New files are: hide notis");
      }else{
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 10,
            channelKey: "Key1",
            title: "New Files Added?",
            body: "Looks like you've added some new files, would you like to sort them?",
            notificationLayout: NotificationLayout.BigText,
          ),
          actionButtons: <NotificationActionButton>[
            NotificationActionButton(key: 'yes', label: 'All Files'),
            NotificationActionButton(key: 'no', label: 'Dismiss'),
          ],
        );
      }
    }
    }catch(e){
      print("New files are: Catch error $e");
    }
  }

  void addNewfileTosharedPreflist(String filePath) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //Get Shared Prefs list and add new value
    List<String> newFiles = prefs.getStringList("new_files_added")!;
    newFiles.add(filePath);
    print("New files are: $newFiles");
    //Set list
    await prefs.setStringList("new_files_added", newFiles);
  }