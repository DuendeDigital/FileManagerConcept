import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keepit/constants/custom_toast.dart';
import 'package:keepit/constants/hide_notification.dart';
import 'package:keepit/constants/utils/controls.dart';
import 'package:keepit/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/custom_toast.dart';
import '../../../constants/custom_toast.dart';
import '../../../constants/utils/tags.dart';
import '../../Collections/screens/keepitcollections.dart';
import '../../home/sorted_files.dart';
import '../../view_files/all_downloads.dart';
import '../../view_files/all_files.dart';
import '../../view_files/audio.dart';
import '../../view_files/docs.dart';
import '../../view_files/images.dart';
import '../../view_files/videos.dart';
import '../traverse.dart';

class tag_bottomsheet extends StatefulWidget {
  @override
  State<tag_bottomsheet> createState() => tag_bottomsheetState();
}

class tag_bottomsheetState extends State<tag_bottomsheet> {
  //GLOBALS
  List<String> tagNames = [];
  List<bool> tagValues = [];
  List<String> allFiles = [];
  List<String> setTags = [];
  List<String> keepitFiletags = [];
  List<String> tagFiles = [];

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  tag_bottomsheetState() {
    getTags();
  }


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



  Future<bool> getTags() async {
    //Get tags and set global array
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> temp = prefs.getStringList('tagNames') ?? List.empty();
    List<String> temp2 =
        (prefs.getStringList('keepitFiletags') ?? List.empty());
    List<String> temp3 = (prefs.getStringList('tagFiles') ?? List.empty());
    tagNames = temp;
    keepitFiletags = temp2;
    tagFiles = temp3;
    for (String i in temp) {
      tagValues.add(false);
    }
    if (tagNames.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> deleteTag(int index, BuildContext context) async {


    print('Tag Deleted ${index}');

    bool success = await TagControls().deleteTag(tagNames[index]);

    if (success) {
      //Show success messegae here
      // Your tags have been removed
    
      Future.delayed(Duration(seconds: 2), () async{
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
          builder: (context) => CustomToast().CustomToastNotification(
              Colors.green,
              Colors.amber,
              "assets/keepit.png",
              "Success",
              "The tag was deleted successfully.",
              context),
        );
      });
    } else {
      //Show error message here
      Future.delayed(Duration(seconds: 2), () async{
      Navigator.pop(context);
      Navigator.pop(context);
        var notice = await HideNotification().setValue();
        showModalBottomSheet(
            context: context,
            enableDrag: true,
            isDismissible: true,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.0),
            )),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 25,
            ),
            builder: (context) => CustomToast().CustomToastNotification(
              Colors.red,
              Colors.amber,
              "assets/close.png",
              "Error",
              "The tag was not deleted, something went wrong.",
              context));
      });
    }
  }

  void setTagvalues(List<String> files, BuildContext context) async {
    //Send values
    String tags = setTags.join(",");
    int tagsSuccessfullyadded = 0;
    // for (String file in files) {
    //   TagControls().addTagstoFile(file, tags);
    //     bool success = await TagControls().addTagstoFile(file, tags);
    //   if (success) {
    //     tagsSuccessfullyadded++;
    //   }else{
    //     tagsSuccessfullyadded--;
    //   }
    // }


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




    for (String file in files) {
      await TagControls().addTagstoFile(file, tags).then((value) {
        if(value != null){
          if(value){
            tagsSuccessfullyadded++;
          }
        }else{
          tagsSuccessfullyadded++;
        }
      });
    }
    if (tagsSuccessfullyadded < files.length) {
      var notice = await HideNotification().setValue();
      
      Future.delayed(Duration(seconds: 2), () async{
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        showModalBottomSheet(
            context: context,
            enableDrag: true,
            isDismissible: true,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.0),
            )),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 25,
            ),
            builder: (context) => CustomToast().CustomToastNotification(
                Colors.green,
                Colors.amber,
                "assets/check.png",
                "Success",
                "The tag(s) have been removed from the file(s).",
                context));
      });
    } else {
      var notice = await HideNotification().setValue();
      
      Future.delayed(Duration(seconds: 2), () async{
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        showModalBottomSheet(
            context: context,
            enableDrag: true,
            isDismissible: true,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.0),
            )),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 25,
            ),
            builder: (context) => CustomToast().CustomToastNotification(
                Colors.green,
                Colors.amber,
                "assets/check.png",
                "Success",
                "Your tag(s) have been added.",
                context));
      });
    }
    print("TAG ADDED SUCCESS IS DONE");
  }

  tag_sheet(BuildContext context, List<String> files) async {
    allFiles = files;
    getTags().then((hasTags) async {
      if (hasTags) {
        try {
          showModalBottomSheet(
            context: context,
            enableDrag: true,
            isDismissible: true,
            isScrollControlled: false,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.0),
            )),
            builder: (context) => Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
              child: tag_form(files, context),
            ),
          );
        } catch (e) {
          print("TAG ADDED SUCCESS FAILED!!!!!!!!!!!!!!!!!!!!!!");
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
          builder: (context) => CustomToast().CustomToastNotificationWithButton(
              Colors.red,
              Colors.amber,
              "assets/close.png",
              "No Tags found!",
              "Please create a tag and try again",
              "Add Tags",
              "Tag",
              context),
        );
      }
    });
  }

  tag_form(List<String> files, BuildContext context) {

    bool forceFalsetop = false;

    //Set tag values to true so the user knows which tags the file has
    for (int i = 0; i < tagFiles.length; i++) {
      for(String file in allFiles){
        //Only if the file has a tag
        if(tagFiles.contains(file)){
          //Do not set any values if another file does not have tags
          if(forceFalsetop == false){
            int indexOfcurrentFile = tagFiles.indexOf(file);
            //If the file has the particular tag in this iteration.
            for(String tag in tagNames){
              int indexOftag = tagNames.indexOf(tag);
              bool tagVal = true;
              bool forceFalse = false;
              if(keepitFiletags[indexOfcurrentFile].contains(tag)){
                print("a tagged file is true");

                if(forceFalse == false){
                  print("a tagged file contains $tag | ${keepitFiletags[indexOfcurrentFile]}");

                  tagValues[indexOftag] = true;
                  setTags.add(tagNames[indexOftag]);
                }else{
                  print("a tagged file contains $tag | ${keepitFiletags[indexOfcurrentFile]}");

                  tagValues[indexOftag] = false;
                  setTags.remove(tagNames[indexOftag]);
                }
              }else{
                print("a tagged file is false | ${keepitFiletags[indexOfcurrentFile]}");

                tagValues[indexOftag] = false;
                forceFalse = true;
                setTags.remove(tagNames[indexOftag]);
              }
            }
          }
        }else{
          print("Not a tagged file");
          forceFalsetop = true;
          for(String tag in tagNames){
            for(int i = 0; i < tagValues.length; i++){
              tagValues[i] = false;
            }
          int indexOftag = tagNames.indexOf(tag);
          setTags.remove(tagNames[indexOftag]);
          }
        }
      }
      // if (tagNames[index]) {
      //   tagValues[index] = true;
      //   setTags.add(tagNames[index]);
      // }
    }
    
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(children: [
        SizedBox(
          width: 400,
          height: 320,
          child: SingleChildScrollView(
            physics: const ScrollPhysics(),
            child: ListView.builder(
                itemCount: tagNames.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  getTags();
                  //Check for files with tags
                  if (tagFiles.contains(allFiles.first)) {
                    print("TAG ADDED SUCCESS FILE FOUNMD ON LIST");
                    int index_again = tagFiles.indexOf(allFiles.first);
                    //Check tags that the file has
                    String temp_Filetags = keepitFiletags[index_again];
                    List<String> temp_FiletagsArr = temp_Filetags.split(",");

                    // //Set tag values to true so the user knows which tags the file has
                    // for (String tag_name in temp_FiletagsArr) {
                    //   if (tag_name == tagNames[index]) {
                    //     tagValues[index] = true;
                    //     setTags.add(tagNames[index]);
                    //   }
                    // }
                  } else {
                    print("TAG ADDED SUCCESS NO FILE FOUNMD ON LIST");
                  }

                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Column(children: [
                      CheckboxListTile(
                        title: Text(tagNames[index]),
                        selected: tagValues[index],
                        value: tagValues[index],
                        onChanged: (value) {
                          setState(() {
                            print("Tag is: ${tagValues[index]}");
                            if (tagValues[index]) {
                              tagValues[index] = false;
                              setTags.removeWhere(
                                  (element) => element == tagNames[index]);
                            } else {
                              tagValues[index] = true;
                              setTags.add(tagNames[index]);
                            }

                          });
                        },
                        secondary: PopupMenuButton(
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              child: Text("Delete"),
                              value: 'Delete',
                              onTap: () {
                                print('Show loader');



                                deleteTag(index, context).whenComplete(() {
                                  // Navigator.pop(context);
                                  //Refresh category pages
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

                                  const Images().getTags();
                                  const Videos().getTags();
                                  const Docs().getTags();
                                  const Audio().getTags();
                                  const All().getTags();
                                  const Downloads().getTags();
                                  //Refresh folder pages
                                  Keepitcollections().getTags();
                                  //Refresh sorted files
                                  Sorted_Files(0).getTags();
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 1, // thickness of the line
                        indent: 20,
                        endIndent: 20,
                        color: Colors.grey,
                        height: 20,
                      )
                    ]);
                  });
                }),
          ),
        ),
        ElevatedButton(
            onPressed: () {

              setTagvalues(files, context);
              // Navigator.pop(context);
            },
            child: Text("Done"))
      ]),
    );

    //   }
    // );
  }
}
