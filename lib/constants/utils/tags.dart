import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keepit/constants/utils/controls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/keepit_log.dart';

class TagControls extends StatelessWidget {
  AwesomeNotifications notification = new AwesomeNotifications();
  List<String> tagnames = [];

  TagControls({super.key}) {
    createTagLists();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  createTagLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('tagNames') == null) {
      List<String> tagNames = [];
      prefs.setStringList('tagNames', tagNames);
    } else {
      print("List already created");
      List<String> tagNames = (prefs.getStringList('tagNames') ?? List.empty());
      print('Your list NAMES  $tagNames');
    }

    if (prefs.getStringList('tagFiles') == null) {
      List<String> tagFiles = [];
      prefs.setStringList('tagFiles', tagFiles);
    } else {
      print("List already created");
      List<String> tagFiles = (prefs.getStringList('tagFiles') ?? List.empty());
      print('Your list FILES $tagFiles');
    }

    if (prefs.getStringList('keepitFiletags') == null) {
      List<String> keepitFiletags = [];
      prefs.setStringList('keepitFiletags', keepitFiletags);
    } else {
      print("List already created");
      List<String> keepitFiletags =
          (prefs.getStringList('keepitFiletags') ?? List.empty());
      print('Your list FILE TAGS $keepitFiletags');
    }
  }

  Future<bool> createTag(String tag_name) async {
    try {
      List return_value = [];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> tagNames = prefs.getStringList('tagNames') ?? List.empty();

      //if tag does not match any other tag names then add to tag list

      for (int i = 0; i < tagNames.length; i++) {
        String tag = tagNames[i].toLowerCase();
        String tag_received = tag_name.toLowerCase();
        print("tag $tag received $tag_received");
        if (tag == tag_received) {
          return_value.add(tag);
        }
      }

      //Set tag
      if (return_value.isEmpty) {
        tagNames.add(tag_name);
        prefs.setStringList('tagNames', tagNames);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> addTagstoFile(String file_path, String tag_name) async {
    createTagLists();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitFiletags =
        (prefs.getStringList('keepitFiletags') ?? List.empty());
    List<String> tagFiles = (prefs.getStringList('tagFiles') ?? List.empty());
    int index = tagFiles.indexOf(file_path);

    //If tag names are blank then remove all tags, else continue
    if (tag_name == "") {
      removeTags(file_path);
      return false;
    } else {
      /*
        Check if file already has tag
        If the file has tags then update tags String at index
        */
      if (index == -1) {
        //Add tag
        tagFiles.add(file_path);
        keepitFiletags.add(tag_name);

        //Set tag
        prefs.setStringList('tagFiles', tagFiles);
        prefs.setStringList('keepitFiletags', keepitFiletags);

        return true;
      } else {
        //Add tag
        tagFiles[index] = file_path;
        keepitFiletags[index] = tag_name;

        // Set tag
        prefs.setStringList('tagFiles', tagFiles);
        prefs.setStringList('keepitFiletags', keepitFiletags);

        return true;
      }
    }
    // clearTags();
  }

  Future<bool> removeTags(String file_path) async {
    try {
      createTagLists();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keepitFiletags =
          (prefs.getStringList('keepitFiletags') ?? List.empty());
      List<String> tagFiles = (prefs.getStringList('tagFiles') ?? List.empty());
      int index = tagFiles.indexWhere((element) => element == file_path);

      if (index == -1) {
        return false;
      } else {
        //Remove at index
        keepitFiletags.removeAt(index);
        tagFiles.removeAt(index);

        //Set tag
        prefs.setStringList('tagFiles', tagFiles);
        prefs.setStringList('keepitFiletags', keepitFiletags);

        print("TAGS REMOVED!");
        return true;
      }
    } catch (e) {
      print("Tag Failed to remove: $e");
      return false;
    }
  }

  deleteTag(String tag_name) async {
    try {
      createTagLists();
      //Get lists and index
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> tagNames = prefs.getStringList('tagNames') ?? List.empty();
      List<String> keepitFiletags =
          (prefs.getStringList('keepitFiletags') ?? List.empty());
      List<String> tagFiles = (prefs.getStringList('tagFiles') ?? List.empty());
      int index = tagNames.indexOf(tag_name);

      //Remove tag
      tagNames.removeAt(index);

      //Remove tags from filetags
      for (int i = 0; i < keepitFiletags.length; i++) {
        if (keepitFiletags[i].contains(",$tag_name,")) {
          keepitFiletags[i].replaceAll(",$tag_name,", ",");
        } else if (keepitFiletags[i].contains(",$tag_name")) {
          keepitFiletags[i].replaceAll(",$tag_name", "");
        } else if (keepitFiletags[i].contains("$tag_name,")) {
          keepitFiletags[i].replaceAll("$tag_name,", "");
        } else if (keepitFiletags[i] == tag_name) {
          removeTags(tagFiles[i]);
        }
      }
      //Set list
      prefs.setStringList('tagNames', tagNames);
      return true;
    } catch (e) {
      print("Tag Failed to delete: $e");
      return false;
    }
  }

  emptyBintags() async {
    createTagLists();
    //Declarations
    var bin_dir = Directory("/storage/emulated/0/keepit/.bin/");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> keepitFiletags =
        (prefs.getStringList('keepitFiletags') ?? List.empty());
    List<String> tagFiles = (prefs.getStringList('tagFiles') ?? List.empty());

    //Only clears bin if the .bin folder is created
    if (bin_dir.existsSync()) {
      //Get all items in the bin and delete the file
      List<FileSystemEntity> bin_files =
          bin_dir.listSync(recursive: false, followLinks: false);

      for (FileSystemEntity file in bin_files) {
        //Get file index on keepit list
        int index = tagFiles.indexWhere((element) => element == file.path);

        //Delete the file, at index, on the keepit list
        tagFiles.removeAt(index);
        keepitFiletags.removeAt(index);

        prefs.setStringList('tagFiles', tagFiles);
        prefs.setStringList('keepitFiletags', keepitFiletags);
      }
      print("OYO TAGS CLEARED NOW MA!");
    }
  }

  clearTags() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitFiletags =
        (prefs.getStringList('keepitFiletags') ?? List.empty());
    List<String> tagFiles = (prefs.getStringList('tagFiles') ?? List.empty());
    List<String> tagNames = (prefs.getStringList('tagNames') ?? List.empty());

    //Clear everything

    keepitFiletags.clear();
    tagFiles.clear();
    tagNames.clear();

    prefs.setStringList('tagFiles', tagFiles);
    prefs.setStringList('keepitFiletags', keepitFiletags);
    prefs.setStringList('tagNames', tagNames);
  }

  void Notify(String title, String body) async {
    notification.createNotification(
        content: NotificationContent(
            id: 1,
            channelKey: "route_to_keepit_log",
            title: title,
            body: body));
  }
}
