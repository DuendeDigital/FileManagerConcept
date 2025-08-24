// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'dart:io';
import 'package:device_apps/device_apps.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:keepit/constants/utils/files.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:keepit/providers/category_provider.dart';
import 'package:keepit/constants/custom_toast.dart' as CustomToast;
import 'package:keepit/constants/hide_notification.dart';

class Controls {
  TextEditingController _textFieldController = TextEditingController();

  //GLOBAL VARIABLES
  List<String> sorted_files_images = [];
  List<String> sorted_files_docs = [];
  List<String> sorted_files_audio = [];
  List<String> sorted_files_msc = [];
  List<List> sorrted_files = [];

  Future<List<FileSystemEntity>> get_all_files(String folder) async {
    //LOCALS VARIABLES
    var dir_int;
    var dir_ext;
    var dir_virt;
    var media_folder;
    var iteration_not_completed = [];
    var manual_dirs_to_search = [];
    bool has_sd_card = await check_for_sdcard();
    List<FileSystemEntity> files = [];

    //print("control search is "+folder);

    dir_int = Directory(folder);
    dir_virt = Directory("mnt/sdcard");
    media_folder = Directory("/storage/emulated/0/Android/media");
    if (has_sd_card) {
      String sd_card_path = await getExternalSdCardPath();
      dir_ext = Directory(sd_card_path);
    }

    //Internal directory
    List<FileSystemEntity> internal_directories = dir_int.listSync();
    internal_directories.removeWhere(
        (element) => element.path == "/storage/emulated/0/Android");

    for (int i = 0; i < internal_directories.length; i++) {
      var new_dir = Directory(internal_directories[i].path.toString());
      manual_dirs_to_search.add(internal_directories[i].path);
      try {
        for (var entity
            in new_dir.listSync(recursive: true, followLinks: false)) {
          files.add(entity);
          manual_dirs_to_search.removeWhere(
              (iteration) => iteration == internal_directories[i].path);
        }
      } catch (e) {
        //Error
      }
    }

    //Manual search internal directory
    for (int i = 0; i < manual_dirs_to_search.length; i++) {
      var manual_dir = Directory("/storage/emulated/0/Download");
      try {
        for (var entity
            in manual_dir.listSync(recursive: true, followLinks: false)) {
          files.add(entity);
          //print("Downloads folder entity is ${entity.path}\n$i");
        }
      } catch (e) {
        //Error
      }
    }

    //Virtual directory
    try {
      for (FileSystemEntity entity
          in dir_virt.listSync(recursive: true, followLinks: false)) {
        files.add(entity);
      }
    } catch (e) {
      ////print error
    }

    //Sd card directory
    if (has_sd_card) {
      try {
        for (FileSystemEntity entity
            in dir_ext.listSync(recursive: true, followLinks: false)) {
          files.add(entity);
        }
      } catch (e) {
        ////print error
      }
    }

    //Android/media directory
    try {
      for (FileSystemEntity entity
          in media_folder.listSync(recursive: true, followLinks: false)) {
        files.add(entity);
      }
    } catch (e) {
      ////print error
    }

    return files;
  }

  void get_all_files_2() async {
    //Local vars
    var dir_int;
    var dir_ext;
    var dir_virt;
    var media_folder;
    bool has_sd_card = await check_for_sdcard();
    var temp;
    List<FileSystemEntity> files;
    List<FileSystemEntity> files_internal;
    List<FileSystemEntity> files_external;
    List<FileSystemEntity> files_virtual;

    //Set directories
    dir_int = Directory("storage/emulated/0");
    dir_virt = Directory("mnt/sdcard");
    media_folder = Directory("/storage/emulated/0/Android/media");
    if (has_sd_card) {
      String sd_card_path = await getExternalSdCardPath();
      dir_ext = Directory(sd_card_path);
      files_external = dir_ext.listSync();
    }
    files_internal = dir_int.listSync();
    files_virtual = dir_virt.listSync();

    for (var iteration in dir_int.listSync(recursive: true)) {}

    //Search Internal
    for (int internal_dir_index = 0;
        internal_dir_index < files_internal.length;
        internal_dir_index++) {
      List<String> dir_searched = [];
      var new_dir = Directory(files_internal[internal_dir_index].path);
      dir_searched.add(files_internal[internal_dir_index].path);

      for (int i = 0; i < new_dir.listSync().length; i++) {
        var new_dir = Directory(files_internal[i].path);
      }
    }
  }

