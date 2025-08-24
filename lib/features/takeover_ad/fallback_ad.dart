import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:keepit/features/home/dashboard.dart';
import 'package:keepit/features/keep_it_pro/keepit_pro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class Fallback extends StatefulWidget {
  static const String routeName = '/fallback';
  const Fallback({super.key});

  @override
  State<Fallback> createState() => _FallbackState();
}

class _FallbackState extends State<Fallback> {
  Timer? _timer;
  int _start = 10;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
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
    disable_ad();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    startTimer();
  }

  void disable_ad() async{
      final prefs = await SharedPreferences.getInstance();
     prefs.reload();
     await prefs.setBool("trigger_ad", false);
  }

  @override
  Widget build(BuildContext context) {
    return image_modal();
  }

  Widget image_modal() {
    return Stack(
      children: [
        Center(
          child: GestureDetector(
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => const Keep_It_Pro()));
              },
              child: Image.asset("assets/fallbackAd.gif")),
        ),
        Positioned(
            left: 0,
            bottom: 10,
            child: _start != 0
                ? Card(
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('Skip Ad in ${_start} Seconds')),
                  )
                : GestureDetector(
                    onTap: (() {
                      Navigator.of(context).pop();
                      disable_ad();
                    }),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Text('Close Ad',
                                style: TextStyle(color: Colors.amber)),
                            SizedBox(width: 5.0),
                            Icon(Icons.chevron_right, color: Colors.amber)
                          ],
                        ),
                      ),
                    ),
                  ))
      ],
    );
  }
}
