import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:keepit/constants/custom_toast.dart';
import 'package:keepit/constants/hide_notification.dart';
import 'package:keepit/constants/utils/controls.dart' as controls;
import 'package:flutter/material.dart';
import 'package:keepit/constants/utils/files.dart';
import 'package:keepit/models/filter_file_obj.dart';
import 'package:keepit/models/filter_tags.dart';
import 'package:open_file/open_file.dart';
import 'package:keepit/models/images_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/scheduler.dart';
import 'package:keepit/providers/category_provider.dart';
import 'package:keepit/constants/utils/file_utils.dart';
import 'package:provider/provider.dart';
import 'package:mime_type/mime_type.dart';
import 'package:keepit/features/traverse/widgets/bottomsheet_data.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:keepit/features/home/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keepit/constants/custom_toast.dart' as CustomToast;
import '../../constants/utils/tags.dart';
import 'package:keepit/common/subscriptions.dart';

class Downloads extends StatefulWidget {
  static const String routeName = '/downloads';
  const Downloads({super.key});

  void getTags() {
    _DownloadsState().getTags();
  }

  @override
  State<Downloads> createState() => _DownloadsState();
}

enum _MenuValues { SelectAll, SortBy, FilterBy, NewCollection, NewTagGroup }

late List<FileOBJ> list_Search;

class Constants {
  static List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }
}

bool switch_value = false;

