import 'dart:io';
import 'dart:ffi';

import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keepit/constants/utils/controls.dart';
import 'package:keepit/constants/utils/shared_p.dart';
import 'package:keepit/features/traverse/widgets/tag_bottomsheet.dart';
import 'package:keepit/features/view_files/images.dart';
import 'package:keepit/models/collection_list.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/global_variables.dart';
import '../../../constants/utils/tags.dart';
import 'package:keepit/providers/category_provider.dart';
import 'bottomsheet_form.dart';
import 'package:open_file/open_file.dart';
import 'package:keepit/constants/utils/controls.dart' as controls;
import 'package:keepit/constants/utils/files.dart';
import 'package:keepit/common/subscriptions.dart';
import 'package:keepit/constants/custom_toast.dart' as CustomToast;
import 'package:keepit/constants/hide_notification.dart';

class BottomSheet_Data_ extends StatefulWidget {
  @override
  State<BottomSheet_Data_> createState() => BottomSheet_Data();
}

class BottomSheet_Data extends State<BottomSheet_Data_> {
  bool has_content = false;
  static late DateTime selectedDate;
  static List<String> collection_names = [];
  static List<String> remove_collection_names = [];
  String directory_selected = "";

  Key _refreshKey = UniqueKey();
  //bool subbed = false;
  TextEditingController textFieldController = TextEditingController();

  BottomSheet_Data() {
    // KeepFiles().createKeepLists();
    bool createkeepitlist =
        ShareP.preferences.getBool('createkeepitlist') ?? false;
    if (createkeepitlist == false ||
        createkeepitlist == null ||
        createkeepitlist == '') {
      KeepFiles().createKeepLists();
      print('Create List Triggered');
    } else {
      print('Create List Not Triggered');
    }

    getTags();
  }

  //FUNCTIONS
  void get_collections() async {
    controls.Controls().create_collections_container();
    var foo = await controls.Controls().get_all_collections('bottomsheet');
    print("Length foo ${foo.length}");

    //Remove Collection from Bottom Sheet
    for (int i = 0; i < remove_collection_names.length; i++) {
      print('Collections to remove are ${remove_collection_names[i]}');
      // if(!collection_names.last[i].contains(remove_collection_names[i])){
      collection_names
          .removeWhere((element) => element == remove_collection_names[i]);
      // }
    }

    if (foo.isNotEmpty) {
      for (int i = 0; i < foo.length; i++) {
        var collection_name = foo[i].path.split("/");

        if (collection_names.isEmpty ||
            !collection_names.contains(collection_name.last)) {
          collection_names.add(collection_name.last);
        } else {
          remove_collection_names.add(collection_name.last);
          // for (int i = 0; i < remove_collection_names.length; i++) {
          //   print('Collections to remove are ${remove_collection_names[i]}');
          //   collection_names.removeWhere((element) => element == remove_collection_names[i]);
          // }

        }

        if (collection_names[i].contains(".ads")) {
          collection_names.removeAt(i);
        }
      }
      has_content = true;
    } else {
      has_content = false;
      print("Collections are empty on the device");
    }
  }

  void delete(String _collection, context) async {
    bool success = await controls.Controls().delete_collection(_collection);
    if (success) {
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
            "Folder Deleted",
            "The Folder was successfully deleted",
            context),
      );
      remove_collection_names.add(_collection);
      var notice = await HideNotification().setValue();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isRedirect', true);