  Future<List<FileSystemEntity>> search_dir(
      String directory_to_search, bool recursive) async {
    //LOCALS VARIABLES
    var dir;
    // /storage/emulated/0/
    if (!recursive) {
      try {
        dir = new Directory(directory_to_search);
      } catch (e) {
        //print(e);
      }
      List<FileSystemEntity> files = dir.listSync();

      return files;
    } else {
      List<FileSystemEntity> files = [];
      try {
        dir = new Directory(directory_to_search);
      } catch (e) {
        //print(e);
      }
      await for (var entity in dir.list(recursive: true)) {
        files.add(entity);
      }

      return files;
    }
  }

  copy_files(List<String> files, String copy_to) {
    try {
      for (var file in files) {
        String file_name = file.split("/").last;
        String extention = file_name.split(".").last;
        String FileName = file_name.split(".").first;
        bool forceMove = false;

        if (File("$copy_to/$file_name").existsSync()) {
          forceMove = true;
        } else {
          forceMove = false;
        }

        if (forceMove) {
          File(file).copySync("$copy_to/$FileName ${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour} ${DateTime.now().second} ${DateTime.now().millisecond}.$extention");
        } else {
          File(file).copySync("$copy_to/$file_name");
        }
      }
      return true;
    } catch (e) {
      print("COPY FAIL $e");
      return false;
    }
  }

  destinationContainsfile(String fileName, String destination) {
    String destinationPath =
        "${destination.split("/").removeLast().splitMapJoin("/")}/$fileName";

    if (File(destinationPath).existsSync()) {
      print("FileVerify contains $destinationPath");
    } else {
      print("FileVerify contains not $destinationPath");
    }
  }

  move_files(List<String> files, String move_to) async{
    try {
      
      List <FileSystemEntity> temporary_paths = [];

      for (String file in files) {
        print("Last file is: ${file}");
        String file_name = file.split("/").last;
        String extention = file_name.split(".").last;
        String FileName = file_name.split(".").first;
        bool forceMove = false;

        if (File("$move_to/$file_name").existsSync()) {
          forceMove = true;
        } else {
          forceMove = false;
        }

        if (forceMove) {
          temporary_paths.add(File(FileName));
          await File(file).copy( "$move_to/$FileName ${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour} ${DateTime.now().second} ${DateTime.now().millisecond}.$extention");
        } else {
          temporary_paths.add(File('$FileName.$extention'));
          await File(file).copy("$move_to/$FileName.$extention");
        }
        
      }


      if(temporary_paths.length == files.length){
        for (int i = 0; i < files.length; i++) {
          FileSystemEntity file = File(files[i]);
          if(file.existsSync()){
            file.delete(recursive: false);
            print('Files moved, original files deleted to prevent duplicates');
          }
        }

        return true;
      }else{
        return false;
      }

      
    } catch (e) {
      print("MOVE FAIL $e");
      return false;
    }
  }

  void share_to(List<String> file_paths, String message) {
    try {
      Share.shareFiles(file_paths, text: message);
    } catch (e) {
      print("SHARE ERR $e");
    }
  }

  Future<List> search(String value_to_search) async {
    var dir;

    dir = Directory("/storage/emulated/0/");
    var files = [];

    await for (var i in dir.list(recursive: true, followLinks: false)) {
      files.add(i.toString());
    }
    //print(files[0]);
    var file_found = find_file(files, value_to_search);

    return files;
  }

  bool find_file(arr, String looking_for) {
    bool file_found = false;

    for (var i = 0; i < arr.length; i++) {
      if (arr[i].toString().contains("$looking_for")) {
        file_found = true;
        break;
      }
    }

    return true;
  }

  Future<bool> check_for_sdcard() async {
    List<Directory>? extDirectories = await getExternalStorageDirectories();
    String rebuiltPath;

    if (extDirectories!.length == 2) {
      List<String> dirs = extDirectories[1].toString().split('/');
      rebuiltPath = '/${dirs[1]}/${dirs[2]}/';
      return true;
    } else {
      return false;
    }
  }

  Future<String> getExternalSdCardPath() async {
    List<Directory>? extDirectories = await getExternalStorageDirectories();
    String rebuiltPath;

    if (extDirectories!.length == 2) {
      List<String> dirs = extDirectories[1].toString().split('/');
      rebuiltPath = '/${dirs[1]}/${dirs[2]}/';
      return rebuiltPath;
    } else {
      return "/storage";
    }
  }