class _DownloadsState extends State<Downloads> {
  final BottomSheet_Data bottomsheet_methods = new BottomSheet_Data();
  late TextEditingController _textFieldController;
  static List<Tab> tabs = [];
  static bool isGrid = true;
  static List<String> download_files = [];
  static int _tab_length = 1;
  static List<String> _tab_paths = [];
  static List<FileSystemEntity> all_download = [];
  static bool has_content = false;
  static List<String> collection_names = [];
  static List<String> remove_collection_names = [];
  static List<String> sortlistitems = [
    'Name A to Z',
    'Name Z to A',
    'Newest date first',
    'Oldest date first',
    'Largest first',
    'Smallest first',
  ];
  static HashSet selectItems = new HashSet();
  static bool isMultiSelectionEnabled = false;
  static bool done_action = false;
  static HashSet selectItems_sort = new HashSet();
  static HashSet selectItems_filter = new HashSet();
  String selectedItem = 'Newest date first';
  static List<bool> is_selected = [];
  var local_path;
  int sort = 2;
  Key _refreshKey = UniqueKey();
  String _tabname = 'All';
  final ScrollController scrollController = ScrollController();
  double scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController();
    get_collections();
    doSortSelection(selectedItem);
    buildTabView('All');
    getTags();
    checkSub().whenComplete(() {
      setState(() {});
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textFieldController.dispose();
  }

  void doSingleSelection(String path, String name) async {
    setState(() {
      print('The path that selected ${path}');
      if (selectItems.contains(path)) {
        selectItems.remove(path);
        print('Script Came to Remove');
      } else {
        selectItems.clear();
        selectItems.add(path);
        print('Script Came to Add');

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
                context, [path.toString()], subbed),
          ),
        ).whenComplete(() {
          setState(() {
            switch_value = true;
            isMultiSelectionEnabled = false;
            selectItems.clear();
            done_action = false;
            buildTabView(name);
            print('Cleared everything');
          });
        });

        // bottomSheet.then((onValue) {
        //   // switch_value = true;
        //   isMultiSelectionEnabled = false;
        //   selectItems.clear();
        //   done_action = false;
        //   buildTabView(name);
        // });

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

  void doMultiSelection(String path, String tabname) {
    // if (isMultiSelectionEnabled) {
    setState(() {
      _tabname = tabname;
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
    var foo = await controls.Controls().get_all_collections('bottomsheet');

    for (int i = 0; i < foo.length; i++) {
      var collection_name = foo[i].path.split("/");
      // print("Path is "+foo[i].path.toString());
      local_path = foo[0].path.toString();
      setState(() {
        tabs.add(Tab(child: Text(collection_name.last)));
      });
    }

    // print(tabs.length);
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

                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
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
                                Colors.green,
                                Colors.amber,
                                "assets/check.png",
                                "New Folder Created",
                                "A new Folder was successfully created",
                                context),
                      ).whenComplete(() {
                        Navigator.pop(context);
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
                      ).whenComplete(() {
                        Navigator.pop(context);
                      });

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
        String filepath = files[i].path.toString();
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

  int changeTab = 0;
  int changeTab_temp = 0;
  String changeTab_name = "All";
  int totalTabs = 0;
  bool changeTabIns = false;
  bool changeTabs_name_ins = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          isMultiSelectionEnabled = false;
          selectItems.clear();
          done_action = false;
          Navigator.pop(context);
          return Future.value(true);
        },
        child: Consumer(
          key: _refreshKey,
          builder:
              (BuildContext context, CategoryProvider provider, Widget? child) {
            List list = provider.downloads;

            return DefaultTabController(
              length: provider.downloadTabs.length,
              initialIndex: changeTab,
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
                          icon:
                              Container(width: 200.0, child: Icon(Icons.close)))
                      : ExpandTapWidget(
                          tapPadding: EdgeInsets.all(155.0),
                          onTap: () {
                            isMultiSelectionEnabled = false;
                            selectItems.clear();
                            done_action = false;
                            print('Close Sign');
                            switch_value = true;
                            List list_obj = provider.onePackDownloads;
                            Navigator.pop(context);
                          },
                          child: Container(
                              width: 200.0, child: Icon(Icons.arrow_back))),

                  title: Text(isMultiSelectionEnabled
                      ? getSelectedItemCount()
                      : "Download"),

                  elevation: 0,
                  backgroundColor: Color.fromRGBO(43, 104, 210, 1),
                  // centerTitle: true,
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(60),
                    child: TabBar(
                        indicatorColor: Colors.white,
                        isScrollable:
                            provider.downloadTabs.length < 3 ? false : true,
                        tabs: Constants.map<Widget>(
                          provider.downloadTabs,
                          (index, label) {
                            return Tab(text: '$label');
                          },
                        ),
                        onTap: (val) {
                          print("Selected tab is: ${val}");
                          changeTab_temp = val;
                          changeTab_name = provider.documentTabs[val];

                          setState(() {
                            totalTabs = provider.documentTabs.length;
                            print("downloads are : ${provider.downloads}");
                          });
                        }),
                  ),

                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: MySearchDelegate(),
                        );
                      },
                    ),
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
                        )
                      ],
                      onSelected: (value) async {
                        getTags();
                        checkSub().whenComplete(() {
                          setState(() {});
                        });
                        ;
                        var isSubbed = await Subscription().checkSubscription();
                        switch (value) {
                          case _MenuValues.SelectAll:
                            if (filters.length == 0) {
                              List list = provider.downloads;

                              for (var x = 0; x <= list.length; x++) {
                                isMultiSelectionEnabled = true;
                                File file = File(list[x].path);
                                String path = file.path;
                                selectAll(path);
                              }
                            } else {
                              for (var x = 0; x < items.length; x++) {
                                isMultiSelectionEnabled = true;
                                String path = items[x].thumbnail.toString();
                                selectAll(path);
                              }
                            }
                            break;

                          case _MenuValues.SortBy:
                            showModalBottomSheet(
                              backgroundColor: Color.fromRGBO(34, 34, 34, 1),
                              context: context,
                              enableDrag: true,
                              isDismissible: true,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20.0),
                              )),
                              builder: (context) => Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                                child: SortList(),
                              ),
                            );

                            break;

                          case _MenuValues.FilterBy:
                            var notice = await HideNotification().setValue();
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
                                            borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20.0),
                                        )),
                                        builder: (context) => Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10.0, 0, 10.0, 0),
                                          child: Container(
                                              height: MediaQuery.of(context)
                                                      .copyWith()
                                                      .size
                                                      .height *
                                                  0.50,
                                              // color: Color.fromRGBO(34, 34, 34, 1),
                                              child: FilterList(
                                                  provider.downloads)),
                                        ),
                                      )
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
                                        builder: (context) =>
                                            CustomToast.CustomToast()
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
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
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
                            var notice = await HideNotification().setValue();
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
                                            onPressed: () {
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

                                              /// trims leading whitespace
                                              String ltrim(String str) {
                                                return str.replaceFirst(
                                                    new RegExp(r"^\s+"), "");
                                              }

                                              String left = ltrim(str);

                                              /// trims trailing whitespace
                                              String rtrim(String left) {
                                                return left.replaceFirst(
                                                    new RegExp(r"\s+$"), "");
                                              }

                                              String right = rtrim(left);
                                              var addTag = await TagControls()
                                                  .createTag(right);
                                              if (addTag == true) {
                                                Navigator.pop(context);
                                                getTags();
                                                showModalBottomSheet(
                                                  context: context,
                                                  enableDrag: true,
                                                  isDismissible: true,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                    top: Radius.circular(20.0),
                                                  )),
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
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
                                                );
                                              } else {
                                                showModalBottomSheet(
                                                  context: context,
                                                  enableDrag: true,
                                                  isDismissible: true,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                    top: Radius.circular(20.0),
                                                  )),
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
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
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
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
                            visible: provider.onePackDownloads.isNotEmpty,
                            replacement: Center(
                                child: CircularProgressIndicator(
                              backgroundColor: Colors.grey,
                              color: Colors.yellow[600],
                              strokeWidth: 10,
                            )),
                            child: TabBarView(
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  for (var tab in provider.downloadTabs)
                                    buildTabView(tab),
                                ]),
                          )
                        : Container(
                            child: FilteredListWidget(items),
                          )),
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
                              context, items_selected, subbed),
                        ),
                      ).whenComplete(() {
                        print("Bottom sheet close");
                        setState(() {
                          switch_value = true;
                          buildTabView(_tabname);
                          _tabname = 'All';
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
                ),
              ),
            );
          },
        ));
  }

  List<List<String>> file_types = [
    //Images
    [".jpg", ".jpeg", ".png", ".gif"],
  ];

  /// Convert Byte to KB, MB, .......
  static String formatBytes(bytes, decimals) {
    if (bytes == 0) return '0.0 KB';
    var k = 1024,
        dm = decimals <= 0 ? 0 : decimals,
        sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
        i = (log(bytes) / log(k)).floor();
    return (((bytes / pow(k, i)).toStringAsFixed(dm)) + ' ' + sizes[i]);
  }

  List<FilterOBJ> items = [];

  void create_object_of_filtered_list() async {
    items.clear();

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

      items.add(FilterOBJ(
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

            var fileExt = thumbnail
                .substring(thumbnail.lastIndexOf(".") + 1)
                .replaceAll("'", "");

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
                asset_path = Image.file(
                  File(thumbnail),
                  cacheHeight: 200,
                  cacheWidth: 200,
                );
              } else {
                asset_path = Image.asset('assets/${fileExt}.png');
              }
            } else {
              asset_path = Image.asset('assets/general.png');
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
                        ? doMultiSelection(thumbnail, '')
                        : doSingleSelection(thumbnail, '');
                  }),
                  onLongPress: () {
                    setState(() {
                      scrollOffset = scrollController.position.pixels;
                      isMultiSelectionEnabled = true;
                      doMultiSelection(thumbnail, '');
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

            var thumbnail = sortedItems[index].thumbnail.toString();
            var file_name = sortedItems[index].file_name.toString();
            var file_size = sortedItems[index].file_size;
            var file_date =
                DateFormat('dd/MM/yyyy').format(sortedItems[index].file_date);
            String keep_status = sortedItems[index].keep_status.toString();

            file_size = formatBytes(file_size, 1);

            var fileExt = thumbnail
                .substring(thumbnail.lastIndexOf(".") + 1)
                .replaceAll("'", "");
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
                    ? doMultiSelection(thumbnail, '')
                    : doSingleSelection(thumbnail, '');
              }),
              onLongPress: () {
                setState(() {
                  scrollOffset = scrollController.position.pixels;
                  isMultiSelectionEnabled = true;
                  doMultiSelection(thumbnail, '');
                });
              },
            );
          },
        );

  Timer? timer;
  buildTabView(name) {
    
    return Consumer(builder:
        (BuildContext context, CategoryProvider provider, Widget? child) {
      // Future.delayed(Duration(milliseconds: 1000), () {
      //   if (changeTabIns == true) {
      //     print('P this has run successfully');
      //     timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      //       if (provider.downloadTabs.length > 0) {
      //         // get index of current tab
      //         int index = provider.downloadTabs
      //             .indexWhere((element) => element == changeTab_name);
      //         print("P this index ${index}");
      //         print(
      //             "P this Provider tab length ${provider.downloadTabs.length}");
      //         if (index == 0 || index > 0) {
      //           print("P index found ${index}");
      //         } else {
      //           index = 0;
      //         }
      //         setState(() {
      //           changeTab = index;
      //           changeTabIns = false;
      //           t.cancel();
      //           _refreshKey = UniqueKey();
      //           Future.delayed(Duration(milliseconds: 500), () {
      //             switch_value = true;
      //             buildTabView(changeTab_name);
      //             changeTab = 0;
      //             scrollController.animateTo(scrollOffset,
      //                 duration: const Duration(milliseconds: 100),
      //                 curve: Curves.easeOutExpo);
      //           });
      //         });
      //       } else {
      //         print("P this Provider still ${provider.downloadTabs.length}");
      //       }
      //     });
      //   }
      // });

      if (name == "All") {
        List list = provider.downloads;
        List list_obj = provider.onePackDownloads;
        List<FileOBJ> search = provider.onePackDownloads;
        list_Search = search;
        Future.delayed(Duration(milliseconds: 1000), () {
          if (switch_value == true) {
            //print("switch val is: ${switch_value}");
            provider.switchCurrentFiles(provider.downloads, name, 'downloads');
            List list_obj = provider.onePackDownloads;
            switch_value = false;
            isMultiSelectionEnabled = false;
          }
        });

        if (list.length == 0) {
          return Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.grey,
            color: Colors.yellow[600],
            strokeWidth: 10,
          ));
        }

        return GridOrList(list, list_obj, name);
      } else {
        List list = provider.downloads;
        List list_obj = provider.onePackDownloads;
        List<FileOBJ> search = provider.onePackDownloads;
        list_Search = search;
        Future.delayed(Duration(milliseconds: 1000), () {
          if (switch_value == true) {
            //print("switch val is: ${switch_value}");
            provider.switchCurrentFiles(provider.downloads, name, 'downloads');
            List list_obj = provider.onePackDownloads;
            switch_value = false;
            isMultiSelectionEnabled = false;
          }
        });

        if (list.length == 0) {
          return Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.grey,
            color: Colors.yellow[600],
            strokeWidth: 10,
          ));
        }

        return GridOrList(list, list_obj, name);
      }
    });
  }

  Widget GridOrList(List list, List list_obj, String name) => isGrid
      ? GridView.builder(
          controller: scrollController,
          itemCount: list_obj.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 0, mainAxisSpacing: 0),
          itemBuilder: (context, index) {
            File file = File(list[index].path);
            String path = file.path;
            String mimeType = mime(path) ?? '';

            //String keep_status = keepfiles[index];

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
            var file_size = sortedItems[index].file_size.toString();
            var file_date =
                DateFormat('dd/MM/yyyy').format(sortedItems[index].file_date);
            String keep_status = sortedItems[index].keep_status.toString();

            var file_size_int = int.parse(file_size);
            file_size = formatBytes(file_size_int, 1);

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

            if (fileExt == "jpeg") {
              print("Found JPEG");
            }

            print("The Extensions ${fileExt}");

            final index1 = file_ext.indexWhere((element) => element == fileExt);
            if (index1 != -1) {
              if (fileExt == "png" || fileExt == "jpg" || fileExt == "jpeg") {
                asset_path = Image.file(File(thumbnail),
                    cacheHeight: 250, cacheWidth: 250);
              } else {
                asset_path = Image.asset('assets/${fileExt}.png');
              }
            } else {
              asset_path = Image.asset('assets/general.png');
            }

            var widget_type;

            if (keep_status == 'keep') {
              widget_type = Positioned(
                  top: 0,
                  left: 0,
                  child:
                      Image.asset('assets/keepit.png', width: 30, height: 30));
            } else if (keep_status == 'keep_for') {
              widget_type = Positioned(
                  top: 0,
                  left: 0,
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
                        ? doMultiSelection(thumbnail, name)
                        : doSingleSelection(thumbnail, name);
                    print('The selected thumbnail ${thumbnail}');
                  }),
                  onLongPress: () {
                    setState(() {
                      scrollOffset = scrollController.position.pixels;
                      isMultiSelectionEnabled = true;
                      doMultiSelection(thumbnail, name);
                      print('The selected thumbnail ${thumbnail}');
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
            File file = File(list[index].path);
            String path = file.path;
            //String keep_status = keepfiles[index];

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
            var file_size = sortedItems[index].file_size.toString();
            var file_date =
                DateFormat('dd/MM/yyyy').format(sortedItems[index].file_date);
            String keep_status = sortedItems[index].keep_status.toString();

            var file_size_int = int.parse(file_size);
            file_size = formatBytes(file_size_int, 1);

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

            if (fileExt == "jpeg") {
              print("Found JPEG");
            }

            print("The Extensions ${fileExt}");

            final index1 = file_ext.indexWhere((element) => element == fileExt);
            if (index1 != -1) {
              if (fileExt == "png" || fileExt == "jpg" || fileExt == "jpeg") {
                asset_path = Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Image.file(
                    File(thumbnail),
                    cacheHeight: 200,
                    cacheWidth: 200,
                  ),
                );
              } else {
                asset_path = Image.asset(
                  'assets/${fileExt}.png',
                  width: 60,
                  height: 60,
                );
              }
            } else {
              asset_path = Image.asset(
                'assets/general.png',
                width: 60,
                height: 60,
              );
            }

            var widget_type;

            if (keep_status == 'keep') {
              widget_type = Stack(
                children: [
                  widget_type = Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                    child: asset_path,
                  ),
                  Positioned(
                      top: 0,
                      left: 0,
                      child: Image.asset('assets/keepit.png',
                          width: 25, height: 25)),
                ],
              );
            } else if (keep_status == 'keep_for') {
              widget_type = Stack(
                children: [
                  widget_type = Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                    child: asset_path,
                  ),
                  Positioned(
                      top: 0,
                      left: 0,
                      child: Image.asset('assets/keepit_for.png',
                          width: 25, height: 25)),
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
                    ? doMultiSelection(thumbnail, name)
                    : doSingleSelection(thumbnail, name);
              }),
              onLongPress: () {
                setState(() {
                  scrollOffset = scrollController.position.pixels;
                  isMultiSelectionEnabled = true;
                  doMultiSelection(thumbnail, name);
                });
              },
            );
          },
        );

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

