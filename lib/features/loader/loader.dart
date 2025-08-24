import 'package:flutter/material.dart';
import 'package:keepit/features/onboard/screens/onboard.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:keepit/features/auth/screens/auth_screen.dart';

class LoaderScreen extends StatefulWidget {
  static const String routeName = '/Loader';
  const LoaderScreen({Key? key}) : super(key: key);

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: LoaderContent(),
      nextScreen: const AuthScreen(),
      backgroundColor: Color.fromRGBO(251, 251, 252, 1),
      splashIconSize: 650,
      duration: 2000,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}

Widget LoaderContent() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(100.0, 0, 100.0, 0),
          child: Image.asset('assets/logo.gif'),
        ),

      ],
    ),
  );
}
