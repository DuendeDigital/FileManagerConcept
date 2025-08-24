import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:keepit/features/home/dashboard.dart';
import 'package:keepit/features/traverse/widgets/bottomsheet_data.dart';
import 'package:keepit/features/traverse/widgets/bottomsheet_form.dart';
import 'package:keepit/models/traverse_model.dart';
import 'package:keepit/constants/utils/controls.dart' as controls;
import 'package:keepit/main.dart' as main;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:collection';
import 'dart:io';
import 'package:thumbnailer/thumbnailer.dart';
import 'package:mime/mime.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';
import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:keepit/common/subscriptions.dart';

class TraverseScreenExternal extends StatefulWidget {
  static const String routeName = '/traverse2';

  // const TraverseScreenExternal({super.key});

  final String value;

  const TraverseScreenExternal({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  State<TraverseScreenExternal> createState() => _TraverseScreenExternalState();
}

enum _MenuValues {
  SelectAll,
  SortBy,
  NewCollection,
}

class _TraverseScreenExternalState extends State<TraverseScreenExternal> {
  final BottomSheet_Data bottomsheet_methods = new BottomSheet_Data();
  //GLOBAL VARIABLES
  // var local_path = '/storage/emulated/0';
  var local_path;

  /// Convert Byte to KB, MB, .......
  static String formatBytes(bytes, decimals) {
    if (bytes == 0) return '0.0 KB';
    var k = 1024,
        dm = decimals <= 0 ? 0 : decimals,
        sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
        i = (log(bytes) / log(k)).floor();
    return (((bytes / pow(k, i)).toStringAsFixed(dm)) + ' ' + sizes[i]);
  }

  void traverse(current_dir) async {
    Directory dir = new Directory(current_dir); //Internal Storage
  
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool showHiddenVal = prefs.getBool('showHidden') ?? false;
    List<FileSystemEntity> files =
        dir.listSync(recursive: false); //Returns the subdirectories

    // print(files);
    print(files.length.toString() + ' File length');
    items.clear();

    for (FileSystemEntity file in files) {
      String folderName = file.path.split('/').last;

      if (showHiddenVal == false) {
        if (!folderName.startsWith('.')) {

          var path = file.uri;
          var strip_path = path.toFilePath().replaceAll(current_dir, "");

          // print(strip_path);

          // String folder = strip_path.substring(0, strip_path.length - 1).toString();
          // print(folder);
          late String folder;

          FileStat info = file
              .statSync(); //Returns more info about the file (date file created)
          String date_created = info.modified
              .toString()
              .substring(0, info.modified.toString().indexOf(' '));
          int file_size;
          // String file_size = '';

          print(info.type.toString());

          // if(info.type.toString()=='directory' || info.type.toString() == 'file'){
          folder = strip_path
              .substring(0, strip_path.length)
              .toString()
              .replaceAll('/', '');
          traverse_path.clear();
          traverse_path.add(current_dir);

          // }else{
          //   // print('This file is unsupported');
          // }

          var thumbnail;
          var file_type;
          var mimeType;

          if (info.type.toString() == 'file') {
            file_type = folder.substring(folder.toString().lastIndexOf('.'));
            // print(file_type);

            mimeType = lookupMimeType(folder);

            if (mimeType == null) {
              continue;
            }
            print('Mime Type ' + mimeType.toString());
          } else {
            folder = folder.toString().replaceAll('/', '');
          }

          if (file_type.toString() == '.jpg' ||
              file_type.toString() == '.jpeg' ||
              file_type.toString() == '.png') {
            thumbnail = traverse_path[0] + '/' + folder;
            file_size = info.size;
          } else {
            thumbnail = 'assets/yellow_folder.png';
            file_size = info.size;
            if (file_type.toString() == '.mp3' || file_type.toString() == '.mp4') {
              file_size = info.size;
            } else {
              file_size = 0;
            }
          }

          print(folder);
          print('Path now is ' + traverse_path[0]);
          print(mimeType.toString());

          thumbnail = traverse_path[0] + '/' + folder;
          setState(() {
            items.add(TraverseModel(thumbnail, folder, DateTime.parse(date_created), file_size,
                false, file_type.toString(), mimeType.toString()));
          });

        }
      }else{

        var path = file.uri;
        var strip_path = path.toFilePath().replaceAll(current_dir, "");

        // print(strip_path);

        // String folder = strip_path.substring(0, strip_path.length - 1).toString();
        // print(folder);
        late String folder;

        FileStat info = file
            .statSync(); //Returns more info about the file (date file created)
        String date_created = info.modified
            .toString()
            .substring(0, info.modified.toString().indexOf(' '));
        int file_size;
        // String file_size = '';

        print(info.type.toString());

        // if(info.type.toString()=='directory' || info.type.toString() == 'file'){
        folder = strip_path
            .substring(0, strip_path.length)
            .toString()
            .replaceAll('/', '');
        traverse_path.clear();
        traverse_path.add(current_dir);

        // }else{
        //   // print('This file is unsupported');
        // }

        var thumbnail;
        var file_type;
        var mimeType;

        if (info.type.toString() == 'file') {
          file_type = folder.substring(folder.toString().lastIndexOf('.'));
          // print(file_type);

          mimeType = lookupMimeType(folder);

          if (mimeType == null) {
            continue;
          }
          print('Mime Type ' + mimeType.toString());
        } else {
          folder = folder.toString().replaceAll('/', '');
        }

        if (file_type.toString() == '.jpg' ||
            file_type.toString() == '.jpeg' ||
            file_type.toString() == '.png') {
          thumbnail = traverse_path[0] + '/' + folder;
          file_size = info.size;
        } else {
          thumbnail = 'assets/yellow_folder.png';
          file_size = info.size;
          if (file_type.toString() == '.mp3' || file_type.toString() == '.mp4') {
            file_size = info.size;
          } else {
            file_size = 0;
          }
        }

        print(folder);
        print('Path now is ' + traverse_path[0]);
        print(mimeType.toString());

        thumbnail = traverse_path[0] + '/' + folder;
        setState(() {
          items.add(TraverseModel(thumbnail, folder, DateTime.parse(date_created), file_size,
              false, file_type.toString(), mimeType.toString()));
        });

      }
    }

    // print(files.length);
  }

  List<String> traverse_path = [];
  List<TraverseModel> items = [
    // TraverseModel('assets/folder_traverse.png','Android','2016-03-04','60MB', false),
    // TraverseModel('assets/folder_traverse.png','Backups','2018-12-25','15MB', false),
    // TraverseModel('assets/folder_traverse.png','Data','2021-03-10','20MB', false),
    // TraverseModel('assets/folder_traverse.png','DCIM','2022-05-22','40MB', false),
    // TraverseModel('assets/folder_traverse.png','Documents','2019-10-15','20MB', false),
    // TraverseModel('assets/folder_traverse.png','Downloads','2020-06-21','30MB', false)
  ];

  List<String> sortlistitems = [
    'Name A to Z',
    'Name Z to A',
    'Newest date first',
    'Oldest date first',
    'Largest first',
    'Smallest first',
  ];

  HashSet selectItems = new HashSet();
  bool isMultiSelectionEnabled = false;
  bool done_action = false;

  HashSet selectItems_sort = new HashSet();

  String? selectedItem = 'Name A to Z';

  void initalSort() {
    selectItems_sort.add(selectedItem);
  }

  void initState() {
    super.initState();
    initalSort();
    local_path = widget.value.toString().substring(0, widget.value.length - 1);
    traverse(local_path);
    print('Initial State ' + local_path);
  }

  bool isGrid = false;
  int sort = 0;

  void doSingleSelection(String path) {
    setState(() {
      if (selectItems.contains(path)) {
        selectItems.remove(path);
      } else {
        selectItems.clear();
        selectItems.add(path);
        // List<String> selected_files = selectItems.toList() as List<String>;

        checkSub().then((value) {
          showModalBottomSheet(
            context: context,
            enableDrag: true,
            isDismissible: true,
            isScrollControlled: false,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.0),
            )),
            // backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
              child: bottomsheet_methods.bottomSheet(
                  context, [path.toString()], value),
            ),
          ).whenComplete(() {
            setState(() {
              isMultiSelectionEnabled = false;
              selectItems.clear();
              done_action = false;
            });
          });
        });
      }
      // print(path);
    });

    // print(selectItems);
  }

  String getSelectedItemCount() {
    return selectItems.isNotEmpty
        ? selectItems.length.toString() + " item selected"
        : "No item selected";
  }

  void doMultiSelection(String path) {
    // if (isMultiSelectionEnabled) {
    setState(() {
      if (selectItems.contains(path)) {
        selectItems.remove(path);
      } else {
        selectItems.add(path);
      }

      selectItems.isNotEmpty ? done_action = true : done_action = false;
    });

    // } else {

    // }
  }

  void doSortSelection(String path) {
    setState(() {
      if (selectItems_sort.contains(path)) {
        selectItems_sort.remove(path);
      } else {
        selectItems_sort.clear();
        selectItems_sort.add(path);
      }

      // print(selectItems_sort);
    });
  }

  void selectAll(String path) {
    if (isMultiSelectionEnabled) {
      setState(() {
        if (selectItems.contains(path)) {
          // selectItems.remove(path);
        } else {
          selectItems.add(path);
        }
      });

      selectItems.isNotEmpty ? done_action = true : done_action = false;
    }
  }

  late bool subbed;
  Future<bool> checkSub() async {
    subbed = await Subscription().checkSubscription();
    return await Subscription().checkSubscription();
  }

  void back_func() {
    setState(() {
      var back = traverse_path[0]
          .toString()
          .substring(0, traverse_path[0].toString().lastIndexOf('/'));
      local_path = back;
      traverse_path.clear();
      traverse_path.add(back);

      if (back != '/storage') {
        traverse(back);
        print('Back to path ' + back);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, HomeScreen.routeName, (route) => false);
        print('Back to home path ' + back);
        print('Back to home path2 ' + local_path.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    local_path = arguments['storage_type'].toString();
    // print('The new storage type' + arguments['storage_type'].toString());

    return WillPopScope(
      onWillPop: () async {
        // Do something here
        back_func();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            leading: isMultiSelectionEnabled
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isMultiSelectionEnabled = false;
                        selectItems.clear();
                        done_action = false;
                      });
                    },
                    icon: Container(width: 200.0, child: Icon(Icons.close)))
                : traverse_path.length > 0
                    ? ExpandTapWidget(
                        tapPadding: EdgeInsets.all(155.0),
                        onTap: () {
                          setState(() {
                            var back = traverse_path[0].toString().substring(0,
                                traverse_path[0].toString().lastIndexOf('/'));
                            local_path = back;
                            traverse_path.clear();
                            traverse_path.add(back);

                            if (back != '/storage') {
                              traverse(back);
                              print('Back to path ' + back);
                            } else {
                              Navigator.pushNamedAndRemoveUntil(context,
                                  HomeScreen.routeName, (route) => false);
                              print('Back to home path ' + back);
                              print('Back to home path2 ' +
                                  local_path.toString());
                            }
                          });
                        },
                        child: Container(
                            width: 200.0, child: Icon(Icons.arrow_back)))
                    : GestureDetector(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, HomeScreen.routeName, (route) => false);
                        },
                        child: Container(
                            width: 200.0, child: Icon(Icons.arrow_back))),
            title: Text(isMultiSelectionEnabled
                ? getSelectedItemCount()
                : "External Storage"),
            elevation: 0,
            backgroundColor: Color.fromRGBO(43, 104, 210, 1),
            actions: [
              PopupMenuButton<_MenuValues>(
                color: Color.fromRGBO(34, 34, 34, 1),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    child: Text('Select All',
                        style: TextStyle(color: Colors.white)),
                    value: _MenuValues.SelectAll,
                  ),
                  PopupMenuItem(
                    child:
                        Text('Sort By', style: TextStyle(color: Colors.white)),
                    value: _MenuValues.SortBy,
                  ),
                  PopupMenuItem(
                    child: Text('New Folder',
                        style: TextStyle(color: Colors.white)),
                    value: _MenuValues.NewCollection,
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case _MenuValues.SelectAll:
                      for (var x = 0; x <= items.length; x++) {
                        isMultiSelectionEnabled = true;
                        if (items[x].file_type.toString() != "null") {
                          selectAll(items[x].thumbnail);
                          // print('Selected All');
                        }
                      }

                      break;

                    case _MenuValues.SortBy:
                      showModalBottomSheet(
                        backgroundColor: Color.fromRGBO(34, 34, 34, 1),
                        context: context,
                        enableDrag: true,
                        isDismissible: true,
                        // barrierColor: Colors.white.withOpacity(0),
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.0),
                        )),
                        // backgroundColor: Colors.transparent,
                        builder: (context) => Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                          child: SortList(),
                        ),
                      );

                      break;

                    case _MenuValues.NewCollection:
                      break;
                  }
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(30),
              child: Container(),
            )),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              // image: DecorationImage(Image.asset("mobile_bg.png"),fit: BoxFit.cover),
              image: DecorationImage(
                  image: AssetImage("assets/mobile_bg2.png"),
                  fit: BoxFit.cover)),
          child: buildList(),
        ),
        floatingActionButton: Visibility(
          visible: isMultiSelectionEnabled ? done_action : false,
          child: FloatingActionButton.extended(
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            onPressed: () {
              var items = selectItems.toList();
              List<String> items_selected = [];

              for (var file in items) {
                items_selected.add(file);
              }
              checkSub().then((value) {
                showModalBottomSheet(
                  context: context,
                  enableDrag: true,
                  isDismissible: true,
                  // barrierColor: Colors.white.withOpacity(0),
                  isScrollControlled: false,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.0),
                  )),
                  // backgroundColor: GlobalVariables.backgroundColor,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                    child: bottomsheet_methods.bottomSheet(
                        context, items_selected, value),
                  ),
                );
              });
            },
            label: const Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Icon(Icons.done, size: 40.0),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(150.0),
            ),
          ),
        ),
      ),
    );
  }

  ScrollController _scrollController = new ScrollController();
  Widget buildList() => ListView.builder(
        controller: _scrollController,
        itemCount: items.length,
        itemBuilder: (context, index) {
          late final sortedItems;

          switch (sort) {
            case 0:
              sortedItems = items
                ..sort(
                    (a, b) => a.name.toString().compareTo(b.name.toString()));
              break;

            case 1:
              sortedItems = items
                ..sort(
                    (a, b) => b.name.toString().compareTo(a.name.toString()));
              break;

            case 2:
              sortedItems = items
                ..sort((a, b) => b.date_created.millisecondsSinceEpoch.compareTo(a.date_created.millisecondsSinceEpoch));
              break;

            case 3:
              sortedItems = items
                ..sort((a, b) => a.date_created.millisecondsSinceEpoch.compareTo(b.date_created.millisecondsSinceEpoch));
              break;

            case 4:
              sortedItems = items
                ..sort((a, b) => b.file_size.compareTo(a.file_size));
              break;

            case 5:
              sortedItems = items
                ..sort((a, b) => a.file_size.compareTo(b.file_size));
              break;
          }

          var thumbnail = sortedItems[index].thumbnail;
          final name = sortedItems[index].name;
          final date_created = DateFormat('dd/MM/yyyy').format(sortedItems[index].date_created);
          var file_size = sortedItems[index].file_size;
          final file_type = sortedItems[index].file_type;
          final isSelected = sortedItems[index].isSelected;
          final can_open = sortedItems[index].can_open;

          file_size = formatBytes(file_size, 1).toString();

          print("The thumbnail ${thumbnail}");
          List file_ext = [
            'ai',
            'apk',
            'avi',
            'bmp',
            'crd',
            'csv',
            'dll',
            'doc',
            'docx',
            'dwg',
            'eps',
            'exe',
            'flv',
            'gif',
            'html',
            'iso',
            'mdb',
            'mid',
            'mov',
            'mp3',
            'mp4',
            'mpeg',
            'pdf',
            'ps',
            'psd',
            'ptt',
            'pub',
            'rar',
            'raw',
            'rss',
            'svg',
            'tiff',
            'txt',
            'wav',
            'webm',
            'wma',
            'xls',
            'xlsx',
            'xml',
            'zip'
          ];

          print(can_open.toString());

          final Widget asset_path;
          var its_a_folder;

          if (can_open.toString() == "null") {
            asset_path = Image.asset("assets/yellow_folder.png");
            its_a_folder = "folder";
            file_size = '';
          } else {
            if (file_ext.contains(file_type.toString().substring(1))) {
              asset_path = Image.asset(
                  "assets/${file_type.toString().substring(1)}.png",
                  width: 60,
                  height: 60);
              its_a_folder = null;
            } else {
              if (file_type.toString() == ".jpg" ||
                  file_type.toString() == ".jpeg" ||
                  file_type.toString() == ".png") {
                asset_path = Image.file(File(thumbnail),
                    cacheHeight: 150, cacheWidth: 150);
                its_a_folder = null;
              } else {
                asset_path = Image.asset("assets/general.png");
                its_a_folder = null;
              }
            }
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20.0),
            child: Column(
              children: [
                its_a_folder != 'folder'
                    ? ListTile(
                        leading: asset_path,
                        title:
                            Text(name, style: TextStyle(color: Colors.white)),
                        subtitle: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${file_size} | ${date_created}',
                                  style: TextStyle(
                                      color: Color.fromRGBO(222, 222, 222, 1))),
                              const Divider(
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                                color: Colors.white,
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                        trailing: Visibility(
                          visible: selectItems.contains(thumbnail),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 20.0),
                        ),
                        onTap: () {
                          isMultiSelectionEnabled
                              ? doMultiSelection(thumbnail)
                              : doSingleSelection(thumbnail);
                          print('OnTap Test ${thumbnail}');
                        },
                        onLongPress: () {
                          setState(() {
                            items[index].isSelected = !items[index].isSelected;
                            isMultiSelectionEnabled = true;
                            doMultiSelection(thumbnail);
                            print('OnLongPress Test ${thumbnail}');
                          });
                        },
                      )
                    : ListTile(
                        leading: asset_path,
                        title:
                            Text(name, style: TextStyle(color: Colors.white)),
                        subtitle: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${date_created}',
                                  style: TextStyle(
                                      color: Color.fromRGBO(222, 222, 222, 1))),
                              const Divider(
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                                color: Colors.white,
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          // print('This is ' + can_open.toString());
                          // can_open.toString() != 'null' ?
                          setState(() {
                            if (local_path.toString() == 'null') {
                              local_path += traverse_path[0] + '/' + name;
                              traverse(local_path.toString().substring(4));
                              print('On Tap Path 1: ' +
                                  local_path.toString().substring(4));
                            } else {
                              local_path += traverse_path[0] + name;
                              traverse(local_path);
                              print('On Tap Path 2 ' + local_path);
                            }
                          });

                          _scrollController.animateTo(
                              _scrollController.position.minScrollExtent,
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeOut);
                          // :
                          // Fluttertoast.showToast(
                          //     msg: 'This type of file is unsupported',
                          //     toastLength: Toast.LENGTH_SHORT,
                          //     gravity: ToastGravity.BOTTOM,
                          //     timeInSecForIosWeb: 1,
                          //     backgroundColor: Colors.red,
                          //     textColor: Colors.white,
                          //     fontSize: 16.0
                          // );

                          // traverse_path.clear();
                          // traverse_path.add(local_path);

                          // print('Path now is ' + traverse_path[0]);
                        },
                        onLongPress: () {
                          setState(() {});
                        },
                      ),
              ],
            ),
          );
        },
      );

  Widget SortList() => ListView.builder(
        itemCount: sortlistitems.length,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final sortby = sortlistitems[index];

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              key: UniqueKey(),
              title: Center(
                  child: Text(sortby,
                      style: TextStyle(
                          fontWeight: FontWeight.w400, color: Colors.white))),
              trailing: selectItems_sort.contains(sortby)
                  ? const Icon(Icons.check, color: Colors.white, size: 20.0)
                  : const Text(''),
              onTap: () {
                setState(() {
                  selectedItem = sortby;
                  // print(selectedItem);

                  doSortSelection(sortby);

                  for (var x = 0; x < sortlistitems.length; x++) {
                    if (selectedItem == sortlistitems[x]) {
                      setState(() {
                        sort = x;
                        Navigator.of(context).pop();
                      });
                    }
                  }
                });
              },
            ),
          );
        },
      );
}
