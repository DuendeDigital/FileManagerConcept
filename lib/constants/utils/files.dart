import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keepit/constants/utils/controls.dart';
import 'package:keepit/constants/utils/shared_p.dart';
import 'package:keepit/constants/utils/tags.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/keepit_log.dart';

class KeepFiles extends StatelessWidget {
  AwesomeNotifications notification = new AwesomeNotifications();

  KeepFiles({super.key}) {}

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<void> createKeepLists() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    if (ShareP.preferences.getStringList('keepitfiles') == null || ShareP.preferences.getStringList('keepitStatus') == null || ShareP.preferences.getStringList('keepitDate') == null) {
      List<String> keepitfiles = [];
      List<String> keepitStatus = [];
      List<String> keepitDate = [];

      await ShareP.preferences.setStringList('keepitfiles', keepitfiles);
      await ShareP.preferences.setStringList('keepitStatus', keepitStatus);
      await ShareP.preferences.setStringList('keepitDate', keepitDate);

      await ShareP.preferences.setBool('createkeepitlist', true);
    } else {
      //  ShareP.preferences.setBool('createkeepitlist', true);
      print("List already created");
      List<String> keepitfiles =
          (ShareP.preferences.getStringList('keepitfiles') ?? List.empty());
      print('Your keepitfiles list  $keepitfiles');

      List<String> keepitStatus =
          (ShareP.preferences.getStringList('keepitStatus') ?? List.empty());
      print('Your keepitStatus list  $keepitStatus');

      List<String> keepitDate =
          (ShareP.preferences.getStringList('keepitDate') ?? List.empty());
      print('Your keepitDate list  $keepitDate');

    }


