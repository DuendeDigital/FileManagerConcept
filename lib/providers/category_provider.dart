import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:mime_type/mime_type.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:keepit/constants/utils/file_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileOBJ {
  final String thumbnail;
  final String file_name;
  final int file_size;
  final DateTime file_date;
  final String keep_status;
  final int keep_date;

  FileOBJ(this.thumbnail, this.file_name, this.file_size, this.file_date,
      this.keep_status, this.keep_date);
}

class KeepitFileOBJ {
  final String thumbnail;
  final String file_name;
  final int file_size;
  final DateTime file_date;
  final String keep_status;
  final int keep_date;

  KeepitFileOBJ(this.thumbnail, this.file_name, this.file_size, this.file_date,
      this.keep_status, this.keep_date);
}

class CategoryProvider extends ChangeNotifier {
  bool loading = false;
  List<FileSystemEntity> downloads = <FileSystemEntity>[];
  List<String> downloadTabs = <String>[];

  List<FileSystemEntity> images = <FileSystemEntity>[];
  List<String> imageTabs = <String>[];

  List<FileSystemEntity> allfiles = <FileSystemEntity>[];
  List<String> allfileTabs = <String>[];

  List<FileSystemEntity> sortfiles = <FileSystemEntity>[];
  List<String> sortfileTabs = <String>[];

  List<FileSystemEntity> keepfiles = <FileSystemEntity>[];
  List<String> keepfileTabs = <String>[];

  List<FileSystemEntity> audio = <FileSystemEntity>[];
  List<String> audioTabs = <String>[];

  List<FileSystemEntity> audio_reload = <FileSystemEntity>[];
  List<String> audioTabs_reload = <String>[];

  List<FileSystemEntity> document = <FileSystemEntity>[];
  List<String> documentTabs = <String>[];

  List<FileSystemEntity> video = <FileSystemEntity>[];
  List<String> videoTabs = <String>[];

  List<String> currentKeepFiles = [];
  List<String> currentKeepFilesStatus = [];
  List<String> currentKeepFilesDate = [];
  List<String> currentDirKeepFilesList = [];

  List<FileSystemEntity> currentFiles = [];
  List<FileSystemEntity> currentImageFiles = [];
  List<FileSystemEntity> currentDocumentFiles = [];
  List<FileSystemEntity> currentAudioFiles = [];
  List<FileSystemEntity> currentVideosFiles = [];
  List<FileSystemEntity> currentAllFiles = [];
  List<FileSystemEntity> currentSortFiles = [];
  List<FileSystemEntity> currentKeepFilesObjects = [];
  List<FileSystemEntity> currentDownloadFiles = [];
  List<FileSystemEntity> currentKeep = [];

  List<FileOBJ> onePack = [];
  List<FileOBJ> onePackImages = [];
  List<FileOBJ> onePackAudio = [];
  List<FileOBJ> onePackAudio_reload = [];
  List<FileOBJ> onePackDocuments = [];
  List<FileOBJ> onePackVideos = [];
  List<FileOBJ> onePackAll = [];
  List<FileOBJ> onePackSort = [];
  List<FileOBJ> onePackDownloads = [];
  List<FileOBJ> onePackKeep = [];

  List<String> keepitTabs = <String>["KeepIt", "KeepItFor", "Keepit Bin"];
  List<KeepitFileOBJ> onePackAllKeep = [];

  bool showHidden = false;
  bool reloaded = false;
  int sort = 0;
  final isolates = IsolateHandler();

  sortSwitchList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitfiles =
        (prefs.getStringList('keepitfiles') ?? List.empty());
    List<String> keepitStatus =
        (prefs.getStringList('keepitStatus') ?? List.empty());
    List<String> keepitDate =
        (prefs.getStringList('keepitDate') ?? List.empty());
    print("Reloaded keepitfiles: $keepitfiles");
    print("Reloaded keepitStatus: $keepitStatus");
    print("Reloaded keepitDate: $keepitDate");
    bool isSwitched = prefs.getBool('reloaded') ?? false;
    isSwitched = true;
    prefs.setBool('reloaded', isSwitched);
    print("Reloaded Value form provider: $isSwitched");

