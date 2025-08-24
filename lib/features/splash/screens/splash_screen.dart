import 'package:flutter/material.dart';
import 'package:keepit/features/onboard/screens/onboard.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: SplashContent(),
      nextScreen: Onboard(),
      backgroundColor: Color.fromRGBO(251, 251, 252, 1),
      splashIconSize: 650,
      duration: 3000,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}

Widget SplashContent() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(100.0, 0, 100.0, 0),
          child: Image.asset('assets/logo.gif'),
        ),
        // SizedBox(height: 10.0),
        // const Text('KEEP IT',
        //     style: TextStyle(
        //         fontSize: 30,
        //         fontWeight: FontWeight.bold,
        //         color: Color.fromRGBO(22, 86, 176, 1))),
      ],
    ),
  );
}
