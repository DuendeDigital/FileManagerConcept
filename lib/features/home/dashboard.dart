import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:isolate';
import 'dart:async';
import 'package:byte_converter/byte_converter.dart';
import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:keepit/constants/hide_notification.dart';
import 'package:keepit/constants/utils/loader.dart';
import 'package:keepit/constants/utils/tags.dart';
import 'package:keepit/features/keep_it_pro/keepit_pro.dart';
import 'package:keepit/features/takeover_ad/video_ad.dart';
import 'package:keepit/features/view_files/docs.dart';
import 'package:keepit/models/ads_model.dart';
import 'package:keepit/models/local_ads_model.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:keepit/common/widgets/navbar.dart';
import 'package:keepit/models/list.dart';
import 'package:keepit/models/storage_bar_list.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:keepit/features/view_files/images.dart';
import 'package:keepit/features/view_files/videos.dart';
import 'package:keepit/features/view_files/audio.dart';
import 'package:keepit/features/view_files/docs.dart';
import 'package:keepit/features/view_files/all_files.dart';
import 'package:keepit/features/view_files/all_downloads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../NewFiles/new_files_modal.dart';
import './sorted_files.dart';
import 'package:keepit/constants/utils/controls.dart' as controls;
import 'package:provider/provider.dart';
import 'package:keepit/features/traverse/traverse.dart';
import 'package:keepit/features/traverse/traverse2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keepit/features/Collections/screens/keepitcollections.dart';
import 'package:keepit/providers/category_provider.dart';
import 'package:expand_tap_area/expand_tap_area.dart';

import 'package:keepit/features/shared/shared_modal.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keepit/constants/custom_toast.dart' as CustomToast;
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;
import 'package:keepit/common/subscriptions.dart';

