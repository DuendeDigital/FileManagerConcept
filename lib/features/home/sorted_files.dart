import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:keepit/constants/custom_toast.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:keepit/constants/hide_notification.dart';
import 'package:keepit/constants/utils/file_utils.dart';
import 'package:keepit/constants/utils/files.dart';
import 'package:keepit/constants/utils/loader.dart';
import 'package:keepit/constants/utils/tags.dart';
import 'package:keepit/features/home/dashboard.dart';
import 'package:keepit/features/traverse/widgets/bottomsheet_data.dart';
import 'package:keepit/models/collections_model.dart';
import 'package:keepit/models/filter_file_obj.dart';
import 'package:keepit/models/filter_tags.dart';
import 'package:keepit/models/images_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:keepit/providers/category_provider.dart';
import 'package:mime_type/mime_type.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:keepit/constants/utils/controls.dart' as controls;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keepit/constants/custom_toast.dart' as CustomToast;
import 'package:keepit/common/subscriptions.dart';

class Sorted_Files extends StatefulWidget {
  static const String routeName = '/sorted_files';
  // const Sorted_Files({
  //   Key? key,
  //   required this.value,xf

  // }): super(key: key);
  final int value;
  void getTags() {
    _Sorted_FilesState(this.value).getTags();
  }

  const Sorted_Files(this.value, {Key? key, Key? superKey})
      : super(key: superKey);

  @override
  State<Sorted_Files> createState() => _Sorted_FilesState(this.value);
}

enum _MenuValues { SelectAll, SortBy, FilterBy, NewCollection, NewTagGroup }

