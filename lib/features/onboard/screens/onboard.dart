import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:keepit/features/auth/screens/auth_screen.dart';
import 'package:keepit/features/auth/screens/register_screen.dart';

class Onboard extends StatelessWidget {
  Onboard({super.key});
  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  final List<PageViewModel> pages = [
    PageViewModel(
      image: Center(
        child: Image.asset('assets/onboard1.png'),
      ),
      title: 'Manage Your Files With Keepit',
      body:
          'Keepit is an easy-to-use tool offering a powerful file explorer experience on your Android device.',
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(color: Colors.white),
      ),
    ),

    PageViewModel(
      image: Center(
        child: Image.asset('assets/onboard2.png', width: 450),
      ),
      title: 'Organize Your Files Faster With Keepit',
      body:
          'Keepit allows you to set powerful automations with a simple-to-use UI. Now you can easily keep the files you want or delete the ones you don\'t want immediately or at a set period of time.',
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(color: Colors.white),
      ),
    ),

    PageViewModel(
      image: Center(
        child: Image.asset('assets/onboard3.png', width: 450),
      ),
      title: 'Full-Featured File Management Capabilities',
      body: 'Keepit supports all file management actions. Its intuitive UI allows you to quickly take control of all your storage and file sharing needs.',
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(color: Colors.white),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/mobile_bg.png"), fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 25.0),
          child: Column(
            children: [
              SizedBox(height: 150.0),
              Expanded(
                child: IntroductionScreen(
                  globalBackgroundColor: Colors.transparent,
                  pages: pages,
                  dotsDecorator: DotsDecorator(
                    size: const Size(15, 15),
                    color: Color.fromRGBO(109, 160, 221, 1),
                    activeSize: const Size(22, 10),
                    activeColor: Colors.white,
                    activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  done:
                      const Text('Get Started', style: TextStyle(fontSize: 20)),
                  showSkipButton: false,
                  skip: const Text('Skip', style: TextStyle(fontSize: 20)),
                  showNextButton: false,
                  next: const Icon(Icons.arrow_forward),
                  onDone: () => onDone(context),
                  curve: Curves.bounceInOut,
                  showDoneButton: false,
                ),
              ),

              Container(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, AuthScreen.routeName, (route) => true);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromRGBO(38, 38, 38, 1),
                        ),
                        child: Center(
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.0),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(context, Register.routeName, (route) => true);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromRGBO(252, 198, 79, 1),
                        ),
                        child: Center(
                          child: Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void onDone(context) async {
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
  }
}