enum _MenuValues { NewCollection, NewTagGroup }

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  AppLifecycleState? _notification;

  bool reload_collections = false;
  Key _refreshKey = UniqueKey();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    Timer? timer_loaded;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _fileOpened = prefs.getString('_fileOpened') ?? '';
    bool _istabResumed = prefs.getBool('istabResumed') ?? false;
    bool move_or_copy = prefs.getBool('move_or_copy') ?? false;

    switch (state) {
      case AppLifecycleState.resumed:
        // if(move_or_copy==false || move_or_copy==null){
          print("app in resumed");
          // refreshTheKey();
          checkTheList();
          prefs.setBool('istabResumed', true);
          timer_loaded =
              Timer.periodic(Duration(seconds: 2), (Timer t) => reloadPage());
          setState(() {
            get_collections();
            reload_collections = true;
            if (_fileOpened != 'Open') {
              load_provider = true;
            } else {
              print('resume state file open');
              String fileOpened = '';
              prefs.setString('_fileOpened', fileOpened);
            }
            // Provider.of<CategoryProvider>(context, listen: false)
            //     .getImages('image');
          });
        // }

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

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late TextEditingController _textFieldController;
  static List<String> collection_names = [];
  List<String> reversed_collection_names = collection_names.reversed.toList();

  double int_strg_used = 0;
  double int_strg_total = 0;
  double ext_strg_used = 0;
  double ext_strg_total = 0;
  bool has_ext_strg = false;
  var storage_type;

  bool ActiveConnection = false;
  bool subscription_status = false;

  bool load_provider = false;
  bool _pageReloaded = false;

  void checkInternetconnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          ActiveConnection = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        ActiveConnection = false;
      });
    }
  }

  reloadPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _reloadPage = (prefs.getBool("_reloadPage") ?? false);
    if (_reloadPage) {
      setState(() {
        _pageReloaded = true;
      });
      _reloadPage = false;
      prefs.setBool("_reloadPage", _reloadPage);
    }
  }

  refreshTheKey() {
    setState(() {
      get_collections();
      _refreshKey = UniqueKey();
      print("refreshing the key $_refreshKey");
    });
  }

  checkTheList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keepitfiles =
        (prefs.getStringList('keepitfiles') ?? List.empty());
    print("list of files: $keepitfiles");
  }

  checkSubscription() async {
    subscription_status = await Subscription().checkSubscription();
    print("The subscription is ${subscription_status}");
    if (subscription_status == false) {
      getAdsData();
      display_local_ad();
      print('Getting ads');
    }
  }

  var shuffled_ads = null;

  Future getAdsData() async {
    var response = await http.get(Uri.parse('$uri/fetch_ads.php'));
    var jsonData = jsonDecode(response.body);

    List<Ads> ads_image = [];

    for (var u in jsonData) {
      Ads ad =
          Ads(u["ad_type"], u["title"], u["path"], u["link"], u["createdat"]);
      if (ad.ad_type == 'image_ad') {
        ads_image.add(ad);
      }
    }

    if (shuffled_ads == null) {
      shuffled_ads = (ads_image.toList()..shuffle());
    }

    return shuffled_ads;
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Timer? timer_loader;

  @override
  void initState() {
    super.initState();
    checkInternetconnection();
    checkSubscription();

    WidgetsBinding.instance.addObserver(this);

    timer_loader =
        Timer.periodic(Duration(seconds: 2), (Timer t) => reloadPage());

    getTags();
    checkSub().whenComplete(() {
      setState(() {});
    });

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // For sharing images coming from outside the app while the app is in the memory
    List<String> shared_file = [];
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      print("Init State Ran");

      setState(() {
        List<SharedMediaFile> files = value.toList();

        for (SharedMediaFile file in files) {
          print("FILE SHARED: ${file.path.toString()}");
          shared_file.add(file.toString());

          // Fluttertoast.showToast(
          //     msg: "FILE SHARED ${file.path.toString()}",
          //     toastLength: Toast.LENGTH_LONG,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 2,
          //     backgroundColor: Colors.orange,
          //     textColor: Colors.white,
          //     fontSize: 16.0);
        }

        if (files.isNotEmpty) {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false, // set to false

              pageBuilder: (_, __, ___) => shared_files(files),
            ),
          );
        }
      });
    });

    Provider.of<CategoryProvider>(context, listen: false).getImages('image');
    set_storage_state();
    _textFieldController = TextEditingController();
    get_collections();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _textFieldController.dispose();
    timer_loader?.cancel();
    // controller.dispose();
    // chewieController.dispose();
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  List<ListModel> items = [
    ListModel(Colors.green, const Icon(Icons.download, color: Colors.white),
        'Downloads'),
    ListModel(
        Colors.pink, const Icon(Icons.image, color: Colors.white), 'Images'),
    ListModel(Colors.lightBlue,
        const Icon(Icons.video_camera_front, color: Colors.white), 'Videos'),
    ListModel(Colors.purple, const Icon(Icons.audio_file, color: Colors.white),
        'Audio'),
    ListModel(Colors.red, const Icon(Icons.file_copy, color: Colors.white),
        'Documents and Other'),
    ListModel(
      Colors.yellow,
      const Icon(Icons.file_present, color: Colors.white),
      'All Files',
    )
  ];

  double convert_to_gigabyte(var byte_var) {
    if (byte_var <= 0) {
      return 0;
    } else {
      var i = (log(byte_var) / log(1024)).floor();
      return ((byte_var / pow(1024, i)));
    }
  }

  void set_storage_state() async {
    const platform = MethodChannel('app.keepit/battery');

    has_ext_strg = await controls.Controls().check_for_sdcard();
    // print('This is ' + has_ext_strg.toString());

    int free_disk_space = await platform.invokeMethod('getStorageFreeSpace');
    int total_disk_space = await platform.invokeMethod('getStorageTotalSpace');
    int used_disk_space = total_disk_space - free_disk_space;
    int total_ext_storage = 0;
    int free_ext_storage = 0;
    int used_ext_storage = 0;
    try {
      free_ext_storage =
          await platform.invokeMethod('getExternalStorageFreeSpace');
      total_ext_storage =
          await platform.invokeMethod('getExternalStorageTotalSpace');
      used_ext_storage = total_ext_storage - free_ext_storage;
    } catch (e) {
      print("Error" + e.toString());
    }

    //val x (8) / (8x1000x1000x1000) = val x 0.000000001
    storage_type = await controls.Controls().getExternalSdCardPath();
    print(storage_type);

    print("Total value " + total_disk_space.toString());

    setState(() {
      if (has_ext_strg) {
        int_strg_used = used_disk_space.toDouble();
        int_strg_total = total_disk_space.toDouble();
        ext_strg_used = used_ext_storage.toDouble();
        ext_strg_total = total_ext_storage.toDouble();
      } else {
        int_strg_used = used_disk_space.toDouble();
        int_strg_total = total_disk_space.toDouble();
      }
    });
  }

  List<List<String>> get_storage_types() {
    var int_strg_used_gb = ByteConverter.fromBytes(int_strg_used);
    var int_strg_total_gb = ByteConverter.fromBytes(int_strg_total);
    var ext_strg_used_gb = ByteConverter.fromBytes(ext_strg_used);
    var ext_strg_total_gb = ByteConverter.fromBytes(ext_strg_total);

    String status =
        "${int_strg_used_gb.gigaBytes.roundToDouble()} GB of ${int_strg_total_gb.gigaBytes.roundToDouble()} GB Used";

    if (has_ext_strg) {
      String ext_status =
          "${ext_strg_used_gb.gigaBytes.roundToDouble()} GB of ${ext_strg_total_gb.gigaBytes.roundToDouble()} GB Used";

      return [
        [
          status,
          (int_strg_used_gb.gigaBytes.roundToDouble() /
                  int_strg_total_gb.gigaBytes.roundToDouble() *
                  1)
              .toString(),
          'Internal'
        ],
        [
          ext_status,
          (ext_strg_used_gb.gigaBytes.roundToDouble() /
                  ext_strg_total_gb.gigaBytes.roundToDouble() *
                  1)
              .toString(),
          'External'
        ]
      ];
    } else {
      return [
        // [status, '0.5', 'Internal']
        [
          status,
          (int_strg_used_gb.gigaBytes.roundToDouble() /
                  int_strg_total_gb.gigaBytes.roundToDouble() *
                  1)
              .toString(),
          'internal'
        ]
      ];
    }
  }

  bool available_collections = false;
  late var collection_length = 2;
  late var collection_size = 0;

  KeepItFolderSize() async {
    controls.Controls().create_collections_container();
    var foo = await controls.Controls().get_all_file_collections('dashboard');
    if (foo == true) {
      return false;
    } else {
      return true;
    }
  }