  String get_mime(String path) {
    File file = File(path);
    String mimeType = mime(file.path) ?? '';
    return mimeType;
  }

  Future<List> get_installed_apps() async {
    List apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true, includeSystemApps: true);
    apps.first.systemApp;
    // //print(apps.length);
    // get_metadata("");
    return apps;
  }

  List<FileSystemEntity> sort_array(
      List<FileSystemEntity> files, String look_for) {
    List<FileSystemEntity> files_found = [];

    List<FileSystemEntity> images = [];
    List<FileSystemEntity> audio = [];
    List<FileSystemEntity> videos = [];
    List<FileSystemEntity> docs = [];
    List<FileSystemEntity> all = [];

    var file_extensions = GlobalVariables.file_types;
    for (int i = 0; i < files.length; i++) {
      for (int d1 = 0; d1 < file_extensions.length; d1++) {
        for (int d2 = 0; d2 < file_extensions[d1].length; d2++) {
          if (files[i].path.contains(file_extensions[d1][d2])) {
            //check what category to add file under
            switch (d1) {
              case 0:
                images.add(files[i]);
                all.add(files[i]);
                break;

              case 1:
                videos.add(files[i]);
                all.add(files[i]);
                break;

              case 2:
                audio.add(files[i]);
                all.add(files[i]);
                break;

              case 3:
                docs.add(files[i]);
                all.add(files[i]);
                break;

              case 4:
                docs.add(files[i]);
                all.add(files[i]);
                break;

              case 5:
                docs.add(files[i]);
                all.add(files[i]);
                break;

              case 6:
                docs.add(files[i]);
                all.add(files[i]);
                break;

              case 7:
                docs.add(files[i]);
                all.add(files[i]);
                break;

              case 8:
                docs.add(files[i]);
                all.add(files[i]);
                break;

              default:
                docs.add(files[i]);
                all.add(files[i]);
                break;
            }
          }
        }
      }
    }

    if (look_for == "Images") {
      files_found = images;
    } else if (look_for == "Audio") {
      files_found = audio;
    } else if (look_for == "Videos") {
      files_found = videos;
    } else if (look_for == "All") {
      files_found = all;
    } else if (look_for == "Docs") {
      files_found = docs;
    } else {
      files_found = docs;
    }

    return files_found;
  }

  dynamic get_metadata(String file_path) {
    var bytes =
        File("/storage/emulated/0/DCIM/Screenshot (3).png").readAsBytesSync();

    return bytes;
  }

  bool check_file_bytedata_match(String file_path_1, String file_path_2) {
    var file_1_bytes = File(file_path_1).readAsBytesSync();
    var file_2_bytes = File(file_path_2).readAsBytesSync();

    if (file_1_bytes.toString() == file_2_bytes.toString()) {
      return true;
    } else {
      return false;
    }
  }

