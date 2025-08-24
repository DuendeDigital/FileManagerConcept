import 'dart:io';
import 'dart:isolate';
import 'dart:async';
import 'dart:math';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:keepit/constants/hide_notification.dart';
import 'package:keepit/constants/utils/controls.dart';
import 'package:keepit/constants/utils/tags.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomToastt extends StatefulWidget {
  CustomToastt({super.key});

  @override
  State<CustomToastt> createState() => CustomToast();
}

class CustomToast extends State<CustomToastt> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget CustomToastNotification(
      Color statusColor1,
      Color statusColor2,
      String statusImage,
      String heading,
      String contents,
      BuildContext context) {
    Future.delayed(Duration(seconds: 3)).then((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _runOnce = prefs.getString('_runOnce') ?? 'false';
      if (_runOnce == 'true') {
        prefs.setString('_runOnce', 'false');
        Navigator.of(context).pop();
        print("Yeah, this line is printed after 3 seconds");
      }
      //Navigator.pop(context);
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
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
                  color: statusColor1,
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
                  color: statusColor2,
                  height: 150,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              statusImage.toString(),
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
                              Text(heading.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                              const SizedBox(height: 15.0),
                              //length > 1 ? Text("${length.toString()} Items  Added With KeepIt Status. View Files With Statuses In Sorted Files", style: TextStyle(color: Colors.white, height: 1.3)): const Text("1 Item  Added With KeepIt Status. View Files With Statuses In Sorted Files", style: TextStyle(color: Colors.white, height: 1.3))
                              Text(contents.toString(),
                                  style: TextStyle(
                                      color: Colors.white, height: 1.3)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.fromLTRB(0, 10.0, 10.0, 0),
                              //   child: GestureDetector(
                              //     onTap: (){
                              //       Navigator.of(context).pop();
                              //     },
                              //     child: const Icon(Icons.close, color: Colors.white,size:30.0,)
                              //   ),
                              // ),
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


  Widget CustomToastNotificationWithButton(
      Color statusColor1,
      Color statusColor2,
      String statusImage,
      String heading,
      String contents,
      String buttonText,
      String buttonAction,
      context) {
       
    TextEditingController textFieldController = TextEditingController();
    print("Statement came through");

    // Future.delayed(Duration(seconds: 3)).then((_) async {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   String _runOnce = prefs.getString('_runOnce') ?? 'false';
    //   if (_runOnce == 'true') {
    //     prefs.setString('_runOnce', 'false');
    //     Navigator.of(context).pop();
    //     print("Yeah, this line is printed after 3 seconds");
    //   }
    //   //Navigator.pop(context);
    // });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
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
                  color: statusColor1,
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
                  color: statusColor2,
                  height: 150,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              statusImage.toString(),
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
                              Text(heading.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                              const SizedBox(height: 15.0),
                              //length > 1 ? Text("${length.toString()} Items  Added With KeepIt Status. View Files With Statuses In Sorted Files", style: TextStyle(color: Colors.white, height: 1.3)): const Text("1 Item  Added With KeepIt Status. View Files With Statuses In Sorted Files", style: TextStyle(color: Colors.white, height: 1.3))
                              Text(contents.toString(),
                                  style: TextStyle(
                                      color: Colors.white, height: 1.3)),
                              buttonAction == "Tag"
                                  ? ElevatedButton(
                                      onPressed: () {
                                        //Navigator.pop(context);
                                        //Navigator.pop(context);

                                        //Tag Action
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Please Enter The Tag Group Name',
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color.fromRGBO(
                                                            22, 86, 176, 1))),
                                                content: TextField(
                                                  autofocus: true,
                                                  controller:
                                                      textFieldController,
                                                  decoration: InputDecoration(
                                                      hintText:
                                                          "Tag Group Name"),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      print('Close Sign');
                                                      textFieldController
                                                          .clear();
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {

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

                                                      var addTag = await TagControls().createTag(textFieldController.text);

                                        
                                                      if (addTag == true) {
                                                        var notice = await HideNotification().setValue();
                                                          Future.delayed(Duration(seconds: 2), () {
                                                            Navigator.pop(context);
                                                            Navigator.pop(context);
                                                            Navigator.pop(context);
                                                            Navigator.pop(context);

                                                            showModalBottomSheet(
                                                              context: context,
                                                              enableDrag: true,
                                                              isDismissible: true,
                                                              isScrollControlled:
                                                                  true,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .vertical(
                                                                top:
                                                                    Radius.circular(
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
                                                                  CustomToastNotification(
                                                                      Colors.green,
                                                                      Colors.amber,
                                                                      "assets/check.png",
                                                                      "Tag Created!",
                                                                      "You can now assign files to tags and filter them fthe options.",
                                                                      context),
                                                            );

                                                          });
                                                      } else {
                                                        var notice =
                                                            await HideNotification()
                                                                .setValue();
                                                        Navigator.of(context).pop();
                                                        showModalBottomSheet(
                                                          context: context,
                                                          enableDrag: true,
                                                          isDismissible: true,
                                                          isScrollControlled:
                                                              true,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .vertical(
                                                            top:
                                                                Radius.circular(
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
                                                              CustomToastNotification(
                                                                  Colors.red,
                                                                  Colors.amber,
                                                                  "assets/close.png",
                                                                  "Tag Error!",
                                                                  "The tag name may exist already.",
                                                                  context),
                                                        );
                                                      }

                                                      textFieldController
                                                          .clear();
                                                    },
                                                    child: const Text('Okay'),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      child: Text(buttonText))
                                  : ElevatedButton(
                                      onPressed: () {
                                        //Folder Action
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Please Enter The Folder Name',
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color.fromRGBO(
                                                            22, 86, 176, 1))),
                                                content: TextField(
                                                  autofocus: true,
                                                  controller:
                                                      textFieldController,
                                                  decoration: InputDecoration(
                                                      hintText: "Folder Name"),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      print('Close Sign');
                                                      textFieldController
                                                          .clear();
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      final validCharacters =
                                                          RegExp(
                                                              r'^[9&%=-_\-=@,\.;]+$');
                                                      //Navigator.pop(context);
                                                      if (!validCharacters
                                                          .hasMatch(
                                                              textFieldController
                                                                  .text)) {
                                                        //Add to collection
                                                        bool
                                                            created_collection =
                                                            await Controls()
                                                                .create_collection(
                                                                    textFieldController
                                                                        .text);

                                                        //Check if collection name already exists
                                                        if (created_collection) {
                                                          Navigator.pop(context);
                                                          Navigator.pop(context);
                                                          var notice =
                                                              await HideNotification()
                                                                  .setValue();
                                                                  

                                                          showModalBottomSheet(
                                                            context: context,
                                                            enableDrag: true,
                                                            isDismissible: true,
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .vertical(
                                                              top: Radius
                                                                  .circular(
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
                                                                CustomToastNotification(
                                                                    Colors
                                                                        .green,
                                                                    Colors
                                                                        .amber,
                                                                    "assets/check.png",
                                                                    "New Folder Created",
                                                                    "A new Folder was successfully created",
                                                                    context),
                                                          );

                                                          // get_collections();
                                                          textFieldController
                                                              .clear();
                                                        } else {
                                                          Navigator.pop(
                                                              context);
                                                          var notice =
                                                              await HideNotification()
                                                                  .setValue();
                                                          showModalBottomSheet(
                                                            context: context,
                                                            enableDrag: true,
                                                            isDismissible: true,
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .vertical(
                                                              top: Radius
                                                                  .circular(
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
                                                                CustomToastNotification(
                                                                    Colors.red,
                                                                    Colors
                                                                        .amber,
                                                                    "assets/close.png",
                                                                    "Already Exist",
                                                                    "A Folder with the given name already exist",
                                                                    context),
                                                          );

                                                          textFieldController
                                                              .clear();
                                                        }
                                                      } else {
                                                        Navigator.pop(context);
                                                        var notice =
                                                            await HideNotification()
                                                                .setValue();
                                                        textFieldController
                                                            .clear();
                                                        showModalBottomSheet(
                                                          context: context,
                                                          enableDrag: true,
                                                          isDismissible: true,
                                                          isScrollControlled:
                                                              true,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .vertical(
                                                            top:
                                                                Radius.circular(
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
                                                          builder: (context) => CustomToast()
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
                                      child: Text(buttonText))
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.fromLTRB(0, 10.0, 10.0, 0),
                              //   child: GestureDetector(
                              //     onTap: (){
                              //       Navigator.of(context).pop();
                              //     },
                              //     child: const Icon(Icons.close, color: Colors.white,size:30.0,)
                              //   ),
                              // ),
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
}