      Provider.of<CategoryProvider>(context, listen: false).getImages('image');
    }
  }

  // void add_to_collection(String folder_name, List<String> file_paths, context) async {
  //   bool success = false;
  //   String message = "";

  //   //Add all selected files to collection
  //   for (String path in file_paths) {
  //     success = await controls.Controls().add_to_collection(folder_name, [path]);
  //   }

  //   if (success) {
  //     Navigator.pop(context);
  //     Navigator.pop(context);
  //     var notice = await HideNotification().setValue();

  //     showModalBottomSheet(
  //       context: context,
  //       enableDrag: true,
  //       isDismissible: true,
  //       isScrollControlled: true,
  //       backgroundColor: Colors.transparent,
  //       shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.vertical(
  //         top: Radius.circular(20.0),
  //       )),
  //       constraints: BoxConstraints(
  //         maxWidth: MediaQuery.of(context).size.width - 25,
  //       ),
  //       builder: (context) => CustomToast.CustomToast().CustomToastNotification(
  //           Colors.green,
  //           Colors.amber,
  //           "assets/check.png",
  //           "File(s) Added",
  //           "File(s) sucessfully added to the Folder",
  //           context),
  //     );

  //     Provider.of<CategoryProvider>(context, listen: false).getImages('image');
  //   }
  // }

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

  // _open_dir_picker(List<String> path, bool is_move) async {
  //   //Open native file picker
  //   String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
  //   //If there is no directory selected, show error toast
  //   if (selectedDirectory != null) {
  //     if (!is_move) {
  //       //Show success toast
  //       if (controls.Controls().copy_files(path, selectedDirectory)) {
  //         showToast("Files copied successfully", true);
  //         return true;
  //       } else {
  //         showToast("File failed to copy", false);
  //         return true;
  //       }
  //     } else {
  //       //Show success toast
  //       if (controls.Controls().move_files(path, selectedDirectory)) {
  //         showToast("Files moved successfully", true);
  //         return true;
  //       } else {
  //         showToast("File failed to move", false);
  //         return true;
  //       }
  //     }
  //   } else {
  //     showToast('Error: No folder selected', false);
  //     return false;
  //   }
  // }

  _open_dir_picker(List<String> path, bool is_move) async {
    //Open native file picker
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    //If there is no directory selected, show error toast

    if (selectedDirectory != null) {
      if (selectedDirectory.contains(".ads") ||
          selectedDirectory.contains(".bin") ||
          selectedDirectory.contains("keepit")) {
        return false;
      } else {
        if (!is_move) {
          controls.Controls().copy_files(path, selectedDirectory);
          print("COPY $path");
          //Show success toast
          if (path.length > 1) {
            //showToast("Files copied successfully", true);
            return true;
          } else {
            //showToast("File copied successfully", true);
            return true;
          }
        } else {
          controls.Controls().move_files(path, selectedDirectory);
          print("MOVE $path");

          //Show success toast
          if (path.length > 1) {
            //showToast("Files moved successfully", true);
            return true;
          } else {
            //showToast("File moved successfully", true);
            return true;
          }
        }
      }
    } else {
      //showToast('Error: No folder selected', false);
      return false;
    }
  }
  // List<String> tagNames = [];

  // void getTags() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String> temp = prefs.getStringList('tagNames') ?? List.empty();
  //   tagNames = temp;
  //   print("TAGS ARE $tagNames");
  // }

  List<String> tagNames = [];
  Future getTags() async {
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

  showTagmodel(BuildContext context) {}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //checkSub();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // checkSub() async {
  //   subbed = await Subscription().checkSubscription();
  //   print("SUBBED $subbed");
  //   setState(() {
  //     _refreshKey = UniqueKey();
  //   });
  // }

//  var isSubbed = await Subscription().checkSubscription();

  bottomSheet(
    BuildContext context,
    List<String> path,
    bool subbed,
  ) {
    print("provider refresh key is: ${_refreshKey}");
    get_collections();
    //checkSub();

    return Column(
      key: _refreshKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 40.0, 15.0, 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: (() async {
                      List return_value = [];

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

                      for (var file in path) {
                        print("Multiple files test: $file");
                        var addlist =
                            await KeepFiles().addToList(file, "keep", "none");
                        print("File added to list status $addlist");
                        if (addlist == true) {
                          return_value.add(file);
                        }
                      }
                      print("Keeping Path ${path}");

                      if (return_value.isNotEmpty) {
                        Future.delayed(Duration.zero, () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          // Navigator.of(context).pop();
                          // Future.delayed(Duration(seconds: 1), () {

                          //   Navigator.pop(context);
                          //   Navigator.pop(context);
                          // });
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
                            builder: (context) =>
                                KeepItCustomToast(path.length, context),
                          ).whenComplete(() {
                            // Navigator.pop(context);
                          });
                        });
                        // Provider.of<CategoryProvider>(context, listen: false).getImages('image');
                      } else {
                        print("No files added to list");
                      }
                    }),
                    child: Column(
                      children: [
                        Image.asset('assets/keepit.png', width: 60, height: 60),
                        const SizedBox(height: 10.0),
                        const Text('KeepIt',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18.0,
                                color: Color.fromARGB(255, 75, 75, 75)))
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        enableDrag: true,
                        isDismissible: true,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.0),
                        )),
                        builder: (context) => Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                          child: KeepItForSheet(path),
                        ),
                      );
                      // }
                    },
                    child: Column(
                      children: [
                        Image.asset('assets/keepit_for.png',
                            width: 60, height: 60),
                        const SizedBox(height: 10.0),
                        const Text('KeepIt For',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18.0,
                                color: Color.fromARGB(255, 75, 75, 75)))
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (() async {
                      List return_value = [];
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

                      for (var file in path) {
                        print("Multiple files test: DELETEING $file");
                        var del = await KeepFiles().deleteFromList(file);
                        if (del == true) {
                          return_value.add(file);
                        }
                      }

                      // Navigator.pop(context);

                      if (return_value.isNotEmpty) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setBool('isRedirect', true);

                        Provider.of<CategoryProvider>(context, listen: false)
                            .getImages('image');
                        var notice = await HideNotification().setValue();

                        Future.delayed(Duration(seconds: 2), () {
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
                                    "File(s) have been deleted.",
                                    context),
                          );
                        });
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
                          builder: (context) => CustomToast.CustomToast()
                              .CustomToastNotification(
                                  Colors.red,
                                  Colors.amber,
                                  "assets/close.png",
                                  "Oops!",
                                  "There was an error deleting your files.",
                                  context),
                        );
                      }
                      // if (path.length > 1) {
                      //   showToast("File deleted successfully", true);
                      // } else {
                      //   showToast("Files deleted successfully", true);
                      // }

                      // Provider.of<CategoryProvider>(context, listen: false)
                      //     .getImages('image');
                      // Provider.of(context, listen: false).keepFiles(list);
                    }),
                    child: Column(
                      children: [
                        Image.asset('assets/delete.png', width: 60, height: 60),
                        const SizedBox(height: 10.0),
                        const Text('Delete',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18.0,
                                color: Color.fromARGB(255, 75, 75, 75)))
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              const Divider(
                thickness: 1,
                indent: 20,
                endIndent: 20,
                color: Colors.grey,
                height: 20,
              ),
              const SizedBox(height: 20.0),
              ListTile(
                // leading: GestureDetector(
                //     onTap: () {
                //       get_collections();
                //       if (!collection_names.isEmpty) {
                //         showModalBottomSheet(
                //           context: context,
                //           enableDrag: true,
                //           isDismissible: true,
                //           isScrollControlled: true,
                //           shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.vertical(
                //             top: Radius.circular(20.0),
                //           )),
                //           builder: (context) => Padding(
                //             padding:
                //                 const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                //             child: AddToCollection(path),
                //           ),
                //         );
                //       } else {

                //         showModalBottomSheet(
                //           context: context,
                //           enableDrag: true,
                //           isDismissible: true,
                //           isScrollControlled: true,
                //           backgroundColor: Colors.transparent,
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.vertical(
                //               top: Radius.circular(20.0),
                //             )
                //           ),
                //           constraints:  BoxConstraints(
                //             maxWidth:  MediaQuery.of(context).size.width - 25,
                //           ),

                //           builder: (context) =>  CustomToast.CustomToast().CustomToastNotification(Colors.green, Colors.amber, "assets/close.png", "No Folders", "Please create a folder", context),

                //         );

                //       }
                //     },
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Image.asset('assets/folder.png',width: 40, height: 40),
                //       SizedBox(height: 10.0),
                //       Image.asset('assets/folder.png',width: 40, height: 40),
                //     ],
                //   )),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        print('Clicked Now');
                        controls.Controls().create_collections_container();
                        var foo = await controls.Controls()
                            .get_all_collections('bottomsheet');
                        get_collections();

                        if (foo.length == 0) {
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
                                .CustomToastNotificationWithButton(
                                    Colors.red,
                                    Colors.amber,
                                    "assets/close.png",
                                    "No Folders",
                                    "Please create a folder",
                                    "Add a folder",
                                    "Folder",
                                    context),
                          );
                        } else {
                          get_collections();
                          showModalBottomSheet(
                            context: context,
                            enableDrag: true,
                            isDismissible: true,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.0),
                            )),
                            // backgroundColor: Colors.transparent,
                            builder: (context) => Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                              child: AddToCollection(path, context),
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Image.asset('assets/folder.png',
                              width: 40, height: 40),
                          SizedBox(width: 10.0),
                          const Text('Add to folder',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 75, 75, 75))),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0),
                    GestureDetector(
                      onTap: () async {
                        await getTags();
                        print('Tag names are ${tagNames}');

                        if (subbed == true) {
                          if (tagNames.isNotEmpty) {
                            tag_bottomsheetState().tag_sheet(context, path);
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
                                maxWidth:
                                    MediaQuery.of(context).size.width - 25,
                              ),
                              builder: (context) => CustomToast.CustomToast()
                                  .CustomToastNotificationWithButton(
                                      Colors.red,
                                      Colors.amber,
                                      "assets/close.png",
                                      "Please Add Tags",
                                      "You do not have any Tags",
                                      "Create Tag",
                                      "Tag",
                                      context),
                            );
                          }
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
                            builder: (context) => CustomToast.CustomToast()
                                .CustomToastNotification(
                                    Colors.red,
                                    Colors.amber,
                                    "assets/close.png",
                                    "Subscription Required",
                                    "Please subscribe to continue using this feature",
                                    context),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Image.asset('assets/tag.png', width: 40, height: 40),
                          SizedBox(width: 10.0),
                          const Text('Tag this file',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 75, 75, 75))),
                          SizedBox(width: 10.0),
                          // sdvkhjbhjbhjbhjbhjbhjbhjbhjbhjbhjbhjbhjbhjbhjbhjbhjbhjbhjbhjbbvbbbbbbbbbbbbbbbbvbvbvbvbvbvbvbvbvbvbvbvbvbvbvbvbvbvbvbvbvbv
                          subbed
                              ? Container()
                              :
                              // Container()
                              Image.asset('assets/badge.png',
                                  width: 40, height: 40)
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ExpandTapWidget(
                        onTap: () {
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
                              padding:
                                  const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                              child: MoreOptions(path, context),
                            ),
                          );
                        },
                        tapPadding: EdgeInsets.all(55.0),
                        child: const Icon(Icons.more_vert)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget loader() {
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
                const Text('Please wait...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(
                      22,
                      86,
                      176,
                      1,
                    ))),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget KeepItForSheet(path) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 40.0, 15.0, 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset('assets/keepit_for.png', width: 60, height: 60),
                  const SizedBox(height: 10.0),
                  const Text('KeepIt For',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.0,
                          color: Color.fromARGB(255, 75, 75, 75)))
                ],
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                  child: const Text(
                'Select how long you want to keep this file on your device. Files will be deleted on the selected date.',
                style: TextStyle(color: Color.fromARGB(255, 75, 75, 75)),
                textAlign: TextAlign.center,
              )),
              const SizedBox(height: 30.0),
              const Text('Choose day range',
                  style: TextStyle(
                      color: Color.fromARGB(255, 75, 75, 75),
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10.0),
              BottomSheetForm(path),
            ],
          ),
        ),
      ],
    );
  }

  // Widget MoreOptions(bool openwith_hide) => Column(
  Widget MoreOptions(List<String> path, context) {
    return path.length <= 1
        ? SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 40.0, 15.0, 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (() async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String _fileOpened =
                            prefs.getString('_fileOpened') ?? '';
                        String fileOpened = 'Open';
                        prefs.setString('_fileOpened', fileOpened);
                        OpenFile.open(path.first);
                      }),
                      child: const ListTile(
                        title: Center(
                            child: Text('Open With',
                                style: TextStyle(fontWeight: FontWeight.w400))),
                        trailing: Icon(Icons.arrow_forward),
                      ),
                    ),

                    const Divider(
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.grey,
                      height: 20, // The divider's height extent.
                    ),

                    // Icon(Icons.arrow_forward),
                    GestureDetector(
                      child: const ListTile(
                        title: Center(
                            child: Text('Share',
                                style: TextStyle(fontWeight: FontWeight.w400))),
                        trailing: Icon(Icons.arrow_forward),
                      ),
                      onTap: () async {
                        //Share
                        Navigator.pop(context);
                        Navigator.pop(context);
                        controls.Controls().share_to(path,
                            "Hey! I'd like to share this file with you from KeepIt");
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setBool('isRedirect', true);
                      },
                    ),

                    const Divider(
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.grey,
                      height: 20,
                    ),

                    // const ListTile(
                    //   title: Center(child: Text('Rename', style: TextStyle(fontWeight: FontWeight.w400 ))),
                    //   trailing: Icon(Icons.arrow_forward),
                    // ),

                    // const Divider(
                    //   thickness: 1,
                    //   indent: 20,
                    //   endIndent: 20,
                    //   color: Colors.grey,
                    //   height: 20,
                    // ),

                    GestureDetector(
                      child: ListTile(
                        title: Center(
                            child: Text('Copy',
                                style: TextStyle(fontWeight: FontWeight.w400))),
                        trailing: Icon(Icons.arrow_forward),
                      ),
                      onTap: () async {
                        // jkn

                        String _fileOpened =
                            ShareP.preferences.getString('_fileOpened') ?? '';
                        String fileOpened = 'Open';
                        ShareP.preferences
                          ..setString('_fileOpened', fileOpened);

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
                            padding:
                                const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                            child: loader(),
                          ),
                        );

                        var open = await _open_dir_picker(path, false);
                        if (open == true) {
                          var notice = await HideNotification().setValue();
                          ShareP.preferences.setBool('isRedirect', true);
                          Provider.of<CategoryProvider>(context, listen: false)
                              .getImages('image');

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
                                maxWidth:
                                    MediaQuery.of(context).size.width - 25,
                              ),
                              builder: (context) => CustomToast.CustomToast()
                                  .CustomToastNotification(
                                      Colors.green,
                                      Colors.amber,
                                      "assets/check.png",
                                      "Success!",
                                      "File(s) copied.",
                                      context),
                            );
                          });
                        } else {
                          // Navigator.pop(context);
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
                                    "Error!",
                                    "File(s) not copied. Please try again",
                                    context),
                          );
                        }
                      },
                    ),

                    const Divider(
                      thickness: 1, // thickness of the line
                      indent: 20,
                      endIndent: 20,
                      color: Colors.grey,
                      height: 20,
                    ),

                    GestureDetector(
                      child: ListTile(
                        title: Center(
                            child: Text('Move',
                                style: TextStyle(fontWeight: FontWeight.w400))),
                        trailing: Icon(Icons.arrow_forward),
                      ),
                      onTap: () async {
                        String _fileOpened =
                            ShareP.preferences.getString('_fileOpened') ?? '';
                        String fileOpened = 'Open';
                        ShareP.preferences.setString('_fileOpened', fileOpened);

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
                            padding:
                                const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                            child: loader(),
                          ),
                        );

                        var open = await _open_dir_picker(path, true);
                        if (open == true) {
                          var notice = await HideNotification().setValue();
                          ShareP.preferences.setBool('isRedirect', true);

                          Provider.of<CategoryProvider>(context, listen: false)
                              .getImages('image');
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
                                maxWidth:
                                    MediaQuery.of(context).size.width - 25,
                              ),
                              builder: (context) => CustomToast.CustomToast()
                                  .CustomToastNotification(
                                      Colors.green,
                                      Colors.amber,
                                      "assets/check.png",
                                      "Success!",
                                      "File(s) moved.",
                                      context),
                            );
                          });
                        } else {
                          // Navigator.pop(context);
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
                                    "Error!",
                                    "File(s) not moved. Please try again",
                                    context),
                          );
                        }
                      },
                    ),

                    const Divider(
                      thickness: 1, // thickness of the line
                      indent: 20,
                      endIndent: 20,
                      color: Colors.grey,
                      height: 20,
                    ),

                    GestureDetector(
                      onTap: () async {
                        print('File being renamed ${path.first}');
                        Navigator.of(context).pop();
                        controls.Controls()
                            .displayTextInputDialog(path.first, context);
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setBool('isRedirect', true);

                        // if(await controls.Controls().renameFile(path.toString(), context)){
                        //   // showToast("A File Successfully Renamed", true);
                        // }else{

                        //   // showToast("A File With This Name Already Exist", true);
                        // }
                      },
                      child: const ListTile(
                        title: Center(
                            child: Text('Rename',
                                style: TextStyle(fontWeight: FontWeight.w400))),
                        trailing: Icon(Icons.arrow_forward),
                      ),
                    ),

                    const Divider(
                      thickness: 1, // thickness of the line
                      indent: 20,
                      endIndent: 20,
                      color: Colors.grey,
                      height: 20,
                    ),

                    // tagNames.length != 0 ?

                    //   GestureDetector(
                    //     onTap: (){
                    //      //show bottom sheet
                    //      tag_bottomsheetState().tag_sheet(context,path);
                    //     },
                    //     child: const ListTile(
                    //       title: Center(child: Text('Add Tags', style: TextStyle(fontWeight: FontWeight.w400 ))),
                    //       trailing: Icon(Icons.arrow_forward),
                    //     ),
                    //   )
                    //   :
                    //   Container()
                  ],
                ),
              ),
            ],
          ))
        : SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 40.0, 15.0, 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: const ListTile(
                        title: Center(
                            child: Text('Share',
                                style: TextStyle(fontWeight: FontWeight.w400))),
                        trailing: Icon(Icons.arrow_forward),
                      ),
                      onTap: () async {
                        //Share
                        Navigator.pop(context);
                        Navigator.pop(context);
                        controls.Controls().share_to(path,
                            "Hey! I'd like to share this file with you from KeepIt");
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setBool('isRedirect', true);
                      },
                    ),
                    Divider(
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.grey,
                      height: 20,
                    ),
                    GestureDetector(
                      child: ListTile(
                        title: Center(
                            child: Text('Copy',
                                style: TextStyle(fontWeight: FontWeight.w400))),
                        trailing: Icon(Icons.arrow_forward),
                      ),
                      onTap: () async {
                        String _fileOpened =
                            ShareP.preferences.getString('_fileOpened') ?? '';
                        String fileOpened = 'Open';
                        ShareP.preferences
                          ..setString('_fileOpened', fileOpened);

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
                            padding:
                                const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                            child: loader(),
                          ),
                        );

                        print('Copy started');
                        var open = await _open_dir_picker(path, false);

                        if (open == true) {
                          ShareP.preferences.setBool('isRedirect', true);
                          Provider.of<CategoryProvider>(context, listen: false)
                              .getImages('image');

                          Future.delayed(Duration(seconds: 2), () async {
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
                                maxWidth:
                                    MediaQuery.of(context).size.width - 25,
                              ),
                              builder: (context) => CustomToast.CustomToast()
                                  .CustomToastNotification(
                                      Colors.green,
                                      Colors.amber,
                                      "assets/check.png",
                                      "Success!",
                                      "File(s) copied.",
                                      context),
                            );
                          });
                        } else {
                          // Navigator.pop(context);
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
                                    "Error!",
                                    "File(s) not copied. Please try again",
                                    context),
                          );
                        }
                      },
                    ),
                    Divider(
                      thickness: 1, // thickness of the line
                      indent: 20,
                      endIndent: 20,
                      color: Colors.grey,
                      height: 20,
                    ),
                    GestureDetector(
                      child: ListTile(
                        title: Center(
                            child: Text('Move',
                                style: TextStyle(fontWeight: FontWeight.w400))),
                        trailing: Icon(Icons.arrow_forward),
                      ),
                      onTap: () async {
                        String _fileOpened =
                            ShareP.preferences.getString('_fileOpened') ?? '';
                        String fileOpened = 'Open';
                        ShareP.preferences
                          ..setString('_fileOpened', fileOpened);

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
                            padding:
                                const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                            child: loader(),
                          ),
                        );

                        var open = await _open_dir_picker(path, true);

                        if (open == true) {
                          ShareP.preferences.setBool('isRedirect', true);
                          Provider.of<CategoryProvider>(context, listen: false)
                              .getImages('image');

                          Future.delayed(Duration(seconds: 2), () async {
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
                                maxWidth:
                                    MediaQuery.of(context).size.width - 25,
                              ),
                              builder: (context) => CustomToast.CustomToast()
                                  .CustomToastNotification(
                                      Colors.green,
                                      Colors.amber,
                                      "assets/check.png",
                                      "Success!",
                                      "File(s) moved.",
                                      context),
                            );
                          });
                        } else {
                          // Navigator.pop(context);
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
                                    "Error!",
                                    "File(s) not moved. Please try again",
                                    context),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ));
  }

  Widget AddToCollection(List<String> path, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 40.0, 15.0, 40.0),
              child: Column(
                children: [
                  CollectionList(path),
                  GestureDetector(
                    onTap: () {
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
                                controller: textFieldController,
                                decoration:
                                    InputDecoration(hintText: "Folder Name"),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    print('Close Sign');
                                    textFieldController.clear();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final validCharacters =
                                        RegExp(r'^[9&%=-_\-=@,\.;]+$');
                                    //Navigator.pop(context);
                                    if (!validCharacters
                                        .hasMatch(textFieldController.text)) {
                                      //Add to collection
                                      bool created_collection = await Controls()
                                          .create_collection(
                                              textFieldController.text);

                                      //Check if collection name already exists
                                      if (created_collection) {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        var notice =
                                            await HideNotification().setValue();

                                        showModalBottomSheet(
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
                                                  Colors.green,
                                                  Colors.amber,
                                                  "assets/check.png",
                                                  "New Folder Created",
                                                  "A new Folder was successfully created",
                                                  context),
                                        );

                                        // get_collections();
                                        textFieldController.clear();
                                      } else {
                                        Navigator.pop(context);
                                        var notice =
                                            await HideNotification().setValue();
                                        showModalBottomSheet(
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
                                                  "Already Exist",
                                                  "A Folder with the given name already exist",
                                                  context),
                                        );

                                        textFieldController.clear();
                                      }
                                    } else {
                                      Navigator.pop(context);
                                      var notice =
                                          await HideNotification().setValue();
                                      textFieldController.clear();
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
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(252, 198, 79, 1),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Create a Folder",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 15.0),
                            Icon(Icons.arrow_right_alt, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget CollectionList(List<String> path) {
    return ListView.builder(
      key: _refreshKey,
      itemCount: collection_names.length,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        final folder_name = collection_names[index];
        final time_folder_created = "KeepIt Folder";

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            leading: Image.asset('assets/folder.png', width: 60, height: 60),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(folder_name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(78, 78, 78, 1))),
                SizedBox(height: 5.0),
                Text(time_folder_created,
                    style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(78, 78, 78, 1))),
              ],
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

              // add_to_collection(folder_name, path, context);
              bool success = await controls.Controls()
                  .add_to_collection(folder_name, path);

              if (success) {
                var notice = await HideNotification().setValue();
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
                            "File(s) Added",
                            "File(s) sucessfully added to the Folder",
                            context),
                  );
                });
                Provider.of<CategoryProvider>(context, listen: false)
                    .getImages('image');
              } else {
                var notice = await HideNotification().setValue();

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
                          Colors.red,
                          Colors.amber,
                          "assets/close.png",
                          "Oops!",
                          "There was an error adding to the collection folder.",
                          context),
                );
              }

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isRedirect', true);
            },
            trailing: PopupMenuButton(
              color: GlobalVariables.secondaryColor,
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  child: Text('Delete', style: TextStyle(color: Colors.white)),
                  value: "Delete",
                ),
              ],
              onSelected: (value) {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Are You Sure?',
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(22, 86, 176, 1))),
                        content: Text(
                            "All files in this Folder will also be deleted!"),
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
                              Navigator.pop(context);
                              Navigator.pop(context);
                              delete(folder_name, context);
                              // bool delete_collection = await controls.Controls().create_collection(_textFieldController.text);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
        );
      },
    );
  }

///////////////////////////////////////////////////////////////CUSTOM TOAST///////////////////////////////////////////////////////////////
  Widget KeepItCustomToast(int length, BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pop();
      //print("Yeah, this line is printed after 3 seconds");
    });

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
                              length > 1
                                  ? Text(
                                      "${length.toString()} Items  Added With KeepIt Status. View Files With Statuses In Sorted Files",
                                      style: TextStyle(
                                          color: Colors.white, height: 1.3))
                                  : const Text(
                                      "1 Item  Added With KeepIt Status. View Files With Statuses In Sorted Files",
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
                            const Text("Selected file(s) permanently deleted",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0)),
                            const SizedBox(height: 10.0),
                            length > 1
                                ? Text(
                                    "${length.toString()} Files Were Deleted",
                                    style: TextStyle(
                                        color: Colors.white, height: 1.3))
                                : const Text("1 File Was Deleted",
                                    style: TextStyle(
                                        color: Colors.white, height: 1.3))
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
}