/////////////////////COLLECTIONS/////////////////////////////////////////////////////////

  void create_collections_container() async {
    final Directory collection_folder = Directory("storage/emulated/0/keepit/");
    if (await collection_folder.exists()) {
    } else {
      final Directory new_collection_folder =
          await collection_folder.create(recursive: true);
    }
  }

  Future<bool> create_collection(String collection_name) async {
    try {
      create_collections_container();
      final Directory collection_folder =
          Directory("storage/emulated/0/keepit/");

      //if the collection already exists, return false, otherwise create collection and return true
      List<FileSystemEntity> collections = collection_folder.listSync();
      List return_value = [];

      //if tag does not match any other tag names then add to tag list

      for (int i = 0; i < collections.length; i++) {
        String path = collections[i].path.split("/").last.toLowerCase();
        String newCollectionname = collection_name.toLowerCase();
        print("tag $path received $newCollectionname");
        if (path == newCollectionname) {
          return_value.add(path);
        }
      }

      if (return_value.isEmpty) {
        Directory("storage/emulated/0/keepit/$collection_name")
            .create(recursive: true);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    }
  }

  Future<bool> delete_collection(String collection_name) async {
    try {
      final Directory collection_folder =
          Directory("storage/emulated/0/keepit/$collection_name/");

      if (await collection_folder.exists()) {
        try {
          collection_folder.delete(recursive: true);
          return true;
        } catch (e) {
          Fluttertoast.showToast(
              msg: "Error",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          return false;
        }
      } else {
        Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> add_to_collection(String collection_name, List<String> files) async {
    try {
      var message = "";
      final Directory collection_folder = Directory("storage/emulated/0/keepit/$collection_name/");

      List <FileSystemEntity> temporary_paths = [];

      if (await collection_folder.exists()) {

        for (int i = 0; i < files.length; i++) {
          File file = File(files[i]);
          temporary_paths.add(file);
          String file_name = file.path.split("/").last;
          // file.rename("storage/emulated/0/keepit/$collection_name/$file_name");
          await file.copy("storage/emulated/0/keepit/$collection_name/$file_name");
        }

        if(temporary_paths.length == files.length){
          for (int i = 0; i < files.length; i++) {
            FileSystemEntity file = File(files[i]);
            if(file.existsSync()){
              await file.delete(recursive: false);
              print('Files moved to the collections folder, original files deleted to prevent duplicates');
            }
          }


          return true;
        }else{
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> remove_from_collections(
      String collection_name, List<FileSystemEntity> files) async {
    try {
      var message = "";
      final Directory collection_folder =
          Directory("storage/emulated/0/keepit/$collection_name/");

      if (await collection_folder.exists()) {
        List<String> file_names_arr = [];
        List<String> collection_file_names_arr = [];
        List<FileSystemEntity> collection_file = [];
        //Get file names
        for (int i = 0; i < files.length; i++) {
          var file_name = files[i].path.split("/");
          file_names_arr.add(file_name.last);
        }

        collection_file = collection_folder.listSync();

        for (int i = 0; i < collection_file.length; i++) {
          var file_name = collection_file[i].path.split("/");
          if (file_names_arr.contains(file_name.last)) {
            collection_file[i].delete();
          }
        }

        if (files.length > 1) {
          message =
              "Files successfully removed from collection: $collection_name";
        } else {
          message =
              "File successfully removed from collection: $collection_name";
        }

        return true;
      } else {
        Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<FileSystemEntity>> get_collection(String collection_name) async {
    try {
      final Directory collection_folder =
          Directory("storage/emulated/0/keepit/$collection_name/");
      List<FileSystemEntity> files = collection_folder.listSync();
      print("Collections path is ${collection_folder}");
      return files;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      List<FileSystemEntity> err = [];
      return err;
    }
  }

  Future<List<FileSystemEntity>> get_all_collections(destination) async {
    try {
      final Directory collection_folder =
          Directory("storage/emulated/0/keepit/");
      List<FileSystemEntity> files =
          collection_folder.listSync(followLinks: false);
      // remove where files contains string bin
      files.removeWhere((element) {
        return element.path.contains(".ads");
      });
      files.removeWhere((element) {
        return element.path.contains(".bin");
      });
      print("Last collections are $files");
      return files;
    } catch (e) {
      List<FileSystemEntity> err = [];
      return err;
    }
  }

  Future<bool> get_all_file_collections(destination) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _keepitFolderSize = prefs.getString('_keepitFolderSize') ?? '';
    try {
      List return_value = [];
      List counter = [];
      final Directory collection_folder =
          Directory("storage/emulated/0/keepit/");
      List<FileSystemEntity> files =
          collection_folder.listSync(followLinks: false);
      // remove where files contains string bin
      files.removeWhere((element) {
        return element.path.contains(".ads");
      });
      files.removeWhere((element) {
        return element.path.contains(".bin");
      });

      // loop files and check if they are directories
      if (destination == 'dashboard') {
        for (int i = 0; i < files.length; i++) {
          // print("Last empty folder ${files[i].path.split("/").last}");
          Directory _folder = Directory(
              "storage/emulated/0/keepit/${files[i].path.split("/").last}");
          // check if folder is empty
          if (_folder.listSync().length == 0) {
            return_value.add(files[i]);
          } else {
            counter.add(files[i]);
            return false;
          }
        }
      }
      if (counter.length > 0) {
        return false;
      } else {
        if (return_value.isNotEmpty) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      List<FileSystemEntity> err = [];
      return true;
    }
  }

  // Future<List<FileSystemEntity>> get_all_file_collections(destination) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String _keepitFolderSize = prefs.getString('_keepitFolderSize') ?? '';
  //   try {
  //     List return_value = [];
  //     List counter = [];
  //     final Directory collection_folder =
  //         Directory("storage/emulated/0/keepit/");
  //     List<FileSystemEntity> files =
  //         collection_folder.listSync(followLinks: false);
  //     // remove where files contains string bin
  //     files.removeWhere((element) {
  //       return element.path.contains(".ads");
  //     });
  //     files.removeWhere((element) {
  //       return element.path.contains(".bin");
  //     });
  //     // files.removeWhere((element) {
  //     //   return element.path.contains("Restored");
  //     // });

  //     // loop files and check if they are directories
  //     if (destination == 'dashboard') {
  //       for (int i = 0; i < files.length; i++) {

  //         // print("Last empty folder ${files[i].path.split("/").last}");
  //         Directory _folder = Directory(
  //             "storage/emulated/0/keepit/${files[i].path.split("/").last}");
  //         // check if folder is empty
  //         // print(
  //         //     'The ${files[i].path.split("/").last} folder length is ${_folder.listSync().length}');
  //         if (_folder.listSync().length == 0) {
  //           return_value.add(files[i]);
  //         } else {
  //           counter.add(files[i]);
  //         }
  //       }
  //     }
  //     if (counter.length > 0) {
  //       String _keepitFolderSize = 'false';
  //       prefs.setString('_keepitFolderSize', _keepitFolderSize);
  //     } else {
  //       if (return_value.isNotEmpty) {
  //         String _keepitFolderSize = 'true';
  //         prefs.setString('_keepitFolderSize', _keepitFolderSize);
  //       } else {
  //         String _keepitFolderSize = 'false';
  //         prefs.setString('_keepitFolderSize', _keepitFolderSize);
  //       }
  //     }
  //     print("Last collections are $files");
  //     return files;
  //   } catch (e) {
  //     String _keepitFolderSize = 'false';
  //     prefs.setString('_keepitFolderSize', _keepitFolderSize);
  //     List<FileSystemEntity> err = [];
  //     // Fluttertoast.showToast(
  //     //     msg: "Error",
  //     //     toastLength: Toast.LENGTH_LONG,
  //     //     gravity: ToastGravity.BOTTOM,
  //     //     timeInSecForIosWeb: 2,
  //     //     backgroundColor: Colors.red,
  //     //     textColor: Colors.white,
  //     //     fontSize: 16.0);
  //     // print("Collection 0 is $e");
  //     return err;
  //   }
  // }




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


  void displayTextInputDialog(String path, BuildContext context) async {
    var notice = await HideNotification().setValue();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Please Enter The New Name',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(22, 86, 176, 1))),
            content: TextField(
              autofocus: true,
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Rename"),
            ),
            actions: [
              GestureDetector(
                child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    color: GlobalVariables.secondaryColor),
                              ),
                            ),
                onTap: () {
                  print('Close Sign');
                  _textFieldController.clear();
                  Navigator.pop(context);
                },
              ),
              GestureDetector(
                child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: const Text(
                                'Okay',
                                style: TextStyle(
                                    color: GlobalVariables.secondaryColor),
                              ),
                            ),
                onTap: () async {
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


                  // print('Add Sign');
                  //Check collection name
                  final validCharacters = RegExp(r'^[9&%=-_\-=@,\.;]+$');

                  // if (!validCharacters.hasMatch(_textFieldController.text)) {
                  var res = await renameFile(path, _textFieldController.text, context);

                  print("The passed path ${path.toString()}");
                  print("The entered name ${_textFieldController.text}");
                  print("list file value is $res");

                  if (res == true) {
                    var notice = await HideNotification().setValue();
                    print("list file renamed here!");
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);

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
                                Colors.green,
                                Colors.amber,
                                "assets/check.png",
                                "Success!",
                                "File renamed.",
                                context),
                      );
                    });
                    Provider.of<CategoryProvider>(context, listen: false).getImages('image');

                  } else {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
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
                              "File not renamed!",
                              "We had an error renaming this file and it may contain invalid characters. Please try again.",
                              context),
                    );
                  }
                  // }
                  // else {
                  //   // Fluttertoast.showToast(
                  //   //     msg:
                  //   //         "Name contains invalid characters. Please try again.",
                  //   //     toastLength: Toast.LENGTH_LONG,
                  //   //     gravity: ToastGravity.BOTTOM,
                  //   //     timeInSecForIosWeb: 2,
                  //   //     backgroundColor: Colors.red,
                  //   //     textColor: Colors.white,
                  //   //     fontSize: 16.0);
                  //   Navigator.pop(context);
                  //   Navigator.pop(context);
                  //   showModalBottomSheet(
                  //     context: context,
                  //     enableDrag: true,
                  //     isDismissible: true,
                  //     isScrollControlled: true,
                  //     backgroundColor: Colors.transparent,
                  //     shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.vertical(
                  //       top: Radius.circular(20.0),
                  //     )),
                  //     constraints: BoxConstraints(
                  //       maxWidth: MediaQuery.of(context).size.width - 25,
                  //     ),
                  //     builder: (context) => CustomToast.CustomToast()
                  //         .CustomToastNotification(
                  //             Colors.red,
                  //             Colors.amber,
                  //             "assets/close.png",
                  //             "Error!",
                  //             "Name contains invalid characters. Please try again.",
                  //             context),
                  //   );
                  // }
                },
              ),
            ],
          );
        });
  }

  // Future<File> changeFileNameOnly(String file, String newname, String extension) {
  //   List<String> arr = file.split("/");
  //   arr.removeLast();
  //   String foo = arr.join("/");
  //   print("Foo ${foo}");

  //   return File(file).rename("${foo}/${newname}${extension}");
  // }

  List<String> traverse_path = [];

  bool check_same_file_exist(String file, String newname, String extension) {
    bool exist = false;

    List<String> arr = file.split("/");
    arr.removeLast();
    String foo = arr.join("/");
    print("Foo ${foo}");

    Directory dir = new Directory(foo); //Internal Storage
    List<FileSystemEntity> files = dir.listSync(recursive: false);

    for (FileSystemEntity file in files) {
      var path = file.uri;
      var strip_path = path.toFilePath().replaceAll(foo, "");
      late String folder;
      folder = strip_path.replaceAll("/", "").toString();
      traverse_path.clear();
      traverse_path.add(foo);
      var thumbnail = traverse_path[0] + '/' + folder;

      print("Passing path ${file}");
      print("Check against ${thumbnail}");
      print("File to check ${File(file.toString().replaceAll("'", "").replaceAll("'", ""))}");
      print("Working");

      if ("${foo}/${newname}${extension}" == thumbnail) {
        print("File Already Exist");
        exist = true;
        break;
      } else {
        print("Rename File");
        print("${foo}/${newname}${extension}");
        exist = false;
      }
    }

    return exist;
  }

  renameFile(String path, String newname, BuildContext context) async {

    //Delcarations
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitfiles = (prefs.getStringList('keepitfiles') ?? List.empty());
    List<String> keepitStatus = (prefs.getStringList('keepitStatus') ?? List.empty());
    List<String> keepitDates = (prefs.getStringList('keepitDate') ?? List.empty());

    //Setting parents and extention
    File file = File(path);
    List<String> temp = path.split("/");
    String file_old_name = temp.last.split(".").first;
    String file_extension = temp.last.split(".").last;
    temp.removeLast();
    String file_parents = temp.join("/");

    //Shared Pref index
    int index = keepitfiles.indexWhere((element) => element == path);

    try {
      //Check if file with the same name exists in the same directory
      String parent = path.split("/").removeLast().splitMapJoin("/");

      if (file.existsSync()) {
        String newFileuri = "";

        if (File("$file_parents/$newname.$file_extension").existsSync()) {
          newFileuri = "$file_parents/$newname ${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour} ${DateTime.now().second} ${DateTime.now().millisecond}.$file_extension";
        } else {
          newFileuri = "$file_parents/$newname.$file_extension";
        }

        print("RENAME PATH IS $newFileuri");

        if (keepitfiles.contains(path)) {
          //Rename the file then update the lists
          File new_file = file.copySync(newFileuri);
          file.deleteSync(recursive: false);
          String date = keepitDates[index];
          String val = keepitStatus[index];

          keepitfiles.removeAt(index);
          keepitStatus.removeAt(index);
          keepitDates.removeAt(index);

          KeepFiles().addToList(newFileuri, val, date);
          return true;
        } else {
          //Rename the file then update the lists
          print('Previous path ${file}');
          print('New path ${newFileuri}');
          File new_file = file.copySync(newFileuri);
          file.deleteSync(recursive: false);
          return true;
        }
      }
      // }
    } catch (e) {
      //showToast("Sorry! File not renamed", false);
      print("RENAME GOOFED $e");
      return false;
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
