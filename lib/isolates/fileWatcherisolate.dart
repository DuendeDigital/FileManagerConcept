import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watcher/watcher.dart';

import 'isolateUtilities.dart';

  void createPrefs() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getStringList("new_files_added") == null){
      List<String> newFilesadded = [];
      await prefs.setStringList("new_files_added", newFilesadded);
    }
  }

  void fileWatcher() async{
    Directory deviceStorage = Directory("/storage/emulated/0/");
    List<FileSystemEntity> foldersInroot = deviceStorage.listSync(recursive: false,followLinks: false);

    List<String> newFilesadded = [];
    createPrefs();
    //Dynamically add watchers
    for(FileSystemEntity path in foldersInroot){
      try{
        if (path.path.contains('/storage/emulated/0/Android/data')) {
        } else if (path.path.contains('/storage/emulated/0/Android/obb/')) {
        } else if (path.path.contains('/storage/emulated/0/Android/.Trash')) {
        } else if (path.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/.Shared')) {
        } else if (path.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/.trash')) {
        } else if (path.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Databases')) {
        } else if (path.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Backups')) {
        } else if (path.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/.StickerThumbs')) {
        } else if (path.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/.Thumbs')) {
        } else if (path.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Voice Notes')) {
        } else if (path.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Stickers')) {
        } else if (path.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Links')) {
        } else if (path.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses')) {
        } else if (path.path.contains(
            '/storage/emulated/0/Android/media/com.google.android.gm')) {
        } else{
          var watcher = DirectoryWatcher(path.path);
          watcher.events.listen(
            (event) {
              //Only show notification if the event is an added file
              if(event.type.toString() == "add"){
                newFilesadded.add(event.path);
                addNewfileTosharedPreflist(event.path);
                sendNewfilesNotification();
              }
            }
          );
        }
      }
      catch(e){
        print("The event being watched is ERROR");
      }
    }
  }

  @pragma('vm:entry-point')
  void begin(String hideNotis) async{
    
    Directory deviceStorage = Directory("/storage/emulated/0/");
    List<FileSystemEntity> foldersInroot = deviceStorage.listSync(recursive: false,followLinks: false);

    //Initialise shared preferences and create lists
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.reload();

    fileWatcher();
      
  }

  class startFilewatcherIsolate{

    startFilewatcherIsolate(){
      FlutterIsolate.spawn(begin,"hideNotis");
    }

    stopIsolate(){
      FlutterIsolate.current.kill();
    }

  }