import 'dart:io';
import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keepit/constants/custom_toast.dart' as CustomToast;
import 'package:keepit/constants/global_variables.dart';
import 'package:keepit/features/traverse/widgets/bottomsheet_data.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../constants/utils/controls.dart';
import '../../constants/utils/files.dart';
import '../../providers/category_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:keepit/features/traverse/widgets/bottomsheet_data.dart'
    as bottomsheets;

import 'keepFordate_picker.dart';

List<SharedMediaFile> files_shared = [];
List<String> currentfile = [];

class shared_files extends StatefulWidget {
  shared_files(List<SharedMediaFile> files) {
    print("initiated constructor");

    for (SharedMediaFile file in files) {
      if (!files_shared.contains(file)) {
        files_shared.add(file);
      }
    }

    //Check for duplicates
    for (int i = 0; i < files.length; i++) {
      for (int e = 0; e < files.length; e++) {
        if (files_shared[i] == files_shared[e]) {
          files.removeAt(i);
        }
      }
    }
  }
  @override
  State<shared_files> createState() => _shared_filesState();
}

class _shared_filesState extends State<shared_files>
    with WidgetsBindingObserver {
  AppLifecycleState? _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }

  String move_file(String files) {
    String shared_folder = "/storage/emulated/0/keepit/Shared/";
    var dir = Directory(shared_folder);
    if (dir.existsSync()) {
    } else {
      dir.createSync();
    }
    String newFilename = copyFile(files);

    // //Return new string
    // String temp = files.first.split("/").last;
    // String newFilename = "$shared_folder${files.first.split("/").last}";

    return newFilename;
  }

    String copyFile(String files) {

      String shared_folder = "/storage/emulated/0/keepit/Shared/";
      var dir = Directory(shared_folder);
      if (dir.existsSync()) {
      } else {
        dir.createSync();
      }

        String file_name = files.split("/").last;
        String extention = file_name.split(".").last;
        String FileName = file_name.split(".").first;
        bool forceMove = false;
        String newFilename = "";

        if (File("$shared_folder$file_name").existsSync()) {
          forceMove = true;
        } else {
          forceMove = false;
        }

        if (forceMove) {
          setState(() {
            newFilename = "$shared_folder$FileName ${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour} ${DateTime.now().second} ${DateTime.now().millisecond}.$extention";

            File(files).copySync(newFilename);
          });
        } else {
          print("FILE NAME IS: $file_name");
          setState(() {
            newFilename = "$shared_folder$file_name";
            File(files).copySync(newFilename);
          });
        }
      
      return newFilename;
    
  }

  //DECLARATIONS
  var showing = 0;
  int fileIndex = 0;
  String file_path = files_shared[0].path;



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


  Widget file_type(String path) {
    // print("The File Extension Is ${path.substring(path.lastIndexOf("."))}");
    print("The File Initial Path ${path}");

    var initial_path = path.toString().replaceAll("/data/user/0/app.keepit/cache/", "/storage/emulated/0/keepit/Shared/");

    if (currentfile.length == 0) {
      currentfile.add(initial_path);
      print("Initial Added ${initial_path}");
    }
    var fileExt = path.substring(path.lastIndexOf(".") + 1);

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

    Widget type;

    if (fileExt.toString() == "jpg" ||
        fileExt.toString() == "jpeg" ||
        fileExt.toString() == "png") {
      // print("First Statement");
      type = Image.file(File(files_shared[showing].path),
          width: 250, height: 250, fit: BoxFit.cover);
    } else {
      // print("Second Statement");
      final index1 = file_ext.indexWhere((element) => element == fileExt);
      if (index1 != -1) {
        type = Image.asset("assets/${fileExt}.png",
            width: 250, height: 250, fit: BoxFit.cover);
      } else {
        type = Image.asset("assets/general.png",
            width: 250, height: 250, fit: BoxFit.cover);
      }
    }

    return type;
  }

  List<String> current_cache_file = [];

  List<SharedMediaFile> temp = files_shared;
  List<String> files = [];

  Widget run_modal(context) {
    print("Files path ${files_shared}");

    for (SharedMediaFile path in temp) {
      files.add(path.path);
    }

    //Check if end has been reached
    //"${showing==0? "1" : showing + 1} of ${files_shared.length.toString()}"

    print('Files in the list ${files_shared.length}');

    print("File 1 ${files_shared[0]}");

    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addObserver(this);
    }

    @override
    void dispose() {
      // TODO: implement dispose
      WidgetsBinding.instance.removeObserver(this);
      super.dispose();
    }

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.black.withOpacity(0.5),
      child: SingleChildScrollView(
        child: Stack(alignment: Alignment.center, children: [
          Card(
            margin: const EdgeInsets.fromLTRB(20, 130, 20, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50.0,
                ),
                Text(
                  'Sending Files To KeepIt',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 10.0),

                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  child: Text(
                    files_shared[showing == 0 ? 0 : showing].path.substring(
                        files_shared[showing == 0 ? 0 : showing]
                                .path
                                .lastIndexOf("/") +
                            1),
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Padding(
                //   padding: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                //   child: Text('Sending Files To KeepIt Sending Files To KeepIt Sending Files To KeepIt', style: TextStyle(color: Colors.grey),),
                // ),
                SizedBox(
                  height: 20.0,
                ),

                files_shared.length == 1
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20), // Image border
                        child: SizedBox.fromSize(
                          size: Size.fromRadius(150), // Image radius
                          // child:  Image.file(File(files_shared[fileIndex].path), width: 250, height: 250, fit: BoxFit.cover),
                          child: file_type(files_shared[0].path),
                        ),
                      )
                    : CarouselSlider(
                        options: CarouselOptions(
                          height: 300.0,
                          enlargeCenterPage: false,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            // print(index + 1);
                            setState(() {
                              showing = showing + 1;

                              if (showing == files_shared.length) {
                                showing = 0;
                                file_type(files_shared[showing].path);
                                print("Current Index First ${showing}");
                              } else {
                                file_type(files_shared[1].path);
                                print("Current Index Second ${showing}");
                              }

                              file_path =
                                  files_shared[showing == 0 ? 0 : showing].path;
                              var current = file_path.toString().replaceAll(
                                  "/data/user/0/app.keepit/cache/",
                                  "/storage/emulated/0/keepit/Shared/");
                              currentfile.clear();
                              currentfile.add(current);
                              print("The current file path ${currentfile}");
                            });
                          },
                        ),
                        items: files_shared.map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(color: Colors.amber),
                                // child: Image.file(File('${i.path}'), width: 250, height: 250, fit: BoxFit.cover),
                                child: file_type(i.path),
                              );
                            },
                          );
                        }).toList(),
                      ),

                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  verticalDirection: VerticalDirection.down,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: (() async{
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
                              

                              current_cache_file.clear();
                              current_cache_file.add(file_path
                                  .toString()
                                  .replaceAll(
                                      "/storage/emulated/0/keepit/Shared/",
                                      "/data/user/0/app.keepit/cache/"));

                              String newFilename = move_file(
                                files_shared[showing == 0 ? 0 : showing].path
                              );
                              print("Keepit Script ${newFilename}");
                              
                              bool success = await KeepFiles().addToList(newFilename, "keep", "none");

                              Provider.of<CategoryProvider>(context, listen: false).getImages('image');

                              if(success){
                                // Navigator.of(context).pop();
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
                                    maxWidth:
                                        MediaQuery.of(context).size.width - 25,
                                  ),
                                  builder: (context) =>
                                      bottomsheets.BottomSheet_Data()
                                          .KeepItCustomToast(
                                              currentfile.length, context),
                                ).whenComplete(() {
                                  if (showing >= files_shared.length) {
                                    SystemNavigator.pop();
                                  } else {
                                    setState(() {
                                      files_shared.removeAt(showing);
                                    });
                                    if (showing >= files_shared.length) {
                                      SystemNavigator.pop();
                                    }
                                  }
                                });

                              }

                            }),
                            child: Column(
                              children: [
                                Image.asset('assets/keepit.png',
                                    width: 60, height: 60),
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


                              current_cache_file.clear();
                              current_cache_file.add(file_path
                                  .toString()
                                  .replaceAll(
                                      "/storage/emulated/0/keepit/Shared/",
                                      "/data/user/0/app.keepit/cache/"));

                              String newFilename = move_file(
                                files_shared[showing == 0 ? 0 : showing].path
                              );
                              print("Keep For Script ${newFilename}");

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
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 0, 10.0, 0),
                                  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15.0, 40.0, 15.0, 40.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Image.asset(
                                                    'assets/keepit_for.png',
                                                    width: 60,
                                                    height: 60),
                                                const SizedBox(height: 10.0),
                                                const Text('KeepIt For',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 18.0,
                                                        color: Color.fromARGB(
                                                            255, 75, 75, 75)))
                                              ],
                                            ),
                                            const SizedBox(height: 20.0),
                                            GestureDetector(
                                                child: const Text(
                                              'Select how long you want to keep this file on your device. Files will be deleted on the selected date.',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 75, 75, 75)),
                                              textAlign: TextAlign.center,
                                            )),
                                            const SizedBox(height: 30.0),
                                            const Text('Choose day range',
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 75, 75, 75),
                                                    fontWeight:
                                                        FontWeight.w800),
                                                textAlign: TextAlign.center),
                                            const SizedBox(height: 10.0),
                                            sharedModalform(
                                              newFilename,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                                  // BottomSheet_Data().KeepItForSheet(currentfile),
                                ),
                              ).whenComplete(() {
                                if (showing >= files_shared.length) {
                                  SystemNavigator.pop();
                                } else {
                                  setState(() {
                                    files_shared.removeAt(showing);
                                  });
                                  if (showing >= files_shared.length) {
                                    SystemNavigator.pop();
                                  }
                                }
                              });
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
                            onTap: (() async{
                              //To Be Continued

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


                              current_cache_file.clear();
                              current_cache_file.add(file_path
                                  .toString()
                                  .replaceAll(
                                      "/storage/emulated/0/keepit/Shared/",
                                      "/data/user/0/app.keepit/cache/"));
                              String newFilename = move_file(files_shared[showing == 0 ? 0 : showing].path);

                              bool success = await KeepFiles().deleteFromList(newFilename);

                              if(success){

                                print("Delete Script ${newFilename}");
                                Provider.of<CategoryProvider>(context, listen: false).getImages('image');

                                  Future.delayed(Duration(seconds: 2), () {
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
                                                "Success!",
                                                "File(s) have been deleted.",
                                                context),
                                      );

                                  });


                                if (showing >= files_shared.length) {
                                  SystemNavigator.pop();
                                } else {
                                  setState(() {
                                    files_shared.removeAt(showing);
                                  });
                                  if (showing >= files_shared.length) {
                                    SystemNavigator.pop();
                                  }
                                }

                              }


                            }),
                            child: Column(
                              children: [
                                Image.asset('assets/delete.png',
                                    width: 60, height: 60),
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
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
              top: 100,
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  color: GlobalVariables.secondaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_copy),
                    SizedBox(
                      width: 5.0,
                    ),
                    Text("Shared Files",
                        style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none))
                  ],
                ),
              )),
          Positioned(
              // left: 10,
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width - 100,
                height: 100,
                decoration: BoxDecoration(
                  color: GlobalVariables.secondaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${showing == 0 ? "1" : showing + 1} of ${files_shared.length.toString()}",
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none),
                    ),
                    SizedBox(height: 10.0),
                    Text("Files To Archive",
                        style: TextStyle(
                            fontSize: 18.0,
                            color: Color.fromARGB(255, 122, 122, 122),
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none))
                  ],
                ),
              )),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: run_modal(context),
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        });
  }
}