class _Sorted_FilesState extends State<Sorted_Files>
    with SingleTickerProviderStateMixin {
  List<Tab> tabs = [
    Tab(child: Text("KeepIt")),
    Tab(child: Text("KeepItFor")),
    Tab(child: Text("DeleteIt Bin")),
  ];

  final int value;
  _Sorted_FilesState(this.value);

  late Color colors;
  var filtered;
  var filtered_date;
  bool isGrid = true;
  bool keepit_bin = false;
  late TextEditingController _textFieldController;
  final BottomSheet_Data bottomsheet_methods = new BottomSheet_Data();
  late int tab_length;
  var local_path;
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
  static HashSet selectItems_filter = new HashSet();
  String? selectedItem = 'Name A to Z';
  String? collection_folder;
  List<CollectionsModel> items = [];
  List<String> collection_folder_names = [];
  List<FileSystemEntity> collection_files = [];
  bool switch_value = false;
  var bin = false;
  final ScrollController scrollController = ScrollController();
  double scrollOffset = 0.0;

  Key _refreshKey = UniqueKey();

  static String formatBytes(bytes, decimals) {
    if (bytes == 0) return '0.0 KB';
    var k = 1024,
        dm = decimals <= 0 ? 0 : decimals,
        sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
        i = (log(bytes) / log(k)).floor();
    return (((bytes / pow(k, i)).toStringAsFixed(dm)) + ' ' + sizes[i]);
  }

  void initalSort() {
    selectItems_sort.add(selectedItem);
  }

  int sort = 0;
  var items_length = 0;

  void doSingleSelection(String path) {
    setState(() {
      if (selectItems.contains(path)) {
        selectItems.remove(path);
      } else {
        selectItems.clear();
        selectItems.add(path);

        if (bin) {
        } else {
          showModalBottomSheet(
            context: context,
            enableDrag: true,
            isDismissible: true,
            isScrollControlled: false,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.0),
            )),
            builder: (context) => Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
              child: bottomsheet_methods.bottomSheet(
                  context, [path.toString()], subbed),
            ),
          ).whenComplete(() {
            setState(() {
              switch_value = true;
              buildTabView(current_tab_status);
              isMultiSelectionEnabled = false;
              selectItems.clear();
              done_action = false;
            });
          });
        }
      }
    });
  }

  String getSelectedItemCount() {
    return selectItems.isNotEmpty
        ? selectItems.length.toString() + " item selected"
        : "No item selected";
  }

  void doMultiSelection(String path) {
    setState(() {
      if (selectItems.contains(path)) {
        selectItems.remove(path);
      } else {
        selectItems.add(path);
      }

      selectItems.isNotEmpty ? done_action = true : done_action = false;
    });
  }

  void doMultiSelectionFilter(String path) {
    setState(() {
      if (selectItems_filter.contains(path)) {
        selectItems_filter.remove(path);
      } else {
        selectItems_filter.add(path);
      }
    });
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

  void get_collections() async {
    var foo = await controls.Controls().get_all_collections('sorted_files');

    for (int i = 0; i < foo.length; i++) {
      var collection_name = foo[i].path.split("/");
      tab_length = tabs.length;
      setState(() {
        collection_folder_names.add(collection_name.last);
      });
    }

    // print(tabs.length);
  }

  void restore_files(List<String> files) async {
    var success = await KeepFiles().restoreFile(files);
    print("Last result from restore $success");
    if (success) {
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
        builder: (context) => CustomToast.CustomToast().CustomToastNotification(
            Colors.green,
            Colors.amber,
            "assets/check.png",
            "File Restored!",
            "Your file(s) have been restored successfully.",
            context),
      );
      Provider.of<CategoryProvider>(context, listen: false).getImages('image');
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
        builder: (context) => CustomToast.CustomToast().CustomToastNotification(
            Colors.red,
            Colors.amber,
            "assets/close.png",
            "Error!",
            "We could not move your file to this destination. Please try again.",
            context),
      ).then((value) => restore_files(files));
    }
    // if (success!) {
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
    //     builder: (context) => CustomToastBin(context, true),
    //   );
    // } else {
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
    //     builder: (context) => CustomToastBin(context, false),
    //   ).then((value) => restore_files(files));
    // }
  }

  Widget CustomToastBin(BuildContext context, bool success) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0)),
                child: Container(
                  color: success ? Colors.green[700] : Colors.red[700],
                  width: 50.0,
                  height: 150,
                  child: Text(''),
                ),
              ),
              Expanded(
                  child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0)),
                child: Container(
                  color: Colors.amber[700],
                  height: 150,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/keepit.png",
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Done!",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                              const SizedBox(height: 15.0),
                              Text(
                                  success
                                      ? "Success"
                                      : "Whoops! An error has occured.",
                                  style: TextStyle(
                                      color: Colors.white, height: 1.3))
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    // Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 10.0, 10.0, 0),
                                    // child: const Text("Dismiss", style: TextStyle(color: Color.fromARGB(255, 49, 49, 49), fontWeight: FontWeight.bold)),
                                    child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 30.0,
                                        )),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 20,
            color: Colors.transparent,
            child: Text(""),
          ),
        ],
      ),
    );
  }

  Widget DeleteCustomToast(int length, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0)),
              child: Container(
                color: Colors.red[700],
                width: 50.0,
                height: 150,
                child: Text(''),
              ),
            ),
            Expanded(
                child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0)),
              child: Container(
                color: Colors.amber[300],
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/delete.png",
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("File(s) Deleted!",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0)),
                            const SizedBox(height: 10.0),
                            Text(
                                "All selected files in the bin have been permanently deleted!",
                                style:
                                    TextStyle(color: Colors.white, height: 1.3))
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  // Navigator.of(context).pop();
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 25.0, 0, 0),
                                  // child: const Text("Dismiss", style: TextStyle(color: Color.fromARGB(255, 49, 49, 49), fontWeight: FontWeight.bold)),
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 30.0,
                                      )),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 20,
          color: Colors.transparent,
          child: Text(""),
        ),
      ],
    );
  }

  Widget KeepItCustomToast(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0)),
                child: Container(
                  color: Colors.green[700],
                  width: 50.0,
                  height: 150,
                  child: Text(''),
                ),
              ),
              Expanded(
                  child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0)),
                child: Container(
                  color: Colors.amber[700],
                  height: 150,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/keepit.png",
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Done!",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                              const SizedBox(height: 15.0),
                              Text("All items in the bin have been restored!",
                                  style: TextStyle(
                                      color: Colors.white, height: 1.3))
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    // Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 10.0, 10.0, 0),
                                    // child: const Text("Dismiss", style: TextStyle(color: Color.fromARGB(255, 49, 49, 49), fontWeight: FontWeight.bold)),
                                    child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 30.0,
                                        )),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 20,
            color: Colors.transparent,
            child: Text(""),
          ),
        ],
      ),
    );
  }

  late TabController _tabController;
  late String tab_index;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tab_index = widget.value.toString();
    print('Value started ${tab_index}');

    //Provider.of<CategoryProvider>(context, listen: false).allKeepFiles();
    _textFieldController = TextEditingController();
    get_collections();
    _tabController = TabController(vsync: this, length: 3);

    if (value == 0) {
      setState(() {
        //_refreshKey = UniqueKey();
        current_tab_status = 'keep';
        keepit_bin = false;
        bin = false;
        switch_value = true;
        buildTabView(current_tab_status);
      });
    }

    if (value == 1) {
      setState(() {
        //_refreshKey = UniqueKey();
        current_tab_status = 'keep_for';
        keepit_bin = true;
        bin = false;
        switch_value = true;
        buildTabView(current_tab_status);
      });
    }

    if (value == 2) {
      setState(() {
        //_refreshKey = UniqueKey();
        current_tab_status = 'keep_for';
        keepit_bin = false;
        bin = true;
        switch_value = true;
        buildTabView(current_tab_status);
      });
    }

    print("Value is ${value}");

    getTags();
    checkSub().whenComplete(() {
      setState(() {});
    });

    isMultiSelectionEnabled = false;
    selectItems.clear();
    done_action = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textFieldController.dispose();
    _tabController.dispose();
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Please Enter The Folder Name',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(22, 86, 176, 1))),
            content: TextField(
              autofocus: true,
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Folder Name"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print('Close Sign');
                  _textFieldController.clear();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final validCharacters = RegExp(r'^[9&%=-_\-=@,\.;]+$');


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


                  if (!validCharacters.hasMatch(_textFieldController.text)) {
                    String str = _textFieldController.text;

                    /// trims leading whitespace
                    String ltrim(String str) {
                      return str.replaceFirst(new RegExp(r"^\s+"), "");
                    }

                    String left = ltrim(str);

                    /// trims trailing whitespace
                    String rtrim(String left) {
                      return left.replaceFirst(new RegExp(r"\s+$"), "");
                    }

                    String right = rtrim(left);
                    //Add to collection
                    bool created_collection =
                        await controls.Controls().create_collection(right);

                    //Check if collection name already exists
                    if (created_collection) {
                      get_collections();
                      var notice = await HideNotification().setValue();
                      Navigator.of(context).pop();

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
                                "New Folder Created",
                                "A new Folder was successfully created",
                                context),
                      ).then((value) {
                        setState(() {
                          print("keep me: dashboard new folder has been added");
                          get_collections();
                          // prefs.setBool('istabResumed', false);
                          Navigator.pop(context);
                        });
                      });


                      // get_collections();
                      _textFieldController.clear();
                    } else {
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
                                "Already Exist",
                                "A Folder with the given name already exist",
                                context),
                      );

                      _textFieldController.clear();
                    }
                  } else {
                    Navigator.pop(context);
                    var notice = await HideNotification().setValue();
                    _textFieldController.clear();
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
                              "Invalid Characters",
                              "Name contains invalid characters. Please try again.",
                              context),
                    );
                  }
                },
                child: const Text('Okay'),
              ),
            ],
          );
        });
  }

  var current_tab_status = "keep";

  List<String> tagNames = [];
  void getTags() async {
    //Get tags and set global array
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> temp = prefs.getStringList('tagNames') ?? List.empty();

    if (tagNames.length > 0) {
      tagNames.clear();
    }

    for (String i in temp) {
      tagNames.add(i);
    }
    print("SPHA TAGS ARE $tagNames");
  }

  List<FilterTags> one_pack = [];
  List<FileSystemEntity> temporary_paths = [];
  List<String> cached_path = [];
  List<String> filters = [];

  void getlist(String filter, List files) async {
    // List<String> tags = ["Audio", "Video,Audio", "Images"];
    // List<String> file_paths = ["emulated/0/audio/drake.mp3", "emulated/0/audio/eminem.mp3", "emulated/0/images/me.jpg"];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tags = prefs.getStringList('keepitFiletags') ?? List.empty();
    List<String> file_paths = (prefs.getStringList('tagFiles') ?? List.empty());

    checkFileInList(file_path) {
      List return_value = [];
      for (int i = 0; i < files.length; i++) {
        String filepath = files[i].thumbnail.toString();
        if (filepath.contains(file_path)) {
          return_value.add(filepath);
        }
      }
      if (return_value.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }

    for (var x = 0; x < file_paths.length; x++) {
      var file_check = await checkFileInList(file_paths[x]);
      if (file_check == true) {
        one_pack.add(FilterTags(file_paths[x], tags[x]));
      }
    }

    List<FilterTags> filterlist = one_pack.where((filterResult) {
      final result = filterResult.tags.toLowerCase();

      final input = filter;

      return result.contains(input.toLowerCase());
    }).toList();

    for (var i = 0; i < filterlist.length; i++) {
      if (cached_path.contains(filterlist[i].file_path)) {
        //Do not add file
      } else {
        temporary_paths.add(File(filterlist[i].file_path));
        cached_path.add(filterlist[i].file_path);
      }
    }

    for (var x = 0; x < temporary_paths.length; x++) {
      // print('All the filtered files ${temporary_paths[x]}');
    }

    if (!filters.contains(filter)) {
      filters.add(filter);
    }

    print('The filters ${filters}');
    create_object_of_filtered_list();
  }

  void deselect(String filter, List files) {
    temporary_paths.clear();
    cached_path.clear();
    print('Before removing the filter ${filters}');
    filters.remove(filter.toString());
    for (var x = 0; x < filters.length; x++) {
      getlist(filters[x], files);
      print('Re rendering list');
    }
  }

  late bool subbed = false;
  Future<void> checkSub() async {
    setState(() async {
      subbed = await Subscription().checkSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          isMultiSelectionEnabled = false;
          selectItems.clear();
          done_action = false;
          // Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false);

          return Future.value(true);
        },
        child: Consumer(
            key: _refreshKey,
            builder: (BuildContext context, CategoryProvider provider,
                Widget? child) {
              List list = provider.onePackSort;

              return DefaultTabController(
                initialIndex: value,
                length: tabs.length,
                child: SafeArea(
                  bottom: true,
                  left: true,
                  top: true,
                  right: true,
                  maintainBottomViewPadding: true,
                  minimum: EdgeInsets.zero,
                  child: Scaffold(
                    // extendBodyBehindAppBar: true,
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
                              icon: Icon(Icons.close))
                          : GestureDetector(
                              onTap: (() {
                                isMultiSelectionEnabled = false;
                                selectItems.clear();
                                done_action = false;
                                // Navigator.pop(context);
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()),
                                    (Route<dynamic> route) => false);
                              }),
                              child: Icon(Icons.arrow_back)),

                      title: Text(isMultiSelectionEnabled
                          ? getSelectedItemCount()
                          : "Sorted Files"),
                      elevation: 0,
                      backgroundColor: Color.fromRGBO(43, 104, 210, 1),
                      // centerTitle: true,
                      bottom: PreferredSize(
                        preferredSize: keepit_bin || bin
                            ? const Size.fromHeight(190)
                            : const Size.fromHeight(50),
                        child: Column(
                          children: [
                            TabBar(
                                indicatorColor: Colors.white,
                                isScrollable: true,
                                tabs: tabs,
                                onTap: (val) {
                                  if (val == 1) {
                                    setState(() {
                                      current_tab_status = 'keep_for';
                                      keepit_bin = true;
                                      bin = false;
                                      switch_value = true;
                                      buildTabView(current_tab_status);
                                    });
                                  } else if (val == 0) {
                                    setState(() {
                                      current_tab_status = 'keep';
                                      keepit_bin = false;
                                      bin = false;
                                      switch_value = true;
                                      buildTabView(current_tab_status);
                                    });
                                  } else if (val == 2) {
                                    setState(() {
                                      current_tab_status = 'keep_for';
                                      keepit_bin = false;
                                      bin = true;
                                      switch_value = true;
                                      buildTabView(current_tab_status);
                                    });
                                  }
                                }),

                            keepit_bin
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.yellow[700],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 20.0, 10, 20.0),
                                              child: Image.asset(
                                                  'assets/keep_file.png',
                                                  width: 100,
                                                  height: 100),
                                            )),
                                        Expanded(
                                          flex: 6,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 10.0, 0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                    'Files with a keep for status will be permanently deleted when their chosen date is reached'),
                                                SizedBox(height: 10.0),
                                                const Text(
                                                    'Change the status to Keep It to ensure you aren\'t removing important files',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : bin
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red[700],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 3,
                                                child: Image.asset(
                                                    'assets/bin.png',
                                                    width: 140,
                                                    height: 140)),
                                            Expanded(
                                              flex: 6,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 10.0, 0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                        'Files in the bin will be permanently deleted after 1 day'),
                                                    SizedBox(height: 10.0),
                                                    const Text(
                                                        'You can restore files below by moving them back into your file storage',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container()

                            // :

                            // null
                          ],
                        ),
                      ),

                      actions: [
                        IconButton(
                          icon: Icon(
                            isGrid
                                ? Icons.list_alt_rounded
                                : Icons.grid_3x3_rounded,
                          ),
                          onPressed: () {
                            setState(() {
                              isGrid ? isGrid = false : isGrid = true;
                            });
                          },
                        ),
                        PopupMenuButton<_MenuValues>(
                          color: Color.fromRGBO(34, 34, 34, 1),
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              child: Text('Select All',
                                  style: TextStyle(color: Colors.white)),
                              value: _MenuValues.SelectAll,
                            ),
                            PopupMenuItem(
                              child: Text('Sort By',
                                  style: TextStyle(color: Colors.white)),
                              value: _MenuValues.SortBy,
                            ),
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Text('Filter By Tag',
                                      style: TextStyle(color: Colors.white)),
                                  SizedBox(width: 10),
                                  subbed
                                      ? Container()
                                      : Image.asset('assets/badge.png',
                                          width: 40, height: 40),
                                ],
                              ),
                              value: _MenuValues.FilterBy,
                            ),
                            PopupMenuItem(
                              child: Text('New Folder',
                                  style: TextStyle(color: Colors.white)),
                              value: _MenuValues.NewCollection,
                            ),
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Text("New Tag Group",
                                      style: TextStyle(color: Colors.white)),
                                  SizedBox(width: 10),
                                  subbed
                                      ? Container()
                                      : Image.asset('assets/badge.png',
                                          width: 40, height: 40),
                                ],
                              ),
                              value: _MenuValues.NewTagGroup,
                            ),
                          ],
                          onSelected: (value) async {
                            getTags();
                            checkSub().whenComplete(() {
                              setState(() {});
                            });
                            var isSubbed =
                                await Subscription().checkSubscription();
                            switch (value) {
                              case _MenuValues.SelectAll:
                                for (var x = 0; x <= filtered.length; x++) {
                                  isMultiSelectionEnabled = true;
                                  selectAll(filtered[x].thumbnail);
                                }

                                break;

                              case _MenuValues.SortBy:
                                showModalBottomSheet(
                                  backgroundColor:
                                      Color.fromRGBO(34, 34, 34, 1),
                                  context: context,
                                  enableDrag: true,
                                  isDismissible: true,
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20.0),
                                  )),
                                  builder: (context) => Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10.0, 0, 10.0, 0),
                                    child: SortList(),
                                  ),
                                );
                                break;

                              case _MenuValues.FilterBy:
                                var notice =
                                    await HideNotification().setValue();
                                isSubbed
                                    ? (tagNames.isNotEmpty
                                        ? showModalBottomSheet(
                                            backgroundColor:
                                                Color.fromRGBO(34, 34, 34, 1),
                                            context: context,
                                            enableDrag: true,
                                            isDismissible: true,
                                            // isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                              top: Radius.circular(20.0),
                                            )),
                                            builder: (context) => Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10.0, 0, 10.0, 0),
                                              child: Container(
                                                  height: MediaQuery.of(context)
                                                          .copyWith()
                                                          .size
                                                          .height *
                                                      0.50,
                                                  // color: Color.fromRGBO(34, 34, 34, 1),
                                                  child: FilterList(
                                                      provider.onePackSort)),
                                            ),
                                          )
                                        : showModalBottomSheet(
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
                                                    "Please Add Tags",
                                                    "You do not have any Tags",
                                                    context),
                                          ))
                                    : showModalBottomSheet(
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
                                                "Subscription Required",
                                                "Please subscribe to continue using this feature",
                                                context),
                                      );
                                break;

                              case _MenuValues.NewCollection:
                                _displayTextInputDialog(context);
                                break;

                              case _MenuValues.NewTagGroup:
                                var notice =
                                    await HideNotification().setValue();
                                isSubbed
                                    ? showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Please Enter The Tag Group Name',
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color.fromRGBO(
                                                        22, 86, 176, 1))),
                                            content: TextField(
                                              autofocus: true,
                                              controller: _textFieldController,
                                              decoration: InputDecoration(
                                                  hintText: "Tag Group Name"),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () async {
                                                  print('Close Sign');
                                                  _textFieldController.clear();
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  String str =
                                                      _textFieldController.text;

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


                                                  /// trims leading whitespace
                                                  String ltrim(String str) {
                                                    return str.replaceFirst(
                                                        new RegExp(r"^\s+"),
                                                        "");
                                                  }

                                                  String left = ltrim(str);

                                                  /// trims trailing whitespace
                                                  String rtrim(String left) {
                                                    return left.replaceFirst(
                                                        new RegExp(r"\s+$"),
                                                        "");
                                                  }

                                                  String right = rtrim(left);
                                                  var addTag =
                                                      await TagControls()
                                                          .createTag(right);
                                                  if (addTag == true) {
                                                    Navigator.of(context).pop();
                                                    getTags();
                                                    showModalBottomSheet(
                                                      context: context,
                                                      enableDrag: true,
                                                      isDismissible: true,
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .vertical(
                                                        top: Radius.circular(
                                                            20.0),
                                                      )),
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
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
                                                              "Tag Created!",
                                                              "You can now assign files to tags and filter them from the options.",
                                                              context),
                                                    ).whenComplete((){
                                                       getTags();
                                                       Navigator.pop(context);
                                                    });
                                                  } else {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      enableDrag: true,
                                                      isDismissible: true,
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .vertical(
                                                        top: Radius.circular(
                                                            20.0),
                                                      )),
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
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
                                                              "Tag Error!",
                                                              "The tag name may exist already.",
                                                              context),
                                                    );
                                                  }

                                                  _textFieldController.clear();
                                                },
                                                child: const Text('Okay'),
                                              ),
                                            ],
                                          );
                                        })
                                    : showModalBottomSheet(
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
                                                "Subscription Required",
                                                "Please subscribe to continue using this feature",
                                                context),
                                      );
                                /////////////////////////////////////////////////////////////////////////////////////////
                                break;
                            }
                          },
                        ),
                      ],
                    ),

                    body: Container(
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                          // image: DecorationImage(Image.asset("mobile_bg.png"),fit: BoxFit.cover),
                          image: DecorationImage(
                              image: AssetImage("assets/mobile_bg.png"),
                              fit: BoxFit.cover)),
                      child: filters.isEmpty
                          ? Visibility(
                              visible: provider.sortfiles.isNotEmpty,
                              replacement: Center(
                                  child: CircularProgressIndicator(
                                backgroundColor: Colors.grey,
                                color: Colors.yellow[600],
                                strokeWidth: 10,
                              )),
                              child: TabBarView(
                                  controller: _tabController,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: [
                                    for (var tab in provider.keepitTabs)
                                      buildTabView(tab),
                                  ]),
                            )
                          : Container(
                              child: FilteredListWidget(items_filter),
                            ),
                    ),

                    floatingActionButton: !bin
                        ? Visibility(
                            visible: done_action,
                            child: FloatingActionButton.extended(
                              backgroundColor: Colors.lightBlue,
                              foregroundColor: Colors.white,
                              onPressed: () {
                                var items = selectItems.toList();
                                List<String> items_selected = [];

                                for (var file in items) {
                                  items_selected.add(file);
                                }

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
                                    padding: const EdgeInsets.fromLTRB(
                                        10.0, 0, 10.0, 0),
                                    child: bottomsheet_methods.bottomSheet(
                                        context, items_selected, subbed),
                                  ),
                                ).whenComplete(() {
                                  print("Bottom sheet close");
                                  setState(() {
                                    switch_value = true;
                                    buildTabView("keep_for");
                                    // current_tab_status = 'All';
                                    isMultiSelectionEnabled = false;
                                    selectItems.clear();
                                    done_action = false;
                                  });
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
                          )
                        : AnimatedOpacity(
                            opacity: selectItems.isNotEmpty
                                ? (bin ? 1.0 : 0.0)
                                : 0.0,
                            duration: const Duration(milliseconds: 1),
                            child: Visibility(
                              visible: bin,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    40.0, 0, 10.0, 30),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    FloatingActionButton(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Are You Sure?',
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color.fromRGBO(
                                                            22, 86, 176, 1))),
                                                content: Text(
                                                    "All files in the bin will be permanently deleted!"),
                                                actions: [
                                                  GestureDetector(
                                                    child: const Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                          color: GlobalVariables
                                                              .secondaryColor),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  GestureDetector(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: const Text(
                                                        'Okay',
                                                        style: TextStyle(
                                                            color: GlobalVariables
                                                                .secondaryColor),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      List temp_list =
                                                          selectItems.toList();
                                                      List<String> files = [];
                                                      for (var item
                                                          in temp_list) {
                                                        files.add(item);
                                                      }
                                                      for (String file
                                                          in files) {
                                                        KeepFiles()
                                                            .deleteFile(file);
                                                      }
                                                      Provider.of<CategoryProvider>(
                                                              context,
                                                              listen: false)
                                                          .getImages('image');
                                                      Navigator.pop(context);
                                                      showModalBottomSheet(
                                                        context: context,
                                                        enableDrag: true,
                                                        isDismissible: true,
                                                        isScrollControlled:
                                                            true,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .vertical(
                                                          top: Radius.circular(
                                                              20.0),
                                                        )),
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              25,
                                                        ),
                                                        builder: (context) =>
                                                            DeleteCustomToast(
                                                                10, context),
                                                      );

                                                      setState(() {
                                                        selectItems.clear();
                                                        isMultiSelectionEnabled =
                                                            false;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: const Icon(Icons.delete_forever,
                                            size: 40.0),
                                      ),
                                    ),
                                    FloatingActionButton(
                                      backgroundColor: Colors.green[400],
                                      foregroundColor: Colors.white,
                                      onPressed: () {
                                        //Restore
                                        List temp_list = selectItems.toList();
                                        List<String> files = [];
                                        for (var item in temp_list) {
                                          files.add(item);
                                        }

                                        restore_files(files);

                                        isMultiSelectionEnabled = false;
                                        selectItems.clear();
                                        done_action = false;
                                      },
                                      child: const Icon(
                                          Icons.settings_backup_restore_sharp,
                                          size: 40.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              );
            }));
  }

  List<FilterOBJ> items_filter = [];

  void create_object_of_filtered_list() async {
    items_filter.clear();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.reload();
    List<String> keepitfiles =
        (prefs.getStringList('keepitfiles') ?? List.empty());
    List<String> keepitStatus =
        (prefs.getStringList('keepitStatus') ?? List.empty());
    List<String> keepitDate =
        (prefs.getStringList('keepitDate') ?? List.empty());
    print("Reloaded keepitfiles: $keepitfiles");
    print("Reloaded keepitStatus: $keepitStatus");
    print("Reloaded keepitDate: $keepitDate");

    for (FileSystemEntity file in temporary_paths) {
      FileStat info = file
          .statSync(); //Returns more info about the file (date file created)
      String date_created = info.modified
          .toString()
          .substring(0, info.modified.toString().indexOf(' '));
      // String file_size = formatBytes(info.size, 1).toString();

      var keep_status;
      var keep_date;

      final index = keepitfiles.indexWhere((element) =>
          element ==
          file
              .toString()
              .replaceAll("'", "")
              .substring(file.toString().indexOf("/") - 1));

      if (index >= 0) {
        print('File Keep Status ${keepitStatus[index]}');
        print('File Keep Date ${keepitDate[index]}');
        keep_status = keepitStatus[index];
        keep_date = keepitDate[index];
      } else {
        keep_status = '';
        keep_date = '';
      }

      print('File Path: ${file} | File Date: ${date_created}');
      String path = file.path;

      if (current_tab_status == keep_status.toString()) {
        items_filter.add(FilterOBJ(
            path,
            file
                .toString()
                .substring(file.toString().lastIndexOf('/') + 1)
                .replaceAll("'", ""),
            info.size,
            DateTime.parse(date_created),
            keep_status.toString(),
            keep_date.toString()));
      }
    }
  }

  Widget FilteredListWidget(List list_obj) => isGrid
      ? GridView.builder(
          controller: scrollController,
          itemCount: list_obj.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 0, mainAxisSpacing: 0),
          itemBuilder: (context, index) {
            var sortedItems = list_obj;

            switch (sort) {
              case 0:
                sortedItems.sort((a, b) {
                  int nameComp =
                      a.file_name.toString().compareTo(b.file_name.toString());
                  if (nameComp == 0) {
                    return -a.thumbnail.compareTo(b.thumbnail);
                  }
                  return nameComp;
                });
                break;

              case 1:
                sortedItems.sort((a, b) {
                  int nameComp =
                      b.file_name.toString().compareTo(a.file_name.toString());
                  if (nameComp == 0) {
                    return -a.thumbnail.compareTo(b.thumbnail);
                  }
                  return nameComp;
                });
                break;

              case 2:
                sortedItems.sort((a, b) {
                  int nameComp = b.file_date.millisecondsSinceEpoch
                      .compareTo(a.file_date.millisecondsSinceEpoch);
                  if (nameComp == 0) {
                    return -a.thumbnail
                        .compareTo(b.thumbnail); // '-' for descending
                  }
                  return nameComp;
                });
                break;

              case 3:
                sortedItems.sort((a, b) {
                  int nameComp = a.file_date.millisecondsSinceEpoch
                      .compareTo(b.file_date.millisecondsSinceEpoch);
                  if (nameComp == 0) {
                    return -a.thumbnail
                        .compareTo(b.thumbnail); // '-' for descending
                  }
                  return nameComp;
                });
                break;

              case 4:
                sortedItems.sort((a, b) {
                  int nameComp = b.file_size.compareTo(a.file_size);
                  if (nameComp == 0) {
                    return -a.thumbnail
                        .compareTo(b.thumbnail); // '-' for descending
                  }
                  return nameComp;
                });
                break;

              case 5:
                sortedItems.sort((a, b) {
                  int nameComp = a.file_size.compareTo(b.file_size);
                  if (nameComp == 0) {
                    return -a.thumbnail
                        .compareTo(b.thumbnail); // '-' for descending
                  }
                  return nameComp;
                });
                break;
            }

            var thumbnail = sortedItems[index].thumbnail.toString();
            var file_name = sortedItems[index].file_name.toString();
            var file_size = sortedItems[index].file_size;
            var file_date =
                DateFormat('dd/MM/yyyy').format(sortedItems[index].file_date);
            String keep_status = sortedItems[index].keep_status.toString();

            file_size = formatBytes(file_size, 1);

            var fileExt = thumbnail.substring(thumbnail.lastIndexOf(".") + 1);

            final Widget asset_path;
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
              'jpg',
              'jpeg',
              'mdb',
              'mid',
              'mov',
              'mp3',
              'mp4',
              'mpeg',
              'pdf',
              'png',
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

            final index1 = file_ext.indexWhere((element) => element == fileExt);
            if (index1 != -1) {
              if (fileExt == "png" || fileExt == "jpg" || fileExt == "jpeg") {
                asset_path = Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Image.file(
                    File(thumbnail),
                    cacheHeight: 200,
                    cacheWidth: 200,
                  ),
                );
              } else {
                asset_path = Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Image.asset('assets/${fileExt}.png',
                      width: 80, height: 80),
                );
              }
            } else {
              asset_path =
                  Image.asset('assets/general.png', width: 80, height: 80);
            }
            var widget_type;

            if (keep_status == 'keep') {
              widget_type = Positioned(
                  top: 2,
                  left: 2,
                  child:
                      Image.asset('assets/keepit.png', width: 30, height: 30));
            } else if (keep_status == 'keep_for') {
              widget_type = Positioned(
                  top: 2,
                  left: 2,
                  child: Image.asset('assets/keepit_for.png',
                      width: 30, height: 30));
            } else {
              widget_type = const Text('');
            }

            return Stack(alignment: Alignment.center, children: [
              GridTile(
                child: InkWell(
                  onTap: (() {
                    scrollOffset = scrollController.position.pixels;
                    isMultiSelectionEnabled
                        ? doMultiSelection(thumbnail)
                        : doSingleSelection(thumbnail);
                  }),
                  onLongPress: () {
                    setState(() {
                      scrollOffset = scrollController.position.pixels;
                      isMultiSelectionEnabled = true;
                      doMultiSelection(thumbnail);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Stack(
                      children: [
                        selectItems.contains(thumbnail)
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 5,
                                    color: Colors.white,
                                  ),
                                ),
                                child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.white
                                        ],
                                      ).createShader(
                                          Rect.fromLTRB(0, 0, rect.width, 30));
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: ShaderMask(
                                      shaderCallback: (rect) {
                                        return LinearGradient(
                                          begin: Alignment.center,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white,
                                            Colors.transparent
                                          ],
                                        ).createShader(Rect.fromLTRB(
                                            0, 0, rect.width, rect.height));
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: asset_path,
                                    )),
                              )
                            : ShaderMask(
                                shaderCallback: (rect) {
                                  return LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.white],
                                  ).createShader(
                                      Rect.fromLTRB(0, 0, rect.width, 30));
                                },
                                blendMode: BlendMode.dstIn,
                                child: ShaderMask(
                                  shaderCallback: (rect) {
                                    return LinearGradient(
                                      begin: Alignment.center,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white,
                                        Colors.transparent
                                      ],
                                    ).createShader(Rect.fromLTRB(
                                        0, 0, rect.width, rect.height));
                                  },
                                  blendMode: BlendMode.dstIn,
                                  child: asset_path,
                                )),
                      ],
                    ),
                  ),
                ),
              ),
              widget_type,
              Positioned(
                  top: 10,
                  right: 10,
                  child: Center(
                    child: Text(file_size.toString(),
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.right),
                  )),
              Positioned(
                  // left: 10,
                  bottom: 10,
                  child: Center(
                    child: Text(
                        file_name.length > 20
                            ? "${file_name.toString().substring(0, 20)}..."
                            : file_name.toString(),
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center),
                  )),
            ]);
          },
        )
      : ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.only(top: 5.0, left: 1.0, right: 1.0),
          itemCount: list_obj.length,
          itemBuilder: (BuildContext context, int index) {
            var sortedItems = list_obj;

            switch (sort) {
              case 0:
                sortedItems.sort((a, b) {
                  int nameComp =
                      a.file_name.toString().compareTo(b.file_name.toString());
                  if (nameComp == 0) {
                    return -a.thumbnail.compareTo(b.thumbnail);
                  }
                  return nameComp;
                });
                break;

              case 1:
                sortedItems.sort((a, b) {
                  int nameComp =
                      b.file_name.toString().compareTo(a.file_name.toString());
                  if (nameComp == 0) {
                    return -a.thumbnail.compareTo(b.thumbnail);
                  }
                  return nameComp;
                });
                break;

              case 2:
                sortedItems.sort((a, b) {
                  int nameComp = b.file_date.millisecondsSinceEpoch
                      .compareTo(a.file_date.millisecondsSinceEpoch);
                  if (nameComp == 0) {
                    return -a.thumbnail
                        .compareTo(b.thumbnail); // '-' for descending
                  }
                  return nameComp;
                });
                break;

              case 3:
                sortedItems.sort((a, b) {
                  int nameComp = a.file_date.millisecondsSinceEpoch
                      .compareTo(b.file_date.millisecondsSinceEpoch);
                  if (nameComp == 0) {
                    return -a.thumbnail
                        .compareTo(b.thumbnail); // '-' for descending
                  }
                  return nameComp;
                });
                break;

              case 4:
                sortedItems.sort((a, b) {
                  int nameComp = b.file_size.compareTo(a.file_size);
                  if (nameComp == 0) {
                    return -a.thumbnail
                        .compareTo(b.thumbnail); // '-' for descending
                  }
                  return nameComp;
                });
                break;

              case 5:
                sortedItems.sort((a, b) {
                  int nameComp = a.file_size.compareTo(b.file_size);
                  if (nameComp == 0) {
                    return -a.thumbnail
                        .compareTo(b.thumbnail); // '-' for descending
                  }
                  return nameComp;
                });
                break;
            }

            var thumbnail = sortedItems[index]
                .thumbnail
                .toString()
                .replaceAll("'", "")
                .replaceAll("'", "");
            print('File thumbnail ${File(thumbnail)}');
            var file_name = sortedItems[index].file_name.toString();
            var file_size = sortedItems[index].file_size;
            var file_date =
                DateFormat('dd/MM/yyyy').format(sortedItems[index].file_date);
            String keep_status = sortedItems[index].keep_status.toString();

            file_size = formatBytes(file_size, 1);

            var fileExt = thumbnail
                .substring(thumbnail.lastIndexOf(".") + 1)
                .replaceAll("'", "");

            print('File thumbnail ${thumbnail}');
            print('Extensions ${fileExt}');
            final Widget asset_path;

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
              'jpg',
              'jpeg',
              'mdb',
              'mid',
              'mov',
              'mp3',
              'mp4',
              'mpeg',
              'pdf',
              'png',
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

            final index1 = file_ext.indexWhere((element) => element == fileExt);
            if (index1 != -1) {
              if (fileExt == "png" || fileExt == "jpg" || fileExt == "jpeg") {
                asset_path = Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Image.file(
                    File(thumbnail.toString()),
                    cacheHeight: 200,
                    cacheWidth: 200,
                  ),
                );
              } else {
                asset_path = Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Image.asset('assets/${fileExt}.png',
                      width: 80, height: 80),
                );
              }
            } else {
              asset_path =
                  Image.asset('assets/general.png', width: 80, height: 80);
            }

            var widget_type;

            if (keep_status == 'keep') {
              widget_type = Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                    child: asset_path,
                  ),
                  Positioned(
                      top: 0,
                      left: 0,
                      child: Image.asset('assets/keepit.png',
                          width: 30, height: 30)),
                ],
              );
            } else if (keep_status == 'keep_for') {
              widget_type = Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                    child: asset_path,
                  ),
                  Positioned(
                      top: 0,
                      left: 0,
                      child: Image.asset('assets/keepit_for.png',
                          width: 30, height: 30)),
                ],
              );
            } else {
              widget_type = Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                child: asset_path,
              );
            }

            return ListTile(
              leading: widget_type,
              title: Text(file_name.toString(),
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text("${file_size} | ${file_date}",
                  style:
                      const TextStyle(color: Color.fromRGBO(222, 222, 222, 1))),
              trailing: Visibility(
                visible: selectItems.contains(thumbnail),
                child: const Icon(Icons.check, color: Colors.white, size: 20.0),
              ),
              onTap: (() {
                scrollOffset = scrollController.position.pixels;
                isMultiSelectionEnabled
                    ? doMultiSelection(thumbnail)
                    : doSingleSelection(thumbnail);

                print('Keeping path sorted files ${thumbnail}');
              }),
              onLongPress: () {
                setState(() {
                  scrollOffset = scrollController.position.pixels;
                  isMultiSelectionEnabled = true;
                  doMultiSelection(thumbnail);
                });
              },
            );
          },
        );

  buildTabView(name) {
    // scrollController.animateTo(scrollOffset,
    //     duration: const Duration(seconds: 1), curve: Curves.easeOutExpo);
    //return Text("${name}");
    return Consumer(builder:
        (BuildContext context, CategoryProvider provider, Widget? child) {
      List onePackSort = provider.onePackSort;
      List list_obj = onePackSort;
      print('Provider object length ${list_obj.length}');

      Future.delayed(Duration(milliseconds: 1000), () {
        if (switch_value == true) {
          //print("switch val is: ${switch_value}");
          provider.switchCurrentFiles(provider.sortfiles, 'All', 'sort');
          List list_obj = provider.onePackSort;
          switch_value = false;
        }
      });

      if (list_obj.length == 0) {
        return Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Empty",
                style: TextStyle(fontSize: 18.0, color: Colors.white)),
            SizedBox(height: 15.0),
            Image.asset("assets/empty2.png"),
          ],
        ));
      } else {
        if (current_tab_status == "keep") {
          filtered = list_obj
              .where((content) =>
                  content.keep_status == current_tab_status.toString())
              .toList();

          print("Initial Filtered ${filtered}");

          if (filtered.length == 0) {
            return Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Empty",
                    style: TextStyle(fontSize: 18.0, color: Colors.white)),
                SizedBox(height: 15.0),
                Image.asset("assets/empty2.png"),
              ],
            ));
          } else {
            print("Filtered List KeepIt ${filtered[0].keep_status}");
            return GridOrList(filtered);
          }
        } else {
          //************************************** */
          //************************************** */

          // Edit Here To Sort Keep Files Within 24 Hours / 1 Day

          //************************************** */
          //************************************** */
          //************************************** */
          if (bin == false) {
            filtered = list_obj
                .where((content) =>
                    content.keep_status == current_tab_status.toString() &&
                    content.keep_date > 1)
                .toList();
          } else {
            print('You are in a Bin Tab');



            List keepfor = list_obj
              .where((content) =>
                  content.keep_status == "keep_for")
              .toList();

            print('Before Filter ${keepfor}');

            filtered = keepfor
                .where((content) =>
                    content.keep_status == current_tab_status.toString() &&
                    content.keep_date <= 1)
                .toList();
            
            print('After Filter ${filtered}');

          }

          print("Initial Filtered ${filtered}");

          if (filtered.length == 0) {
            return Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Empty",
                    style: TextStyle(fontSize: 18.0, color: Colors.white)),
                SizedBox(height: 15.0),
                Image.asset("assets/empty2.png"),
              ],
            ));
          } else {
            print("Filtered List KeepFor ${filtered[0].keep_status}");
            return GridOrList(filtered);
          }
        }
      }
    });
  }

  Widget GridOrList(
    List list_obj,
  ) =>
      isGrid
          ? GridView.builder(
              controller: scrollController,
              itemCount: list_obj.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 0, mainAxisSpacing: 0),
              itemBuilder: (context, index) {
                //late final sortedItems;
                var gridtile;

                var sortedItems = list_obj;

                switch (sort) {
                  case 0:
                    sortedItems.sort((a, b) {
                      int nameComp = a.file_name
                          .toString()
                          .compareTo(b.file_name.toString());
                      if (nameComp == 0) {
                        return -a.thumbnail.compareTo(b.thumbnail);
                      }
                      return nameComp;
                    });
                    break;

                  case 1:
                    sortedItems.sort((a, b) {
                      int nameComp = b.file_name
                          .toString()
                          .compareTo(a.file_name.toString());
                      if (nameComp == 0) {
                        return -a.thumbnail.compareTo(b.thumbnail);
                      }
                      return nameComp;
                    });
                    break;

                  case 2:
                    sortedItems.sort((a, b) {
                      int nameComp = b.file_date.millisecondsSinceEpoch
                          .compareTo(a.file_date.millisecondsSinceEpoch);
                      if (nameComp == 0) {
                        return -a.thumbnail
                            .compareTo(b.thumbnail); // '-' for descending
                      }
                      return nameComp;
                    });
                    break;

                  case 3:
                    sortedItems.sort((a, b) {
                      int nameComp = a.file_date.millisecondsSinceEpoch
                          .compareTo(b.file_date.millisecondsSinceEpoch);
                      if (nameComp == 0) {
                        return -a.thumbnail
                            .compareTo(b.thumbnail); // '-' for descending
                      }
                      return nameComp;
                    });
                    break;

                  case 4:
                    sortedItems.sort((a, b) {
                      int nameComp = b.file_size.compareTo(a.file_size);
                      if (nameComp == 0) {
                        return -a.thumbnail
                            .compareTo(b.thumbnail); // '-' for descending
                      }
                      return nameComp;
                    });
                    break;

                  case 5:
                    sortedItems.sort((a, b) {
                      int nameComp = a.file_size.compareTo(b.file_size);
                      if (nameComp == 0) {
                        return -a.thumbnail
                            .compareTo(b.thumbnail); // '-' for descending
                      }
                      return nameComp;
                    });
                    break;
                }

                var thumbnail = sortedItems[index].thumbnail.toString();
                var file_name = sortedItems[index].file_name.toString();
                var file_size = sortedItems[index].file_size.toString();
                var file_date = DateFormat('dd/MM/yyyy')
                    .format(sortedItems[index].file_date);
                var keep_days = sortedItems[index].keep_date.toString();

                var file_size_int = int.parse(file_size);
                file_size = formatBytes(file_size_int, 1);

                var fileExt =
                    thumbnail.substring(thumbnail.lastIndexOf(".") + 1);

                final Widget asset_path;
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
                  'jpg',
                  'jpeg',
                  'mdb',
                  'mid',
                  'mov',
                  'mp3',
                  'mp4',
                  'mpeg',
                  'pdf',
                  'png',
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

                final index1 =
                    file_ext.indexWhere((element) => element == fileExt);
                if (index1 != -1) {
                  if (fileExt == "png" ||
                      fileExt == "jpg" ||
                      fileExt == "jpeg") {
                    asset_path = Image.file(
                      File(thumbnail),
                      cacheHeight: 250,
                      cacheWidth: 250,
                    );
                  } else {
                    asset_path = Image.asset('assets/${fileExt}.png');
                  }
                } else {
                  asset_path = Image.asset('assets/general.png');
                }

                // String keep_date = sortedItems[index].keep_date.toString();
                // print("Date is: ${keep_date}");

                gridtile = Stack(alignment: Alignment.center, children: [
                  GridTile(
                    child: InkWell(
                      onTap: (() {
                        // if (bin) {
                        // } else {
                        scrollOffset = scrollController.position.pixels;
                        isMultiSelectionEnabled
                            ? doMultiSelection(thumbnail)
                            : doSingleSelection(thumbnail);
                        // }
                      }),
                      onLongPress: () {
                        setState(() {
                          scrollOffset = scrollController.position.pixels;
                          isMultiSelectionEnabled = true;
                          doMultiSelection(thumbnail);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Stack(
                          children: [
                            selectItems.contains(thumbnail)
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 5,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: ShaderMask(
                                        shaderCallback: (rect) {
                                          return LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.white
                                            ],
                                          ).createShader(Rect.fromLTRB(
                                              0, 0, rect.width, 30));
                                        },
                                        blendMode: BlendMode.dstIn,
                                        child: ShaderMask(
                                          shaderCallback: (rect) {
                                            return LinearGradient(
                                              begin: Alignment.center,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.white,
                                                Colors.transparent
                                              ],
                                            ).createShader(Rect.fromLTRB(
                                                0, 0, rect.width, rect.height));
                                          },
                                          blendMode: BlendMode.dstIn,
                                          child: asset_path,
                                        )),
                                  )
                                : ShaderMask(
                                    shaderCallback: (rect) {
                                      return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.white
                                        ],
                                      ).createShader(
                                          Rect.fromLTRB(0, 0, rect.width, 30));
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: ShaderMask(
                                      shaderCallback: (rect) {
                                        return LinearGradient(
                                          begin: Alignment.center,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white,
                                            Colors.transparent
                                          ],
                                        ).createShader(Rect.fromLTRB(
                                            0, 0, rect.width, rect.height));
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: asset_path,
                                    )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  current_tab_status == 'keep'
                      ? Positioned(
                          top: 0,
                          left: 0,
                          child: Image.asset('assets/keepit.png',
                              width: 30, height: 30))
                      : Positioned(
                          top: 0,
                          left: 0,
                          child: Image.asset('assets/keepit_for.png',
                              width: 30, height: 30)),
                  Positioned(
                      top: 10,
                      right: 10,
                      child: Center(
                        child: Text(file_size.toString(),
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.right),
                      )),
                  Positioned(
                      bottom: 10,
                      child: Center(
                        child: Text(
                            file_name.length > 20
                                ? "${file_name.toString().substring(0, 20)}..."
                                : file_name.toString(),
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center),
                      )),
                ]);

                return gridtile;
              },
            )
          : ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.only(top: 5.0, left: 1.0, right: 1.0),
              itemCount: list_obj.length,
              itemBuilder: (BuildContext context, int index) {
                //late final sortedItems;
                var listile;

                var sortedItems = list_obj;

                switch (sort) {
                  case 0:
                    sortedItems.sort((a, b) {
                      int nameComp = a.file_name
                          .toString()
                          .compareTo(b.file_name.toString());
                      if (nameComp == 0) {
                        return -a.thumbnail.compareTo(b.thumbnail);
                      }
                      return nameComp;
                    });
                    break;

                  case 1:
                    sortedItems.sort((a, b) {
                      int nameComp = b.file_name
                          .toString()
                          .compareTo(a.file_name.toString());
                      if (nameComp == 0) {
                        return -a.thumbnail.compareTo(b.thumbnail);
                      }
                      return nameComp;
                    });
                    break;

                  case 2:
                    sortedItems.sort((a, b) {
                      int nameComp = b.file_date.millisecondsSinceEpoch
                          .compareTo(a.file_date.millisecondsSinceEpoch);
                      if (nameComp == 0) {
                        return -a.thumbnail
                            .compareTo(b.thumbnail); // '-' for descending
                      }
                      return nameComp;
                    });
                    break;

                  case 3:
                    sortedItems.sort((a, b) {
                      int nameComp = a.file_date.millisecondsSinceEpoch
                          .compareTo(b.file_date.millisecondsSinceEpoch);
                      if (nameComp == 0) {
                        return -a.thumbnail
                            .compareTo(b.thumbnail); // '-' for descending
                      }
                      return nameComp;
                    });
                    break;

                  case 4:
                    sortedItems.sort((a, b) {
                      int nameComp = b.file_size.compareTo(a.file_size);
                      if (nameComp == 0) {
                        return -a.thumbnail
                            .compareTo(b.thumbnail); // '-' for descending
                      }
                      return nameComp;
                    });
                    break;

                  case 5:
                    sortedItems.sort((a, b) {
                      int nameComp = a.file_size.compareTo(b.file_size);
                      if (nameComp == 0) {
                        return -a.thumbnail
                            .compareTo(b.thumbnail); // '-' for descending
                      }
                      return nameComp;
                    });
                    break;
                }

                var thumbnail = sortedItems[index].thumbnail.toString();
                var file_name = sortedItems[index].file_name.toString();
                var file_size = sortedItems[index].file_size.toString();
                var file_date = DateFormat('dd/MM/yyyy')
                    .format(sortedItems[index].file_date);
                var keep_days = sortedItems[index].keep_date.toString();

                var file_size_int = int.parse(file_size);
                file_size = formatBytes(file_size_int, 1);

                if (keep_days != '0') {
                  keep_days = "Deleting in ${keep_days} days";
                } else {
                  keep_days = "";
                }

                var fileExt =
                    thumbnail.substring(thumbnail.lastIndexOf(".") + 1);

                final Widget asset_path;
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
                  'jpg',
                  'jpeg',
                  'mdb',
                  'mid',
                  'mov',
                  'mp3',
                  'mp4',
                  'mpeg',
                  'pdf',
                  'png',
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

                final index1 =
                    file_ext.indexWhere((element) => element == fileExt);
                if (index1 != -1) {
                  if (fileExt == "png" ||
                      fileExt == "jpg" ||
                      fileExt == "jpeg") {
                    asset_path = Image.file(
                      File(thumbnail),
                      cacheHeight: 170,
                      cacheWidth: 170,
                      width: 80,
                      height: 80,
                    );
                  } else {
                    asset_path = Image.asset('assets/${fileExt}.png',
                        width: 80, height: 80);
                  }
                } else {
                  asset_path =
                      Image.asset('assets/general.png', width: 80, height: 80);
                }

                if (keep_days != '') {
                  int days_left = int.parse(
                      "${keep_days.toString().replaceAll("Deleting in ", "").replaceAll("days", "")}");

                  print('Days left ${days_left}');

                  if (days_left <= 7) {
                    colors = Colors.red;
                  } else if (days_left > 7 && days_left <= 30) {
                    colors = Colors.amber;
                  } else {
                    colors = Colors.green;
                  }
                }

                listile = Padding(
                  padding: keepit_bin
                      ? const EdgeInsets.all(5.0)
                      : const EdgeInsets.all(0),
                  child: ListTile(
                    leading: Stack(children: [
                      asset_path,
                      current_tab_status == 'keep'
                          ? Positioned(
                              top: 0,
                              left: 0,
                              child: Image.asset('assets/keepit.png',
                                  width: 30, height: 30))
                          : Positioned(
                              top: 0,
                              left: 0,
                              child: Image.asset('assets/keepit_for.png',
                                  width: 30, height: 30)),
                    ]),
                    title: Text(file_name.toString(),
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${file_size} | ${file_date}",
                          style: const TextStyle(
                              color: Color.fromRGBO(222, 222, 222, 1)),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 5.0),
                        keepit_bin
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                  color: colors,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                  child: Text(
                                    '${keep_days}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    ),
                    trailing: Visibility(
                      visible: selectItems.contains(thumbnail),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 20.0),
                    ),
                    onTap: (() {
                      scrollOffset = scrollController.position.pixels;
                      isMultiSelectionEnabled
                          ? doMultiSelection(thumbnail)
                          : doSingleSelection(thumbnail);
                    }),
                    onLongPress: () {
                      setState(() {
                        scrollOffset = scrollController.position.pixels;
                        isMultiSelectionEnabled = true;
                        doMultiSelection(thumbnail);
                      });
                    },
                  ),
                );

                return listile;
              },
            );

  void _onTabChanged() {
    setState(() {
      // buildList();
    });
  }

  Widget SortList() => ListView.builder(
        controller: scrollController,
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

  Widget FilterList(list) => StatefulBuilder(builder: (context, updateState) {
        return Container(
          child: ListView.builder(
            controller: scrollController,
            itemCount: tagNames.length,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              final filterby = tagNames[index];

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  key: UniqueKey(),
                  title: Center(
                      child: Text(filterby,
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white))),
                  trailing: filters.contains(filterby)
                      ? const Icon(Icons.check, color: Colors.white, size: 20.0)
                      : const Text(''),
                  onTap: () {
                    updateState(() {
                      // doMultiSelectionFilter(filterby);
                      setState(() {
                        if (!filters.contains(filterby)) {
                          getlist(filterby, list);
                          print('Get list ${filterby}');
                        } else {
                          deselect(filterby, list);
                          print('deselect list ${filterby}');
                        }
                      });
                    });
                  },
                ),
              );
            },
          ),
        );
      });
}