class MySearchDelegate extends SearchDelegate {
  static HashSet selectItems = new HashSet();
  final ScrollController scrollController = ScrollController();
  double scrollOffset = 0.0;
  final BottomSheet_Data bottomsheet_methods = new BottomSheet_Data();
  List<FileOBJ> searchResults = list_Search;

  late bool subbed = false;
  Future<bool> checkSub() async {
    subbed = await Subscription().checkSubscription();
    return await Subscription().checkSubscription();
  }

  /// Convert Byte to KB, MB, .......
  static String formatBytes(bytes, decimals) {
    if (bytes == 0) return '0.0 KB';
    var k = 1024,
        dm = decimals <= 0 ? 0 : decimals,
        sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
        i = (log(bytes) / log(k)).floor();
    return (((bytes / pow(k, i)).toStringAsFixed(dm)) + ' ' + sizes[i]);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: Color.fromARGB(255, 30, 107, 214),
    );
  }

  void doSingleSelection(String path, String name, BuildContext context) {
    print("Selected Path Now ${path}");
    if (selectItems.contains(path)) {
      selectItems.remove(path);
    } else {
      selectItems.clear();
      selectItems.add(path);

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
          builder: (context) => Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
            child: bottomsheet_methods.bottomSheet(
                context, [path.toString()], value),
          ),
        ).whenComplete(() {
          selectItems.clear();
        });
      });
    }
  }

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back));

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
            onPressed: () {
              if (query.isEmpty) {
                close(context, null);
              } else {
                query = '';
              }
            },
            icon: const Icon(Icons.clear))
      ];

  @override
  Widget buildSuggestions(BuildContext context) {
    List<FileOBJ> suggestions = searchResults.where((searchResult) {
      final result = searchResult.file_name.toLowerCase();
      final input = query.toLowerCase();

      return result.contains(input);
    }).toList();

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(top: 5.0, left: 1.0, right: 1.0),
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        late final sortedItems;
        final suggestion = suggestions[index];

        var thumbnail = suggestions[index].thumbnail.toString();
        var file_name = suggestions[index].file_name.toString();
        var file_size = suggestions[index].file_size.toString();
        var file_date = suggestions[index].file_date.toString();
        String keep_status = suggestions[index].keep_status.toString();

        var file_size_int = int.parse(file_size);
        file_size = formatBytes(file_size_int, 1);

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
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Image.file(
                File(thumbnail),
                cacheHeight: 250,
                cacheWidth: 250,
              ),
            );
          } else {
            asset_path =
                Image.asset('assets/${fileExt}.png', width: 80, height: 80);
          }
        } else {
          asset_path = Image.asset('assets/general.png', width: 80, height: 80);
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
                  child:
                      Image.asset('assets/keepit.png', width: 30, height: 30)),
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
              style: const TextStyle(color: Color.fromRGBO(222, 222, 222, 1))),
          trailing: Visibility(
            visible: selectItems.contains(thumbnail),
            child: const Icon(Icons.check, color: Colors.white, size: 20.0),
          ),
          onTap: (() {
            query = thumbnail.substring(thumbnail.lastIndexOf("/") + 1);
            scrollOffset = scrollController.position.pixels;
            _DownloadsState obj = _DownloadsState();
            doSingleSelection(thumbnail,
                thumbnail.substring(thumbnail.lastIndexOf("/")), context);
            obj.buildTabView("All");
          }),
        );
      },
    );
  }

  Key _refreshKey = UniqueKey();

  @override
  Widget buildResults(BuildContext context) {
    return Consumer(
        key: _refreshKey,
        builder:
            (BuildContext context, CategoryProvider provider, Widget? child) {
          List list = provider.allfiles;
          return Container(
            color: Colors.blue,
          );
        });
  }
}
