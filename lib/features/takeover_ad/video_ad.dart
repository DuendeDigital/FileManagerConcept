import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:keepit/features/home/dashboard.dart';
import 'package:keepit/models/ads_model.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:wakelock/wakelock.dart';

class VideoAd extends StatefulWidget {
  static const String routeName = '/videoad';

   final String data;

  // VideoAd({Key? key});
  VideoAd({Key? key,
  required this.data
  });
 
  @override
  State<VideoAd> createState() => _VideoAdState();
}

class _VideoAdState extends State<VideoAd> {

  late VideoPlayerController controller;
  late ChewieController chewieController;
  bool enable = true;

  Timer? _timer;
  int _start = 10;

  var video_path = null;

  Future<void> loadVideoPlayer(String video_path_arg) async{
    controller = VideoPlayerController.network(video_path_arg.toString());
    controller.initialize();

    chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: false,
      looping: true,
      // aspectRatio: controller.value.aspectRatio*2,
      fullScreenByDefault: false,
      showControls: false,

    );

    final prefs = await SharedPreferences.getInstance();
    prefs.reload();
    setState(() {
      controller.addListener(() {
        if(!chewieController.isFullScreen){
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        }

        Future.delayed(const Duration(seconds: 5), (){
          if (controller.value.duration == controller.value.position) {
            _start = 0;
            //  Navigator.pop(context);
          }
        });

       
        prefs.setBool("trigger_ad", false);
      });
    });



  }



  void startTimer() {
    const oneSec =  Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });

          print("Reach Zero");
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _getList();

    get_offline_path();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Wakelock.toggle(enable: true);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
    chewieController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  }

  @override
  Widget build(BuildContext context) {

    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

    print('The received argument PATH ${arguments['online_takeover_path']} | LINK ${arguments['online_takeover_link']}');

    if(video_path==null){
      video_path = arguments['online_takeover_path'];
      print('Video path set to the variable');
      loadVideoPlayer(video_path.toString());
      controller.play();
      startTimer();

    }

    return WillPopScope(
      onWillPop: () async => false,
      child: video_modal(arguments['online_takeover_link'])
    );
  }
  
  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
  
  var offline_path_download;

  Future get_offline_path() async{
    final prefs = await SharedPreferences.getInstance();
    offline_path_download = prefs.getString('offline_takeover_path');

  }

  int count = 0;


  void disable_ad() async{
      final prefs = await SharedPreferences.getInstance();
     prefs.reload();
     await prefs.setBool("trigger_ad", false);
  }
  

  Widget video_modal(String online_link){
    return Center(
      child:  
      chewieController != null && chewieController.videoPlayerController.value.isInitialized ? 
      Stack(
        children: [
          GestureDetector(
            onTap: (){
              _launchInBrowser(Uri.parse(online_link.toString()));              
            },
            child: Chewie(controller: chewieController)
          ),
          Positioned(
            bottom: 10,
            left: 0,
            child:_start!=0 ?  Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('Skip Ad in ${_start} Seconds')
              ),
            )
            :
            GestureDetector(
              onTap: (() {
                Wakelock.toggle(enable: false);
                disable_ad();
                Navigator.of(context).pop();
              }),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text('Close Ad', style: TextStyle(color: Colors.amber)),
                      SizedBox(width: 5.0),
                      Icon(Icons.chevron_right, color: Colors.amber)
                    ],
                  ),
                ),
              ),
            )            ,
          )
        ],
      )
      : 
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const[
            CircularProgressIndicator(),
          ],
        ),
      )
    );
  }
}