    //Deleted items list
    if (ShareP.preferences.getStringList('deletedFiles') == null) {
      List<String> deletedFiles = [];
      await ShareP.preferences.setStringList('deletedFiles', deletedFiles);
    } else {
      print("List already created");
      List<String> deletedFiles =
          (ShareP.preferences.getStringList('deletedFiles') ?? List.empty());
      //print('Your list  $deletedFiles');
    }
  }

  Future<bool> addToList(String file, String val, String date) async {
 

    List return_value = [];
    // SharedPreferences prefs = await SharedPreferences.getInstance();
     List<String> keepitfiles =
        (ShareP.preferences.getStringList('keepitfiles') ?? List.empty());
    List<String> keepitStatus =
        (ShareP.preferences.getStringList('keepitStatus') ?? List.empty());
    List<String> keepitDates =
        (ShareP.preferences.getStringList('keepitDate') ?? List.empty());

    if (keepitfiles.contains(file)) {
      int index = keepitfiles.indexWhere((element) => element == file);
      keepitStatus[index] = val;
      keepitDates[index] = date;

      await ShareP.preferences.setStringList('keepitStatus', keepitStatus);
      await ShareP.preferences.setStringList('keepitDate', keepitDates);
      return_value.add(file);
    } else {
      print('Initially list is empty');
      keepitfiles.add(file);
      keepitStatus.add(val);
      keepitDates.add(date);

      await ShareP.preferences.setStringList('keepitfiles', keepitfiles);
      await ShareP.preferences.setStringList('keepitStatus', keepitStatus);
      await ShareP.preferences.setStringList('keepitDate', keepitDates);
      return_value.add(file);
    }

    if (return_value.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteFromList(String file) async {
 
    List return_value = [];
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitfiles;
    List<String> keepitStatus;
    List<String> keepitDates;

    keepitfiles = (ShareP.preferences.getStringList('keepitfiles') ?? List.empty());
    keepitStatus = (ShareP.preferences.getStringList('keepitStatus') ?? List.empty());
    keepitDates = (ShareP.preferences.getStringList('keepitDate') ?? List.empty());

    var bin_folder = Directory("/storage/emulated/0/keepit/.bin");
    if (!await bin_folder.exists()) {
      bin_folder.createSync();
    }

    File file_to_move = File(file);
    file_to_move.copy("/storage/emulated/0/keepit/.bin/" + file_to_move.path.split("/").last);
    var newFile = File("/storage/emulated/0/keepit/.bin/" + file_to_move.path.split("/").last);

    DateTime today = DateTime.now();
    DateTime duration = DateTime(today.year, today.month, today.day + 1, today.hour, today.minute);

    if (keepitfiles.contains(file)) {
      int index = keepitfiles.indexWhere((element) => element == file);
      keepitfiles.removeAt(index);
      keepitStatus.removeAt(index);
      keepitDates.removeAt(index);

      await ShareP.preferences.setStringList('keepitfiles', keepitfiles);
      await ShareP.preferences.setStringList('keepitStatus', keepitStatus);
      await ShareP.preferences.setStringList('keepitDate', keepitDates);

      keepitfiles.add(newFile.path);
      keepitStatus.add('keep_for');
      keepitDates.add(duration.toString());

      await ShareP.preferences.setStringList('keepitfiles', keepitfiles);
      await ShareP.preferences.setStringList('keepitStatus', keepitStatus);
      await ShareP.preferences.setStringList('keepitDate', keepitDates);

      return_value.add(file);
    } else {
      keepitfiles.add(newFile.path);
      keepitStatus.add('keep_for');
      keepitDates.add(duration.toString());

      await ShareP.preferences.setStringList('keepitfiles', keepitfiles);
      await ShareP.preferences.setStringList('keepitStatus', keepitStatus);
      await ShareP.preferences.setStringList('keepitDate', keepitDates);

      return_value.add(file);
    }

    if (newFile.existsSync() && return_value.isNotEmpty) {
      file_to_move.delete(recursive: false);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteFromList2(String file) async {
    await createKeepLists();
    //Declarations
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitfiles;
    List<String> keepitStatus;
    List<String> keepitDates;

    keepitfiles = (prefs.getStringList('keepitfiles') ?? List.empty());
    keepitStatus = (prefs.getStringList('keepitStatus') ?? List.empty());
    keepitDates = (prefs.getStringList('keepitDate') ?? List.empty());

    int index = keepitfiles.indexWhere((element) => element == file);

    DateTime today = DateTime.now();
    DateTime duration = DateTime(
        today.year, today.month, today.day + 1, today.hour, today.minute);
    //DateTime duration = DateTime(
    //today.year, today.month, today.day, today.hour, today.minute + 5);
    var bin_folder = Directory("/storage/emulated/0/keepit/.bin");

    if (!await bin_folder.exists()) {
      bin_folder.createSync();
    }

    File new_file =
        await File(file).rename("${bin_folder.path}/${file.split("/").last}");

    if (new_file.existsSync()) {}
    if (index == -1) {
      addToList(new_file.path, 'keep_for', duration.toString());
      return true;
    } else {
      keepitfiles[index] = new_file.path;
      keepitStatus[index] = 'keep_for';
      keepitDates[index] = duration.toString();

      prefs.setStringList('keepitfiles', keepitfiles);
      prefs.setStringList('keepitStatus', keepitStatus);
      prefs.setStringList('keepitDate', keepitDates);
      return true;
    }
  }

  Future<bool> move_to_bin() async {
    List return_value = [];
    print("Move to bin initialised");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitfiles;
    List<String> keepitStatus;
    List<String> keepitDates;

    keepitfiles = (prefs.getStringList('keepitfiles') ?? List.empty());
    keepitStatus = (prefs.getStringList('keepitStatus') ?? List.empty());
    keepitDates = (prefs.getStringList('keepitDate') ?? List.empty());

    int daysBetween(DateTime from, DateTime to) {
      from = DateTime(from.year, from.month, from.day);
      to = DateTime(to.year, to.month, to.day);
      return (to.difference(from).inHours / 24).round();
    }

    var bin_folder = Directory("/storage/emulated/0/keepit/.bin");

    if (!await bin_folder.exists()) {
      bin_folder.createSync();
    }

    for (int i = 0; i < keepitfiles.length; i++) {
      int index = i;
      if (keepitStatus[i] == 'keep_for') {
        File file = File(keepitfiles[i]);

        final DateTime date1 = DateTime.parse(keepitDates[i].toString());
        final date2 = DateTime.now();
        final int difference = await daysBetween(date2, date1);
        String fileName = file.path.split('/').last;
        String isBin = '${file.path.split('/')[file.path.split('/').length - 2]}';

        if (difference < 2) {
          // Check if file is in .bin
          if (isBin != ".bin") {
            Controls().move_files([file.path], "/storage/emulated/0/keepit/.bin");
            String newPath = "/storage/emulated/0/keepit/.bin/$fileName";

            keepitfiles[index] = newPath;
            prefs.setStringList('keepitfiles', keepitfiles);
            return_value.add(keepitfiles[index]);
          }
        }
      }
    }

    if (return_value.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  execute_keep_for() async {
    print("Notifi test case");
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keepitfiles;
      List<String> keepitStatus;
      List<String> keepitDates;
      List<String> deletedFiles;
      List<int> index_array = [];
      int complete = 0;
      String deleted_items = "";

      keepitfiles = (prefs.getStringList('keepitfiles') ?? List.empty());
      keepitStatus = (prefs.getStringList('keepitStatus') ?? List.empty());
      keepitDates = (prefs.getStringList('keepitDate') ?? List.empty());

      //Get the index of all keep_for statuses
      for (int i = 0; i < keepitStatus.length; i++) {
        if (keepitStatus[i] == "keep_for") {
          index_array.add(i);
        }
      }

      //Check if the date matches
      for (int index in index_array) {
        DateTime keep_for_date = DateTime.parse(keepitDates[index]);
        if (keep_for_date.day == DateTime.now().day) {
          //Delete file
          deleteFromList(keepitfiles[index]);
          // deletedFiles.add(keepitfiles[index]);
          complete++;
          // deleted_items += "-${keepitfiles[index]}\n";
        } else {
          complete--;
        }
      }

      if (complete > 0) {
        print("See notification");
        Notify("Files deleted",
            "You've marked some files to be deleted today. Well, you can consider the clutter...offically cleared!");
      } else {
        Notify("Error, No files deleted", "");
      }
    } catch (e) {
      print("Multiple files test: DELETE ERR $e");

      Notify("Erro", "Error caught by flutter");
    }
  }

  verifyLists() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keepitfiles;
      List<String> keepitStatus;
      List<String> keepitDates;

      keepitfiles = (prefs.getStringList('keepitfiles') ?? List.empty());
      keepitStatus = (prefs.getStringList('keepitStatus') ?? List.empty());
      keepitDates = (prefs.getStringList('keepitDate') ?? List.empty());

      for (int i = 0; i < keepitfiles.length; i++) {
        File dummy_file = File(keepitfiles[i]);
        if (dummy_file.existsSync()) {
        } else {
          //Remove file from arr
          keepitfiles.removeAt(i);
          keepitStatus.removeAt(i);
          keepitDates.removeAt(i);
        }
      }

      Notify("List Verified", "body");
    } catch (e) {
      print("Verify List Error: $e");
    }
  }

  clearBin() async {
    //Declarations
    var bin_dir = Directory("storage/emulated/0/keepit/.bin");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitfiles;
    List<String> keepitStatus;
    List<String> keepitDates;

    keepitfiles = (prefs.getStringList('keepitfiles') ?? List.empty());
    keepitStatus = (prefs.getStringList('keepitStatus') ?? List.empty());
    keepitDates = (prefs.getStringList('keepitDate') ?? List.empty());

    //Only clears bin if the .bin folder is created
    if (bin_dir.existsSync()) {
      //Get all items in the bin and delete the file
      List<FileSystemEntity> bin_files =
          bin_dir.listSync(recursive: false, followLinks: false);

      for (var x = 0; x < bin_files.length; x++) {
        File file = File(bin_files[x].path);
        String fpath = "/" + file.path.toString();
        int index = keepitfiles.indexWhere((element) => element == fpath);
        //print("Keep me: Bin files is: ${bin_files}");
        //print("Keep me: files is: ${keepitfiles[index]}");
        if (index != -1) {
          if (DateTime.parse(keepitDates[index]).isBefore(DateTime.now())) {
            //print("Keep me: file is: ${keepitfiles[index]}");
            //print("Keep me: date is: ${keepitDates[index]}");
            keepitfiles.removeAt(index);
            keepitStatus.removeAt(index);
            keepitDates.removeAt(index);

            await prefs.setStringList('keepitfiles', keepitfiles);
            await prefs.setStringList('keepitStatus', keepitStatus);
            await prefs.setStringList('keepitDate', keepitDates);

            //Delete File
            File(file.path).delete();
            //Controls().move_files([file.path], "/storage/emulated/0/Pictures");
          }
        }
      }
    } else {
      bin_dir.createSync();
    }
  }

  restoreBin() async {
    /*
      If the bin exists, get all its' files, else create .bin folder
    */
    var bin_dir = Directory("/storage/emulated/0/keepit/.bin/");
    if (bin_dir.existsSync()) {
      List<FileSystemEntity> bin_files = bin_dir.listSync();

      if (bin_files.length > 0) {
        //Open native file picker
        String? selectedDirectory =
            await FilePicker.platform.getDirectoryPath();
        bool isRestrictedfolder =
            selectedDirectory!.contains("storage/emulated/0/keepit");
        if (isRestrictedfolder) {
          restoreBin();
          showToast("You cannot restore files to this location", false);
        } else {
          //Assign files to array
          List<String> files_to_move = [];
          for (FileSystemEntity file in bin_files) {
            files_to_move.add(file.path);
          }
          //MOVE
          Controls().move_files(files_to_move, selectedDirectory);
        }
      }
    } else {
      bin_dir.createSync();
    }
  }

  resetListbinAction() {
    /*
      If the bin exists, get all its' files, else create .bin folder
    */
    var bin_dir = Directory("/storage/emulated/0/keepit/.bin/");
    if (bin_dir.existsSync()) {
      List<FileSystemEntity> bin_files = bin_dir.listSync();

      if (bin_files.length > 0) {
        //Assign files to array
        List<String> files_to_move = [];
        for (FileSystemEntity file in bin_files) {
          files_to_move.add(file.path);
        }

        //Create `Restored folder`
        Controls().create_collection("Restored");

        //MOVE
        Controls()
            .move_files(files_to_move, "storage/emulated/0/keepit/Restored/");

        // showToast("Files have been moved from the bin!", true);
      }
    } else {
      bin_dir.createSync();
    }
  }

  emptyBin() async {
    //Declarations
    var bin_dir = Directory("/storage/emulated/0/keepit/.bin/");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitfiles;
    List<String> keepitStatus;
    List<String> keepitDates;

    keepitfiles = (prefs.getStringList('keepitfiles') ?? List.empty());
    keepitStatus = (prefs.getStringList('keepitStatus') ?? List.empty());
    keepitDates = (prefs.getStringList('keepitDate') ?? List.empty());

    //Only clears bin if the .bin folder is created
    if (bin_dir.existsSync()) {
      //Get all items in the bin and delete the file
      List<FileSystemEntity> bin_files =
          bin_dir.listSync(recursive: false, followLinks: false);

      for (FileSystemEntity file in bin_files) {
        //Get file index on keepit list
        int index = keepitfiles.indexWhere((element) => element == file.path);

        //Delete the file, at index, on the keepit list
        keepitfiles.removeAt(index);
        keepitStatus.removeAt(index);
        keepitDates.removeAt(index);

        prefs.setStringList('keepitfiles', keepitfiles);
        prefs.setStringList('keepitStatus', keepitStatus);
        prefs.setStringList('keepitDate', keepitDates);

        //Delete File
        File(file.path).delete();
        //Controls().move_files([file.path], "/storage/emulated/0/Pictures");
      }
      //Clear all tags on bin files
      // TagControls().emptyBintags();

    } else {
      bin_dir.createSync();
    }
  }

  restoreFile(List<String> files) async {
    //Open native file picker
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    bool isRestrictedfolder =
        selectedDirectory!.contains("storage/emulated/0/keepit");
    if (isRestrictedfolder) {
      return false;
    } else {
      var result = await Controls().move_files(files, selectedDirectory);
      if (result == true) {
        return true;
      } else {
        return false;
      }
    }
  }

  deleteFile(String file) async {
    // await createKeepLists();
    try {
      //Declarations
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keepitfiles;
      List<String> keepitStatus;
      List<String> keepitDates;

      keepitfiles = (prefs.getStringList('keepitfiles') ?? List.empty());
      keepitStatus = (prefs.getStringList('keepitStatus') ?? List.empty());
      keepitDates = (prefs.getStringList('keepitDate') ?? List.empty());

      int index = keepitfiles.indexWhere((element) => element == file);

      if (index == -1) {
        File(file).deleteSync();
        //Controls().move_files([file], "/storage/emulated/0/Pictures");
      } else {
        keepitfiles.removeAt(index);
        keepitStatus.removeAt(index);
        keepitDates.removeAt(index);

        prefs.setStringList('keepitfiles', keepitfiles);
        prefs.setStringList('keepitStatus', keepitStatus);
        prefs.setStringList('keepitDate', keepitDates);
        File(file).deleteSync();
        //Controls().move_files([file], "/storage/emulated/0/Pictures");
        TagControls().removeTags(file);
      }
    } catch (e) {
      print("Multiple files test: DELETE ERR $e");
      showToast("Error, files not deleted", false);
    }
  }

  Future<bool> resetList() async {
    //createKeepLists();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keepitfiles;
      List<String> keepitStatus;
      List<String> keepitDates;

      keepitfiles = (prefs.getStringList('keepitfiles') ?? List.empty());
      keepitStatus = (prefs.getStringList('keepitStatus') ?? List.empty());
      keepitDates = (prefs.getStringList('keepitDate') ?? List.empty());

      if (keepitfiles.isEmpty || keepitStatus.isEmpty || keepitDates.isEmpty) {
        return false;
      }

      keepitfiles.clear();
      keepitStatus.clear();
      keepitDates.clear();
      prefs.reload();

      await prefs.setStringList('keepitfiles', keepitfiles);
      await prefs.setStringList('keepitStatus', keepitStatus);
      await prefs.setStringList('keepitDate', keepitDates);
      // showToast("Keepit Statuses cleared", true);
      print('List cleared return true');

      /*
        If the bin exists, get all its' files, else create .bin folder
      */
      var bin_dir = Directory("/storage/emulated/0/keepit/.bin/");
      if (bin_dir.existsSync()) {
        print('Went to the if statement the .bin folder exist');

        List<FileSystemEntity> bin_files = bin_dir.listSync();

        if (bin_files.length > 0) {
          //Assign files to array
          List<String> files_to_move = [];

          for (FileSystemEntity file in bin_files) {
            files_to_move.add(file.path);
          }

          //Create `Restored folder`
          Controls().create_collection("Restored");

          //MOVE
          Controls().move_files(
              files_to_move, "/storage/emulated/0/keepit/Restored/");
          print('Calling the move function from the controls file');
          // showToast("Files have been moved from the bin!", true);
        }
      } else {
        print('Went to the else statement to create the bin');
        bin_dir.createSync();
      }

      return true;
      //showToast("Success",true);
    } catch (e) {
      showToast("Error", false);
      return false;
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

  void Notify(String title, String body) async {
    notification.createNotification(
        content: NotificationContent(
            id: 1,
            channelKey: "route_to_keepit_log",
            title: title,
            body: body));
  }
}