    if (isSwitched == true) {
      print("Reloaded Value Inside provider: $isSwitched");
      reloaded = true;
    }
    notifyListeners();
  }

  // Get the images and videos
  getImages(String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitfiles =
        (prefs.getStringList('keepitfiles') ?? List.empty());
    List<String> keepitStatus =
        (prefs.getStringList('keepitStatus') ?? List.empty());
    List<String> keepitDate =
        (prefs.getStringList('keepitDate') ?? List.empty());
    prefs.reload();

    // var x = keepitfiles.length;
    // var y = keepitStatus.length;
    // var z = keepitDate.length;

    // int keepitfilesLengthMin = [x, y, z].reduce(min);
    // int keepitfilesLengthMax = [x, y, z].reduce(max);
    // print("Keep me Max length: ${keepitfilesLengthMax}");
    // print("Keep me Min length: ${keepitfilesLengthMin}");

    // if (keepitfiles.length > keepitfilesLengthMin) {
    //   keepitfiles.removeRange(keepitfilesLengthMin, keepitfiles.length);
    //   prefs.setStringList('keepitfiles', keepitfiles);
    // }

    // if (keepitStatus.length > keepitfilesLengthMin) {
    //   keepitStatus.removeRange(keepitfilesLengthMin, keepitStatus.length);
    //   prefs.setStringList('keepitStatus', keepitStatus);
    // }

    // if (keepitDate.length > keepitfilesLengthMin) {
    //   keepitDate.removeRange(keepitfilesLengthMin, keepitDate.length);
    //   prefs.setStringList('keepitDate', keepitDate);
    // }

    print("Keep me files length: ${keepitfiles.length}");
    print("Keep me files are : ${keepitfiles}");
    print("Keep me status are : ${keepitStatus}");
    print("Keep me status length: ${keepitStatus.length}");
    print("Keep me date are : ${keepitDate}");
    print("Keep me dates length: ${keepitDate.length}");

    bool showHiddenVal = prefs.getBool('showHidden') ?? false;
    bool _isLoaded = prefs.getBool('_isLoaded') ?? false;
    setLoading(true);
    allfileTabs.clear();
    imageTabs.clear();
    audioTabs.clear();
    videoTabs.clear();
    documentTabs.clear();
    downloadTabs.clear();
    keepfileTabs.clear();

    allfiles.clear();
    sortfiles.clear();
    images.clear();
    audio.clear();
    video.clear();
    document.clear();
    downloads.clear();
    keepfiles.clear();

    allfileTabs.add('All');
    imageTabs.add('All');
    audioTabs.add('All');
    videoTabs.add('All');
    documentTabs.add('All');
    downloadTabs.clear();
    keepfileTabs.add('All');

    onePackImages.clear();
    onePackDocuments.clear();
    onePackAudio.clear();
    onePackVideos.clear();
    onePackAll.clear();
    onePackSort.clear();
    onePackDownloads.clear();
    onePackKeep.clear();

    //var now = new DateTime.now();
    String isolateName = type;
    isolates.spawn<String>(
      getAllFilesWithIsolate,
      name: isolateName,
      onReceive: (val) {
        print(val);
        isolates.kill(isolateName);
      },
      onInitialized: () => isolates.send('Init', to: isolateName),
    );
    ReceivePort _port = ReceivePort();
    IsolateNameServer.registerPortWithName(_port.sendPort, '${isolateName}_2');
    _port.listen((files) {
      print('RECEIVED SERVER PORT');
      // print(files);

      var file_count = 0;

      files.forEach((file) async {
        file_count++;
        String fileCount = (prefs.getString('file_count') ?? '0');
        prefs.setString("file_count", file_count.toString());
        if (files.length == file_count) {
          _isLoaded = true;
          prefs.setBool('_isLoaded', _isLoaded);
        }
        String KeepItStatus = 'none';
        int KeepItDate = 0;

        getKeep(String path_to_file) async {
          var result = 'false';
          var x = 0;
          for (var z = 0; z < keepitfiles.length; z++) {
            if (path_to_file == keepitfiles[z]) {
              result = keepitStatus[z];
            }
            x++;
          }
          if (x == keepitfiles.length) {
            return result;
          }
        }

        getDate(String path_to_file) async {
          var date = 'none';
          var x = 0;
          for (var z = 0; z < keepitfiles.length; z++) {
            if (path_to_file == keepitfiles[z]) {
              date = keepitDate[z];
            }
            x++;
          }
          if (x == keepitfiles.length) {
            return date;
          }
        }

        int daysBetween(DateTime from, DateTime to) {
          from = DateTime(from.year, from.month, from.day);
          to = DateTime(to.year, to.month, to.day);
          return (to.difference(from).inHours / 24).round();
        }

        String path = file.path;
        String pname =
            '${file.path.split('/')[file.path.split('/').length - 2]}';
        final stat = FileStat.statSync(path);

        var result = await getKeep(path);
        var date = await getDate(path);
        //print('Result Date is: ${date}');
        if (result != 'false') {
          KeepItStatus = result.toString();

          if (date.toString() != 'none') {
            final DateTime date1 = DateTime.parse(date.toString());
            final date2 = DateTime.now();
            final int difference = await daysBetween(date2, date1);

            //final DateTime time1 = DateTime.parse(date.toString());
            KeepItDate = difference;
            print("keep me Date diff is: ${KeepItDate}");

            // var tt = await convertToAgo(date.toString());
            // print("Date is: ${tt}");
          } else {
            KeepItDate = 0;
          }
        } else {
          KeepItStatus = 'none';
          KeepItDate = 0;
        }

        var file_name = path
            .toString()
            .substring(path.toString().lastIndexOf('/'))
            .replaceAll("/", "")
            .replaceAll("/", "");

        var file_name_hidden = "${file_name.substring(0, 1)}";
        var path_name_hidden = "${pname.substring(0, 1)}";
        var dfolder =
            '${file.path.split('/')[file.path.split('/').length - 2]}';
        var kfolder =
            '${file.path.split('/')[file.path.split('/').length - 3]}';
        String binCheck =
            '${file.path.split('/')[file.path.split('/').length - 2]}';
        //print('File name starts with: ${file_name_hidden}');
        //print('Folder name starts with: ${path_name_hidden}');
        if (showHiddenVal == false) {
          if (path_name_hidden != "." && file_name_hidden != ".") {
            if (file.path.contains(".bin")) {
            } else {
              allfiles.add(file);
              allfileTabs.add(
                  '${file.path.split('/')[file.path.split('/').length - 2]}');
              allfileTabs = allfileTabs.toSet().toList();
              var dfolder =
                  '${file.path.split('/')[file.path.split('/').length - 2]}';
              //print("Folder is: ${file.path}");
              // get file size in bytes
              //FileUtils.formatBytes(stat.size, 1)

              onePackAll.add(FileOBJ(
                  path,
                  file_name,
                  stat.size,
                  DateTime.parse(stat.modified.toString()),
                  KeepItStatus,
                  KeepItDate));
            }
          }
        } else {
          if (file.path.contains(".bin")) {
          } else {
            allfiles.add(file);
            allfileTabs.add(
                '${file.path.split('/')[file.path.split('/').length - 2]}');
            allfileTabs = allfileTabs.toSet().toList();
            //print("Folder is: ${file.path}");

            onePackAll.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }

        if (showHiddenVal == false) {
          sortfiles.add(file);
          // allfileTabs.add(
          //     '${file.path.split('/')[file.path.split('/').length - 2]}');
          // allfileTabs = allfileTabs.toSet().toList();
          //print("Folder is: ${file.path}");
          // get file size in bytes
          //FileUtils.formatBytes(stat.size, 1)

          onePackSort.add(FileOBJ(
              path,
              file_name,
              stat.size,
              DateTime.parse(stat.modified.toString()),
              KeepItStatus,
              KeepItDate));
        } else {
          sortfiles.add(file);
          // sortfileTabs.add(
          //     '${file.path.split('/')[file.path.split('/').length - 2]}');
          // allfileTabs = allfileTabs.toSet().toList();
          //print("Folder is: ${file.path}");

          onePackSort.add(FileOBJ(
              path,
              file_name,
              stat.size,
              DateTime.parse(stat.modified.toString()),
              KeepItStatus,
              KeepItDate));
        }

        // var result = await getFileInDb(path);
        // print("Result Found in database: ${result}");

        // Check for downloads folder
        if (dfolder == 'Download') {
          if (showHiddenVal == false) {
            if (path_name_hidden != "." && file_name_hidden != ".") {
              downloads.add(file);
              downloadTabs.add(
                  '${file.path.split('/')[file.path.split('/').length - 2]}');
              downloadTabs = downloadTabs.toSet().toList();

              onePackDownloads.add(FileOBJ(
                  path,
                  file_name,
                  stat.size,
                  DateTime.parse(stat.modified.toString()),
                  KeepItStatus,
                  KeepItDate));
            }
          } else {
            downloads.add(file);
            downloadTabs.add(
                '${file.path.split('/')[file.path.split('/').length - 2]}');
            downloadTabs = downloadTabs.toSet().toList();

            onePackDownloads.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }

        // SET KEEPIT FOLDER TABS
        if (kfolder == 'keepit') {
          print(
              "Last keepit folder ${file.path.split('/')[file.path.split('/').length - 2]}");
          if (showHiddenVal == false) {
            if (path_name_hidden != "." && file_name_hidden != ".") {
              if (file.path.contains(".bin")) {
              } else {
                keepfiles.add(file);
                keepfileTabs.add(
                    '${file.path.split('/')[file.path.split('/').length - 2]}');
                keepfileTabs = keepfileTabs.toSet().toList();

                onePackKeep.add(FileOBJ(
                    path,
                    file_name,
                    stat.size,
                    DateTime.parse(stat.modified.toString()),
                    KeepItStatus,
                    KeepItDate));
              }
            }
          } else {
            if (file.path.contains(".bin")) {
            } else {
              keepfiles.add(file);
              keepfileTabs.add(
                  '${file.path.split('/')[file.path.split('/').length - 2]}');
              keepfileTabs = keepfileTabs.toSet().toList();

              onePackKeep.add(FileOBJ(
                  path,
                  file_name,
                  stat.size,
                  DateTime.parse(stat.modified.toString()),
                  KeepItStatus,
                  KeepItDate));
            }
          }
        }

        String mimeType = mime(file.path) ?? '';
        if (mimeType.split('/')[0] == "image") {
          if (showHiddenVal == false) {
            if (path_name_hidden != "." && file_name_hidden != ".") {
              if (file.path.contains(".bin")) {
              } else {
                images.add(file);
                imageTabs.add(
                    '${file.path.split('/')[file.path.split('/').length - 2]}');
                imageTabs = imageTabs.toSet().toList();

                onePackImages.add(FileOBJ(
                    path,
                    file_name,
                    stat.size,
                    DateTime.parse(stat.modified.toString()),
                    KeepItStatus,
                    KeepItDate));
              }
            }
          } else {
            if (file.path.contains(".bin")) {
            } else {
              images.add(file);
              imageTabs.add(
                  '${file.path.split('/')[file.path.split('/').length - 2]}');
              imageTabs = imageTabs.toSet().toList();

              onePackImages.add(FileOBJ(
                  path,
                  file_name,
                  stat.size,
                  DateTime.parse(stat.modified.toString()),
                  KeepItStatus,
                  KeepItDate));
            }
          }
        }

        if (mimeType.split('/')[0] == "video") {
          if (showHiddenVal == false) {
            if (path_name_hidden != "." && file_name_hidden != ".") {
              if (file.path.contains(".bin")) {
              } else {
                video.add(file);
                videoTabs.add(
                    '${file.path.split('/')[file.path.split('/').length - 2]}');
                videoTabs = videoTabs.toSet().toList();

                onePackVideos.add(FileOBJ(
                    path,
                    file_name,
                    stat.size,
                    DateTime.parse(stat.modified.toString()),
                    KeepItStatus,
                    KeepItDate));
              }
            }
          } else {
            if (file.path.contains(".bin")) {
            } else {
              video.add(file);
              videoTabs.add(
                  '${file.path.split('/')[file.path.split('/').length - 2]}');
              videoTabs = videoTabs.toSet().toList();

              onePackVideos.add(FileOBJ(
                  path,
                  file_name,
                  stat.size,
                  DateTime.parse(stat.modified.toString()),
                  KeepItStatus,
                  KeepItDate));
            }
          }
        }

        if (mimeType.split('/')[0] == "audio" ||
            mimeType == "application/ogg") {
          if (showHiddenVal == false) {
            if (path_name_hidden != "." && file_name_hidden != ".") {
              if (file.path.contains(".bin")) {
              } else {
                audio.add(file);
                audioTabs.add(
                    '${file.path.split('/')[file.path.split('/').length - 2]}');
                audioTabs = audioTabs.toSet().toList();

                onePackAudio.add(FileOBJ(
                    path,
                    file_name,
                    stat.size,
                    DateTime.parse(stat.modified.toString()),
                    KeepItStatus,
                    KeepItDate));
              }
            }
          } else {
            if (file.path.contains(".bin")) {
            } else {
              audio.add(file);
              audioTabs.add(
                  '${file.path.split('/')[file.path.split('/').length - 2]}');
              audioTabs = audioTabs.toSet().toList();

              onePackAudio.add(FileOBJ(
                  path,
                  file_name,
                  stat.size,
                  DateTime.parse(stat.modified.toString()),
                  KeepItStatus,
                  KeepItDate));
            }
          }
        }

        if (mimeType.split('/')[0] == "application" &&
            mimeType != "application/ogg") {
          //print('Hidden value is: ${showHiddenVal}');
          if (showHiddenVal == false) {
            if (path_name_hidden != "." && file_name_hidden != ".") {
              if (file.path.contains(".bin")) {
              } else {
                document.add(file);
                documentTabs.add(
                    '${file.path.split('/')[file.path.split('/').length - 2]}');
                var tab =
                    '${file.path.split('/')[file.path.split('/').length - 2]}';
                // print("Tab is ${tab}");
                // print("File name is ${file_name}");
                documentTabs = documentTabs.toSet().toList();

                onePackDocuments.add(FileOBJ(
                    path,
                    file_name,
                    stat.size,
                    DateTime.parse(stat.modified.toString()),
                    KeepItStatus,
                    KeepItDate));
              }
            }
          } else {
            if (file.path.contains(".bin")) {
            } else {
              document.add(file);
              documentTabs.add(
                  '${file.path.split('/')[file.path.split('/').length - 2]}');
              var tab =
                  '${file.path.split('/')[file.path.split('/').length - 2]}';
              // print("Tab is ${tab}");
              // print("File name is ${file_name}");
              documentTabs = documentTabs.toSet().toList();

              onePackDocuments.add(FileOBJ(
                  path,
                  file_name,
                  stat.size,
                  DateTime.parse(stat.modified.toString()),
                  KeepItStatus,
                  KeepItDate));
            }
          }
        }

        notifyListeners();
      });

      //print("Downloads tabs is: ${downloadTabs}");
      //print("Downloads files is: ${downloads}");

      currentImageFiles = images;
      currentDocumentFiles = document;
      currentAudioFiles = audio;
      currentVideosFiles = video;
      currentAllFiles = allfiles;
      currentSortFiles = sortfiles;

      setLoading(false);
      _port.close();
      IsolateNameServer.removePortNameMapping('${isolateName}_2');
    });
  }

  // Watcher(List files) async {
  //   List<FileSystemEntity> sortedFiles = [];
  //   print("Reloaded File list: $files");
  //   files.forEach((file) async {
  //     if (File(file.path).existsSync()) {
  //       sortedFiles.add(file);
  //     }
  //   });
  //   print("Reloaded File Sorted list: $sortedFiles");
  //   return sortedFiles;
  //   // notifyListeners();
  // }

  allKeepFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitfiles =
        (prefs.getStringList('keepitfiles') ?? List.empty());
    List<String> keepitStatus =
        (prefs.getStringList('keepitStatus') ?? List.empty());
    List<String> keepitDate =
        (prefs.getStringList('keepitDate') ?? List.empty());
    currentKeepFiles = keepitfiles;
    currentKeepFilesStatus = keepitStatus;
    currentKeepFilesDate = keepitDate;
    List<FileSystemEntity> currentKeepFilesObjects = [];
    onePackAllKeep.clear();

    for (var x = 0; x < keepitfiles.length; x++) {
      File file = new File(keepitfiles[x]);
      currentKeepFilesObjects.add(file);

      final stat = FileStat.statSync(file.path);
      String path = file.path;
      var file_name = file.path
          .toString()
          .substring(file.path.toString().lastIndexOf('/'))
          .replaceAll("/", "")
          .replaceAll("/", "");

      onePackAllKeep.add(KeepitFileOBJ(
          path,
          file_name,
          stat.size,
          DateTime.parse(stat.modified.toString()),
          currentKeepFilesStatus[x],
          0));
    }

    notifyListeners();
  }

  keepFiles(List list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitfiles =
        (prefs.getStringList('keepitfiles') ?? List.empty());
    List<String> keepitStatus =
        (prefs.getStringList('keepitStatus') ?? List.empty());
    List<String> keepitDate =
        (prefs.getStringList('keepitDate') ?? List.empty());
    currentKeepFiles = [];
    //print("Keep files list ${keepitfiles}");

    getKeep(String path_to_file) async {
      var result = 'false';
      var status = 'none';
      var file = 'none';
      var date = 'none';
      var x = 0;
      for (var z = 0; z < keepitfiles.length; z++) {
        if (path_to_file == keepitfiles[z]) {
          result = keepitStatus[z];
        }
        x++;
      }
      if (x == keepitfiles.length) {
        return result;
      }
    }

    for (File item in list) {
      var path_to_file = item.path.toString();
      var result = await getKeep(path_to_file);
      //print('Result is: ${result}');
      if (result != 'false') {
        currentKeepFiles.add(result.toString());
      } else {
        currentKeepFiles.add("none");
      }
    }

    notifyListeners();
  }

  /// Get all Files on the Device
  Future<List<FileSystemEntity>> getAllFilesForIsolate(
      {bool showHidden = false}) async {
    List<Directory> storages = await getStorageList();
    List<FileSystemEntity> files = <FileSystemEntity>[];
    for (Directory dir in storages) {
      List<FileSystemEntity> allFilesInPath = [];
      // This is important to catch storage errors
      try {
        allFilesInPath =
            await getAllFilesInPath(dir.path, showHidden: showHidden);
      } catch (e) {
        allFilesInPath = [];
        print(e);
      }
      files.addAll(allFilesInPath);
    }
    return files;
  }

  /// Get all Files on the Device
  static Future<List<FileSystemEntity>> getAllFiles(
      {bool showHidden = false}) async {
    List<Directory> storages = await getStorageList();
    List<FileSystemEntity> files = <FileSystemEntity>[];
    for (Directory dir in storages) {
      List<FileSystemEntity> allFilesInPath = [];
      // This is important to catch storage errors
      try {
        allFilesInPath =
            await getAllFilesInPath(dir.path, showHidden: showHidden);
      } catch (e) {
        allFilesInPath = [];
        print(e);
      }
      files.addAll(allFilesInPath);
    }
    return files;
  }

  /// Return all available Storage path
  static Future<List<Directory>> getStorageList() async {
    List<Directory> paths = (await getExternalStorageDirectories())!;
    List<Directory> filteredPaths = <Directory>[];
    for (Directory dir in paths) {
      filteredPaths.add(removeDataDirectory(dir.path));
    }
    return filteredPaths;
  }

  static Directory removeDataDirectory(String path) {
    //print("St: path is $path");
    return Directory(path.split('Android')[0]);
  }

  /// Get all files
  static Future<List<FileSystemEntity>> getAllFilesInPath(String path,
      {bool showHidden = false}) async {
    List<FileSystemEntity> files = <FileSystemEntity>[];
    Directory d = Directory(path);
    List<FileSystemEntity> l = d.listSync();
    for (FileSystemEntity file in l) {
      var string = file.path.toString();
      //print("St: this should be the main logic ${string}");
      if (FileSystemEntity.isFileSync(file.path)) {
        print('Show hidden value is: ${showHidden}');
        if (string.contains('/storage/emulated/0/Android/media')) {
          print("St: we found what we needed here ${string}");
          if (string.contains('WhatsApp Images') ||
              string.contains('WhatsApp Video') ||
              string.contains('WhatsApp Animated Gifs') ||
              string.contains('WhatsApp Audio') ||
              string.contains('WhatsApp Documents')) {
            if (string.contains('Sent') || string.contains('Private')) {
            } else {
              if (!showHidden) {
                files.add(file);
              } else {
                files.add(file);
              }
            }
          }
        } else {
          if (!showHidden) {
            files.add(file);
          } else {
            files.add(file);
          }
        }
      } else {
        //print("St: get all path is ${file.path}");
        if (file.path.contains('/storage/emulated/0/Android/data')) {
        } else if (file.path.contains('/storage/emulated/0/Android/obb')) {
        } else if (file.path.contains('/storage/emulated/0/Android/.Trash')) {
        } else if (file.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/.Shared')) {
        } else if (file.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/.trash')) {
        } else if (file.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Databases')) {
        } else if (file.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Backups')) {
        } else if (file.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/.StickerThumbs')) {
        } else if (file.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/.Thumbs')) {
        } else if (file.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Voice Notes')) {
        } else if (file.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Stickers')) {
        } else if (file.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Links')) {
        } else if (file.path.contains(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses')) {
        } else if (file.path.contains(
            '/storage/emulated/0/Android/media/com.google.android.gm')) {
        } else {
          if (!showHidden) {
            files.addAll(
                await getAllFilesInPath(file.path, showHidden: showHidden));
          } else {
            files.addAll(
                await getAllFilesInPath(file.path, showHidden: showHidden));
          }
        }
//          print(file.path);
        //print('Show hidden value is: ${showHidden}');
      }
    }
//    print(files);
    return files;
  }

  static getAllFilesWithIsolate(Map<String, dynamic> context) async {
    print(context);
    String isolateName = context['name'];
    //print('Get files');
    List<FileSystemEntity> files = await getAllFiles(showHidden: false);
    //print('Files $files');
    final messenger = HandledIsolate.initialize(context);
    try {
      final SendPort? send =
          IsolateNameServer.lookupPortByName('${isolateName}_2');
      send!.send(files);
    } catch (e) {
      print(e);
    }
    messenger.send('done');
  }

  //*************************************************************/

  switchCurrentFiles(List list, String label, String type) async {
    //print("this ran");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitfiles =
        (prefs.getStringList('keepitfiles') ?? List.empty());
    List<String> keepitStatus =
        (prefs.getStringList('keepitStatus') ?? List.empty());
    List<String> keepitDate =
        (prefs.getStringList('keepitDate') ?? List.empty());
    List<String> reloadfiles =
        (prefs.getStringList('reloadfiles') ?? List.empty());
    currentDirKeepFilesList = [];
    prefs.reload();
    String KeepItStatus = 'none';
    int KeepItDate = 0;

    // var x = keepitfiles.length;
    // var y = keepitStatus.length;
    // var z = keepitDate.length;

    // int keepitfilesLengthMin = [x, y, z].reduce(min);
    // int keepitfilesLengthMax = [x, y, z].reduce(max);
    // print("Keep me Max length: ${keepitfilesLengthMax}");
    // print("Keep me Min length: ${keepitfilesLengthMin}");

    // if (keepitfiles.length > keepitfilesLengthMin) {
    //   keepitfiles.removeRange(keepitfilesLengthMin, keepitfiles.length);
    //   prefs.setStringList('keepitfiles', keepitfiles);
    // }

    // if (keepitStatus.length > keepitfilesLengthMin) {
    //   keepitStatus.removeRange(keepitfilesLengthMin, keepitStatus.length);
    //   prefs.setStringList('keepitStatus', keepitStatus);
    // }

    // if (keepitDate.length > keepitfilesLengthMin) {
    //   keepitDate.removeRange(keepitfilesLengthMin, keepitDate.length);
    //   prefs.setStringList('keepitDate', keepitDate);
    // }

    getKeep(String path_to_file) async {
      var result = 'false';
      var status = 'none';
      var file = 'none';
      var date = 'none';
      var x = 0;
      for (var z = 0; z < keepitfiles.length; z++) {
        if (path_to_file == keepitfiles[z]) {
          result = keepitStatus[z];
        }
        x++;
      }
      if (x == keepitfiles.length) {
        return result;
      }
    }

    getDate(String path_to_file) async {
      var date = 'none';
      var x = 0;
      for (var z = 0; z < keepitfiles.length; z++) {
        if (path_to_file == keepitfiles[z]) {
          date = keepitDate[z];
        }
        x++;
      }
      if (x == keepitfiles.length) {
        return date;
      }
    }

    if (type == "keep") {
      List<FileSystemEntity> l = await compute(getTabGroups, [list, label]);
      currentKeep = l;
      List keep = currentKeep;
      List<FileSystemEntity> sortedFiles = [];

      onePackKeep.clear();

      if (label == "All") {
        currentKeep = keepfiles;
        for (var x = 0; x < keepfiles.length; x++) {
          File file = File(keepfiles[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackKeep.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        keepfiles.clear();
        keepfiles = sortedFiles;
      } else {
        for (var x = 0; x < currentKeep.length; x++) {
          File file = File(currentKeep[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackKeep.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        currentKeep.clear();
        currentKeep = sortedFiles;
      }
    }

    if (type == "downloads") {
      List<FileSystemEntity> l = await compute(getTabGroups, [list, label]);
      currentDownloadFiles = l;
      List download = currentDownloadFiles;
      List<FileSystemEntity> sortedFiles = [];

      onePackDownloads.clear();

      if (label == "All") {
        currentDownloadFiles = downloads;
        for (var x = 0; x < downloads.length; x++) {
          File file = File(downloads[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackDownloads.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        downloads.clear();
        downloads = sortedFiles;
      } else {
        for (var x = 0; x < currentDownloadFiles.length; x++) {
          File file = File(currentDownloadFiles[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackDownloads.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        currentDownloadFiles.clear();
        currentDownloadFiles = sortedFiles;
      }
    }

    if (type == "images") {
      List<FileSystemEntity> l = await compute(getTabGroups, [list, label]);
      currentImageFiles = l;
      List<FileSystemEntity> sortedFiles = [];
      List img = currentImageFiles;

      onePackImages.clear();

      if (label == "All") {
        currentImageFiles = images;
        for (var x = 0; x < images.length; x++) {
          File file = File(images[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackImages.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        images.clear();
        images = sortedFiles;
      } else {
        for (var x = 0; x < currentImageFiles.length; x++) {
          File file = File(currentImageFiles[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackImages.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        currentImageFiles.clear();
        currentImageFiles = sortedFiles;
      }
    }

    if (type == "audio") {
      List<FileSystemEntity> l = await compute(getTabGroups, [list, label]);
      currentAudioFiles = l;
      List<FileSystemEntity> sortedFiles = [];
      List audiof = currentAudioFiles;
      //print("switch This is current files ${keepitfiles}");

      onePackAudio.clear();

      if (label == "All") {
        currentAudioFiles = audio;
        for (var x = 0; x < audio.length; x++) {
          File file = File(audio[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackAudio.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        audio.clear();
        audio = sortedFiles;
      } else {
        for (var x = 0; x < currentAudioFiles.length; x++) {
          File file = File(currentAudioFiles[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackAudio.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        currentAudioFiles.clear();
        currentAudioFiles = sortedFiles;
      }
    }

    if (type == "documents") {
      List<FileSystemEntity> l = await compute(getTabGroups, [list, label]);
      currentDocumentFiles = l;
      List docs = currentDocumentFiles;
      List<FileSystemEntity> sortedFiles = [];
      //print("This is current files ${currentDocumentFiles}");

      onePackDocuments.clear();

      if (label == "All") {
        currentDocumentFiles = document;
        for (var x = 0; x < document.length; x++) {
          File file = File(document[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackDocuments.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        document.clear();
        document = sortedFiles;
      } else {
        for (var x = 0; x < currentDocumentFiles.length; x++) {
          File file = File(currentDocumentFiles[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = await path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackDocuments.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        currentDocumentFiles.clear();
        currentDocumentFiles = sortedFiles;
      }
    }

    if (type == "videos") {
      List<FileSystemEntity> l = await compute(getTabGroups, [list, label]);
      currentVideosFiles = l;
      //List videos = currentVideosFiles;
      List<FileSystemEntity> sortedFiles = [];
      //print("This is current files ${currentVideosFiles}");

      onePackVideos.clear();

      if (label == "All") {
        currentVideosFiles = video;
        for (var x = 0; x < video.length; x++) {
          File file = File(video[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackVideos.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        video.clear();
        video = sortedFiles;
      } else {
        for (var x = 0; x < currentVideosFiles.length; x++) {
          File file = File(currentVideosFiles[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackVideos.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        currentVideosFiles.clear();
        currentVideosFiles = sortedFiles;
      }
    }

    if (type == "all") {
      List<FileSystemEntity> l = await compute(getTabGroups, [list, label]);
      currentAllFiles = l;
      List all = currentAllFiles;
      List<FileSystemEntity> sortedFiles = [];
      //print("This is current files ${currentAllFiles}");

      onePackAll.clear();

      if (label == "All") {
        currentAllFiles = allfiles;
        for (var x = 0; x < allfiles.length; x++) {
          File file = File(allfiles[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            int daysBetween(DateTime from, DateTime to) {
              from = DateTime(from.year, from.month, from.day);
              to = DateTime(to.year, to.month, to.day);
              return (to.difference(from).inHours / 24).round();
            }

            var result = await getKeep(path);
            var date = await getDate(path);
            //print('Keep me Result Date is: ${date}');
            if (result != 'false') {
              KeepItStatus = result.toString();
              if (date.toString() != 'none') {
                final DateTime date1 = DateTime.parse(date.toString());
                final date2 = DateTime.now();
                final int difference = await daysBetween(date2, date1);

                //final DateTime time1 = DateTime.parse(date.toString());
                print("Keep me Date is: ${date1}");
                KeepItDate = difference;
                print("Keep me Different is: ${difference}");

                // var tt = await convertToAgo(date.toString());
                // print("Date is: ${tt}");
              } else {
                KeepItDate = 0;
              }
            } else {
              KeepItStatus = 'none';
              KeepItDate = 0;
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackAll.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        allfiles.clear();
        allfiles = sortedFiles;
      } else {
        for (var x = 0; x < currentAllFiles.length; x++) {
          File file = File(currentAllFiles[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackAll.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        currentAllFiles.clear();
        currentAllFiles = sortedFiles;
      }
    }

    if (type == "sort") {
      List<FileSystemEntity> l = await compute(getTabGroups, [list, label]);
      currentSortFiles = l;
      List sort = currentSortFiles;
      List<FileSystemEntity> sortedFiles = [];
      //print("This is current files ${currentAllFiles}");

      onePackSort.clear();

      if (label == "All") {
        currentSortFiles = sortfiles;
        for (var x = 0; x < sortfiles.length; x++) {
          File file = File(sortfiles[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            int daysBetween(DateTime from, DateTime to) {
              from = DateTime(from.year, from.month, from.day);
              to = DateTime(to.year, to.month, to.day);
              return (to.difference(from).inHours / 24).round();
            }

            var result = await getKeep(path);
            var date = await getDate(path);
            //print('Keep me Result Date is: ${date}');
            if (result != 'false') {
              KeepItStatus = result.toString();
              if (date.toString() != 'none') {
                final DateTime date1 = DateTime.parse(date.toString());
                final date2 = DateTime.now();
                final int difference = await daysBetween(date2, date1);

                //final DateTime time1 = DateTime.parse(date.toString());
                print("Keep me Date is: ${date1}");
                KeepItDate = difference;
                print("Keep me Different is: ${difference}");

                // var tt = await convertToAgo(date.toString());
                // print("Date is: ${tt}");
              } else {
                KeepItDate = 0;
              }
            } else {
              KeepItStatus = 'none';
              KeepItDate = 0;
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackSort.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        sortfiles.clear();
        sortfiles = sortedFiles;
      } else {
        for (var x = 0; x < currentSortFiles.length; x++) {
          File file = File(currentSortFiles[x].path);
          if (File(file.path).existsSync()) {
            String path = file.path;
            final stat = FileStat.statSync(path);
            sortedFiles.add(file);

            var result = await getKeep(path);
            //print('Result is: ${result}');
            if (result != 'false') {
              KeepItStatus = result.toString();
            } else {
              KeepItStatus = 'none';
            }

            var file_name = path
                .toString()
                .substring(path.toString().lastIndexOf('/'))
                .replaceAll("/", "")
                .replaceAll("/", "");

            onePackSort.add(FileOBJ(
                path,
                file_name,
                stat.size,
                DateTime.parse(stat.modified.toString()),
                KeepItStatus,
                KeepItDate));
          }
        }
        currentSortFiles.clear();
        currentSortFiles = sortedFiles;
      }
    }

    notifyListeners();
  }

  static Future<List<FileSystemEntity>> getTabGroups(List item) async {
    List items = item[0];
    String label = item[1];
    List<FileSystemEntity> files = [];
    items.forEach((file) {
      if ('${file.path.split('/')[file.path.split('/').length - 2]}' == label) {
        files.add(file);
      }
    });
    return files;
  }

  void setLoading(value) {
    loading = value;
    notifyListeners();
  }
}