//FUNCTIONS
  void get_collections() async {
    controls.Controls().create_collections_container();
    var foo = await controls.Controls().get_all_collections('dashboard');
    print("Length fooO ${foo.length}");

    var first_collection = foo.length;
    collection_size = foo.length + 1;
    print("Last collection size is: $collection_size");

    if (first_collection == 1) {
      collection_length = 1;
    } else {
      collection_length = 2;
    }

    var paths = [];
    print('Collections ${foo}');

    if (foo.isNotEmpty) {
      collection_names.clear();
      for (int i = 0; i < foo.length; i++) {
        print("Add to list");
        var collection_name = foo[i].path.split("/");

        available_collections = true;

        if (collection_names.isEmpty ||
            !collection_names.contains(collection_name.last)) {
          print("Last ${collection_name.last}");

          collection_names.add(collection_name.last);

          // if(collection_names.last==".bin"){
          //   collection_names.add(collection_name.last);
          // }else{
          //   collection_names.add(collection_name.last);
          // }

        }
        // }else{
        //   continue;
        // }

      }

      print('The Collections are ${collection_names}');
    } else {
      print("Foo");
      available_collections = false;
    }
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

                    SharedPreferences prefs = await SharedPreferences.getInstance();

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
                    bool created_collection = await controls.Controls().create_collection(right);
                    print("keep me: Created collection $created_collection");
                    //Check if collection name already exists
                    // prefs.setBool('istabResumed', true);
                    // didChangeAppLifecycleState(AppLifecycleState.resumed);

                    if (created_collection) {
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

                      // setState(() {
                      //   get_collections();
                      // });
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
                      
                        // prefs.setBool('istabResumed', false);

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

                    
                    prefs.setBool('istabResumed', false);
                  }
                },
                child: const Text('Okay'),
              ),
            ],
          );
        });
  }

  bool navigate_to = true;

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

  late bool subbed = false;
  Future<void> checkSub() async {
    setState(() async {
      subbed = await Subscription().checkSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (load_provider == true) {
      print("list LOAD PROVIDER");
      Provider.of<CategoryProvider>(context, listen: false).getImages('image');
      load_provider = false;
    }
    if (reload_collections == true) {
      get_collections();
      reload_collections = false;
    }
    if (_pageReloaded) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(context, '/all_files').then((_) {
          // Navigator.pushNamed(context, '/new_files_modal').then((_) {
          setState(() {
            // Provider.of<CategoryProvider>(context, listen: false)
            //     .getImages('image');
          });
        });
      });
      _pageReloaded = false;
    }
    // refreshTheKey();
    return Scaffold(
      key: _refreshKey,
      drawer: NavBar(),
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return ExpandTapWidget(
            tapPadding: EdgeInsets.all(155.0),
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Container(
                width: 200.0,
                child:
                    Image.asset("assets/hamburger.png", width: 5, height: 5)),
          );
        }),
        backgroundColor: Color.fromRGBO(22, 86, 176, 1),
        elevation: 0,
        title: const Text('Dashboard'),
        actions: [
          PopupMenuButton<_MenuValues>(
            color: Color.fromRGBO(34, 34, 34, 1),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                child:
                    Text('New Folder', style: TextStyle(color: Colors.white)),
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
              var isSubbed = await Subscription().checkSubscription();
              print('The Value ${value}');

              switch (value) {
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
                                      color: Color.fromRGBO(22, 86, 176, 1))),
                              content: TextField(
                                autofocus: true,
                                controller: _textFieldController,
                                decoration:
                                    InputDecoration(hintText: "Tag Group Name"),
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


                                    String str = _textFieldController.text;

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

                                    var addTag = await TagControls().createTag(right);

                                    if (addTag == true) {
                                      Navigator.of(context).pop();
                                      getTags();
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
                                                Colors.green,
                                                Colors.amber,
                                                "assets/check.png",
                                                "Tag Created!",
                                                "You can now assign files to tags and filter them from the options.",
                                                context),
                                      ).whenComplete((){
                                        Navigator.pop(context);
                                      });
                                      _textFieldController.clear();
                                    } else {
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
                  /////////////////////////////////////////////////////////////////////////////////////////
                  break;
              }
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/mobile_bg2.png"), fit: BoxFit.cover)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // has_ext_strg ? const Text('Has External') : const Text('No External'),

              has_ext_strg
                  ? Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigator.pushNamed(context, '/traverse2', arguments: {'storage_type': storage_type});
                            // Navigator.pushNamed(context, '/traverse2', arguments: {'storage_type': storage_type.toString()});

                            navigate_to
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const TraverseScreen()))
                                : Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        TraverseScreenExternal(
                                            value: storage_type.toString())));
                          },
                          child: CarouselSlider(
                            items: get_storage_types()
                                .map(
                                  (item) => Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Stack(
                                          children: <Widget>[
                                            Center(
                                              child: Text(item[0],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  15.0, 25.0, 15.0, 0),
                                              child: LinearPercentIndicator(
                                                leading: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 10, 0),
                                                  child: Image.asset(
                                                      "assets/white_folder.png",
                                                      width: 60,
                                                      height: 60),
                                                ),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    130,
                                                lineHeight: 14.0,
                                                percent: double.parse(item[1]),
                                                trailing: const Icon(
                                                    Icons.arrow_right_alt,
                                                    color: Colors.white),
                                                barRadius:
                                                    const Radius.circular(16),
                                                backgroundColor: Color.fromRGBO(
                                                    206, 226, 249, 1),
                                                progressColor: Color.fromRGBO(
                                                    22, 86, 176, 1),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 70, 85, 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(item[2],
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.white)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 50.0, 0, 0),
                                              child: Center(
                                                child: Image.asset(
                                                  'assets/progressbar.png',
                                                  width: 150,
                                                  height: 150,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            options: CarouselOptions(
                              autoPlay: true,
                              // aspectRatio: 2.0,
                              enlargeCenterPage: false,
                              viewportFraction: 1,
                              onPageChanged: (index, reason) {
                                // setState(() {
                                //stopped here
                                if (index == 0) {
                                  navigate_to = true;
                                } else {
                                  navigate_to = false;
                                }
                                // });
                              },
                            ),
                          ),
                        ),
                        buildMiddleWidget(),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const TraverseScreen()));
                          },
                          child: StreamBuilder<Object>(
                              stream: null,
                              builder: (context, snapshot) {
                                return Container(
                                    // height:
                                    //     MediaQuery.of(context).size.height - 100,
                                    child: ListView(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        children: <Widget>[
                                      const SizedBox(height: 30.0),
                                      Column(
                                        children: get_storage_types()
                                            .map(
                                              (item) => Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Stack(
                                                      children: <Widget>[
                                                        Center(
                                                          child: Text(item[0],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      20.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  15.0,
                                                                  15.0,
                                                                  15.0,
                                                                  0),
                                                          child:
                                                              LinearPercentIndicator(
                                                            leading: Image.asset(
                                                                "assets/white_folder.png",
                                                                width: 60,
                                                                height: 60),
                                                            // width: MediaQuery.of(context).size.width - 150,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                120,
                                                            lineHeight: 14.0,
                                                            percent:
                                                                double.parse(
                                                                    item[1]),
                                                            trailing: const Icon(
                                                                Icons
                                                                    .arrow_right_alt,
                                                                color: Colors
                                                                    .white),
                                                            barRadius:
                                                                const Radius
                                                                    .circular(16),
                                                            backgroundColor:
                                                                const Color
                                                                        .fromRGBO(
                                                                    206,
                                                                    226,
                                                                    249,
                                                                    1),
                                                            progressColor:
                                                                const Color
                                                                        .fromRGBO(
                                                                    22,
                                                                    86,
                                                                    176,
                                                                    1),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 70, 85, 0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(item[2],
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                          .white)),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0,
                                                                  50.0,
                                                                  0,
                                                                  0),
                                                          child: Center(
                                                            child: Image.asset(
                                                              'assets/progressbar.png',
                                                              width: 150,
                                                              height: 150,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                      // const SizedBox(height: 30.0),
                                      // buildMiddleWidget(),
                                    ]));
                              }),
                        ),
                        Container(child: buildMiddleWidget()),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  int count = 0;
  var isLoading = false;

  void display_local_ad() {
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isLoading = true;
      });
    });
  }

  Widget BannerOne() => Center(
        child: Container(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FutureBuilder<dynamic>(
                    future: getAdsData(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Container(
                            // child: Center(
                            //   child: SizedBox(
                            //     height: 100,
                            //     width: 100,
                            //     child: Center(
                            //       child: CircularProgressIndicator(),
                            //     ),
                            //   ),
                            // ),
                            );
                      } else {
                        return GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.reload();
                              String user_id = prefs.getString("id") ?? '';
                              String token =
                                  prefs.getString("x-auth-token") ?? '';
                              _launchInBrowser(Uri.parse(
                                  "$uri/api/v1/analytics.php?id=${user_id}&ad_name=${snapshot.data[0].title}&ad_link=${snapshot.data[0].link}&hash=${token}"));
                              print('Launch browser');
                            },
                            child: Image.network(snapshot.data[0].path));
                      }
                    },
                  )),
            ],
          ),
        ),
      );

  Widget BannerTwo() => Center(
        child: Container(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FutureBuilder<dynamic>(
                    future: getAdsData(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Container(
                            // child: Center(
                            //   child: SizedBox(
                            //     height: 100,
                            //     width: 100,
                            //     child: Center(
                            //       child: CircularProgressIndicator(),
                            //     ),
                            //   ),
                            // ),
                            );
                      } else {
                        return GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.reload();
                              String user_id = prefs.getString("id") ?? '';
                              String token =
                                  prefs.getString("x-auth-token") ?? '';
                              _launchInBrowser(Uri.parse(
                                  "$uri/api/v1/analytics.php?id=${user_id}&ad_name=${snapshot.data[1].title}&ad_link=${snapshot.data[1].link}&hash=${token}"));
                            },
                            child: Image.network(snapshot.data[1].path));
                      }
                    },
                  )),
            ],
          ),
        ),
      );

  Widget BannerThree() => Center(
        child: Container(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FutureBuilder<dynamic>(
                    future: getAdsData(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Container(
                            // child: Center(
                            //   child: SizedBox(
                            //     height: 100,
                            //     width: 100,
                            //     child: Center(
                            //       child: CircularProgressIndicator(),
                            //     ),
                            //   ),
                            // ),
                            );
                      } else {
                        return GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.reload();
                              String user_id = prefs.getString("id") ?? '';
                              String token =
                                  prefs.getString("x-auth-token") ?? '';
                              _launchInBrowser(Uri.parse(
                                  "$uri/api/v1/analytics.php?id=${user_id}&ad_name=${snapshot.data[2].title}&ad_link=${snapshot.data[2].link}&hash=${token}"));
                            },
                            child: Image.network(snapshot.data[2].path));
                      }
                    },
                  )),
            ],
          ),
        ),
      );

  Widget buildMiddleWidget() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                  child: Column(
                    children: [
                      Image.asset("assets/add_file.png",
                          width: 150, height: 150),
                      const SizedBox(height: 15),
                      const Text("KeepIt Folders",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(22, 86, 176, 1))),
                      const SizedBox(height: 10),
                      const Text("A quick way to organize your files",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Color.fromRGBO(22, 86, 176, 1))),
                      const SizedBox(height: 20.0),
                      available_collections
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    for (var x = 0; x < collection_length; x++)
                                      collection_length == 1
                                          ? Expanded(
                                              child: Center(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    var keepit_folder_size =
                                                        await KeepItFolderSize();
                                                    print(
                                                        "Keepit folder size is: $keepit_folder_size");
                                                    keepit_folder_size
                                                        ? Navigator.pushNamed(
                                                                context,
                                                                '/keepitcollection')
                                                            .then((_) {
                                                            setState(() {
                                                              // Provider.of<CategoryProvider>(context, listen: false)
                                                              //     .getImages('image');
                                                            });
                                                          })
                                                        : showModalBottomSheet(
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
                                                            builder: (context) => CustomToast
                                                                    .CustomToast()
                                                                .CustomToastNotification(
                                                                    Colors.red,
                                                                    Colors
                                                                        .amber,
                                                                    "assets/close.png",
                                                                    "Nothing to show!",
                                                                    "Your KeepIt folders are currently empty. Add files to these folders to view them here.",
                                                                    context),
                                                          );
                                                  },
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Center(
                                                        child: Image.asset(
                                                            "assets/folder.png",
                                                            width: 80,
                                                            height: 80),
                                                      ),
                                                      Center(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // SizedBox(height: 20.0),.reversed.toList()
                                                            Text(
                                                              collection_names
                                                                  .first,
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          22,
                                                                          86,
                                                                          176,
                                                                          1)),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          :

                                          //  for(var x = 0 ; x < 2 ; x++)
                                          Expanded(
                                              child: Center(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    var keepit_folder_size =
                                                        await KeepItFolderSize();
                                                    print(
                                                        "Keepit folder size is: $keepit_folder_size");
                                                    keepit_folder_size
                                                        ? Navigator.pushNamed(
                                                                context,
                                                                '/keepitcollection')
                                                            .then((_) {
                                                            setState(() {
                                                              // Provider.of<CategoryProvider>(context, listen: false)
                                                              //     .getImages('image');
                                                            });
                                                          })
                                                        : showModalBottomSheet(
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
                                                            builder: (context) => CustomToast
                                                                    .CustomToast()
                                                                .CustomToastNotification(
                                                                    Colors.red,
                                                                    Colors
                                                                        .amber,
                                                                    "assets/close.png",
                                                                    "Nothing to show!",
                                                                    "Your KeepIt folders are currently empty. Add files to these folders to view them here.",
                                                                    context),
                                                          );
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Center(
                                                        child: Image.asset(
                                                            "assets/folder.png",
                                                            width: 80,
                                                            height: 80),
                                                      ),
                                                      Center(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // SizedBox(height: 20.0),.reversed.toList()
                                                            Text(
                                                              collection_names
                                                                          .toList()[
                                                                              x]
                                                                          .length <
                                                                      6
                                                                  ? collection_names
                                                                          .toList()[
                                                                      x]
                                                                  : collection_names
                                                                          .toList()[
                                                                              x]
                                                                          .substring(
                                                                              0,
                                                                              6) +
                                                                      '...',
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          22,
                                                                          86,
                                                                          176,
                                                                          1)),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                    // Expanded(child: collections_widgets[1]),
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                GestureDetector(
                                  onTap: () async {
                                    var keepit_folder_size =
                                        await KeepItFolderSize();
                                    print(
                                        "Keepit folder size is: $keepit_folder_size");
                                    keepit_folder_size
                                        ? Navigator.pushNamed(
                                                context, '/keepitcollection')
                                            .then((_) {
                                            setState(() {
                                              // Provider.of<CategoryProvider>(context, listen: false)
                                              //     .getImages('image');
                                            });
                                          })
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
                                                    "Nothing to show!",
                                                    "Your KeepIt folders are currently empty. Add files to these folders to view them here.",
                                                    context),
                                          );
                                  },
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          const Color.fromRGBO(252, 198, 79, 1),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            "View Folders",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 15.0),
                                          Icon(Icons.arrow_right_alt,
                                              color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30.0),
                              ],
                            )
                          : Column(
                              children: [
                                const Text('Please Click Below to Add Folders',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color.fromRGBO(22, 86, 176, 1))),
                                const SizedBox(height: 30.0),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    minimumSize: const Size(200, 50),
                                    maximumSize: const Size(200, 50),
                                  ),
                                  onPressed: () {
                                    _displayTextInputDialog(context);
                                  },
                                  child: const Icon(Icons.add),
                                ),
                                const SizedBox(height: 30.0),
                                // Text('testing ${available_collections}')
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // const SizedBox(height: 10),

          //If User is a inactive subscriber
          subscription_status == false
              ? ActiveConnection
                  ?
                  //Online Ad
                  BannerOne()
                  :
                  //Offline Ad
                  Container(
                      child: Padding(
                      padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                      child: isLoading
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Keep_It_Pro()));
                              },
                              child: Image.asset("assets/ad1.gif"))
                          : Container(),
                    )
                      // Image.asset(File(shuffled_local_ads[0].toString())
                      )
              :

              //No Ad, the user is Active
              Container(child: Text('')),

          // const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/file_sent.png", width: 200, height: 200),
                  // SizedBox(height: 15),
                  const Text("View Sorted Files",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(22, 86, 176, 1))),
                  const SizedBox(height: 10),
                  const Text(
                      "Here you can view KeepIt files \nand files set for deletion",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromRGBO(
                        22,
                        86,
                        176,
                        1,
                      ))),
                  const SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => Sorted_Files(0)));
                              Navigator.pushNamed(context, '/sorted_files@keep')
                                  .then((_) {
                                setState(() {
                                  // Provider.of<CategoryProvider>(context, listen: false)
                                  //     .getImages('image');
                                });
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => Sorted_Files(1)));
                              Navigator.pushNamed(
                                      context, '/sorted_files@keepFor')
                                  .then((_) {
                                setState(() {
                                  // Provider.of<CategoryProvider>(context, listen: false)
                                  //     .getImages('image');
                                });
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => Sorted_Files(2)));
                              Navigator.pushNamed(context, '/sorted_files@bin')
                                  .then((_) {
                                setState(() {
                                  // Provider.of<CategoryProvider>(context, listen: false)
                                  //     .getImages('image');
                                });
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset('assets/delete.png',
                                    width: 60, height: 60),
                                const SizedBox(height: 10.0),
                                const Text('DeleteIt Bin',
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
                  ),
                ],
              ),
            ),
          ),
          // const SizedBox(height: 10),

          //If User is a inactive subscriber
          subscription_status == false
              ? ActiveConnection
                  ?
                  //Online Ad
                  BannerTwo()
                  :
                  //Offline Ad
                  Container(
                      child: Padding(
                      padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                      child: isLoading
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Keep_It_Pro()));
                              },
                              child: Image.asset("assets/ad2.gif"))
                          : Container(),
                    )
                      // Image.asset(File(shuffled_local_ads[0].toString())
                      )
              :

              //No Ad, the user is Active
              Container(child: Text('')),

          // const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 30.0, 0, 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/browse.png", width: 200, height: 200),
                    // SizedBox(height: 15),
                    const Text("Browse By Categories",
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(22, 86, 176, 1))),
                    const SizedBox(height: 30.0),

                    buildList(),
                  ],
                ),
              ),
            ),
          ),
          // const SizedBox(height: 10),

          //If User is a inactive subscriber
          subscription_status == false
              ? ActiveConnection
                  ?
                  //Online Ad
                  BannerThree()
                  :
                  //Offline Ad
                  Container(
                      child: Padding(
                      padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                      child: isLoading
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Keep_It_Pro()));
                              },
                              child: Image.asset("assets/ad3.gif"))
                          : Container(),
                    )
                      // Image.asset(File(shuffled_local_ads[0].toString())
                      )
              :

              //No Ad, the user is Active
              Container(child: Text('')),

          const SizedBox(height: 10),
          SizedBox(height: 30.0),
        ],
      );

  List<String> icons = [
    'assets/downloads_cat.png',
    'assets/images_cat.png',
    'assets/video_cat.png',
    'assets/music_cat.png',
    'assets/document_cat.png',
    'assets/allfiles_cat.png'
  ];

  Widget buildList() => ListView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          // final bg_color = items[index].bg_color;
          final name = items[index].name;
          // final icon = items[index].icon;

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: Image.asset(
                icons[index],
                width: 40,
                height: 40,
              ),
              title: Text(name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(78, 78, 78, 1))),
              onTap: () {
                if (name == "Downloads") {
                  Navigator.pushNamed(context, '/downloads').then((_) {
                    setState(() {
                      Provider.of<CategoryProvider>(context, listen: false)
                          .getImages('image');
                      get_collections();
                    });
                  });
                } else if (name == "Images") {
                  Navigator.pushNamed(context, '/images').then((_) {
                    setState(() {
                      Provider.of<CategoryProvider>(context, listen: false)
                          .getImages('image');
                      get_collections();
                    });
                  });
                } else if (name == "Videos") {
                  Navigator.pushNamed(context, '/videos').then((_) {
                    setState(() {
                      Provider.of<CategoryProvider>(context, listen: false)
                          .getImages('image');
                      get_collections();
                    });
                  });
                } else if (name == "Audio") {
                  Navigator.pushNamed(context, '/audio').then((_) {
                    setState(() {
                      Provider.of<CategoryProvider>(context, listen: false)
                          .getImages('image');
                      get_collections();
                    });
                  });
                } else if (name == "Documents and Other") {
                  Navigator.pushNamed(context, '/docs').then((_) {
                    setState(() {
                      Provider.of<CategoryProvider>(context, listen: false)
                          .getImages('image');
                      get_collections();
                    });
                  });
                } else if (name == "All Files") {
                  Navigator.pushNamed(context, '/all_files').then((_) {
                    setState(() {
                      Provider.of<CategoryProvider>(context, listen: false)
                          .getImages('image');
                      get_collections();
                    });
                  });
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => const All()));
                }
                else if (name == "New Files Modal") {
                                Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false, // set to false
                  pageBuilder: (_, __, ___) => new_files(),
                ),
              );
                }
              },
            ),
          );
        },
      );
}
