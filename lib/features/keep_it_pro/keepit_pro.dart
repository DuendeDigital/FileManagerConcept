import 'package:flutter/material.dart';
import 'package:keepit/features/payments/payments.dart';
import 'package:keepit/models/list.dart';
import 'package:keepit/features/payments/payments.dart';
import 'package:provider/provider.dart';
import 'package:keepit/features/auth/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Keep_It_Pro extends StatefulWidget {
  static const String routeName = '/keep_it_pro';
  const Keep_It_Pro({super.key});

  @override
  State<Keep_It_Pro> createState() => _Keep_It_ProState();
}

class _Keep_It_ProState extends State<Keep_It_Pro> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    authService.getUserData(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 130,
        backgroundColor: const Color.fromRGBO(43, 104, 210, 1),
        elevation: 0,
        title: Center(
            child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Image.asset("assets/keepit_pro_logo.png"),
        )),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset("assets/x.png", width: 40, height: 40)),
          ),
        ],
      ),
      body: Container(
          color: const Color.fromRGBO(235, 235, 235, 1),
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30.0),
                    ListTile(
                      leading: ClipOval(
                        child: Container(
                          color: Colors.black,
                          height: 30,
                          width: 30,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Icon(Icons.remove, color: Colors.white),
                          ),
                        ),
                      ),
                      title: Text("Remove all ads in the app", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0, color: Color.fromARGB(255, 90, 90, 90))),
                    ),
                    ListTile(
                      leading: ClipOval(
                        child: Container(
                          color: Colors.black,
                          height: 30,
                          width: 30,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Icon(Icons.remove, color: Colors.white),
                          ),
                        ),
                      ),
                      title: Text("Custom Tag Management", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0, color: Color.fromARGB(255, 90, 90, 90))),
                    ),
                    ListTile(
                      leading: ClipOval(
                        child: Container(
                          color: Colors.black,
                          height: 30,
                          width: 30,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Icon(Icons.remove, color: Colors.white),
                          ),
                        ),
                      ),
                      title: Text("View hidden files", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0, color: Color.fromARGB(255, 90, 90, 90))),
                    ),
                    SizedBox(height: 50),
                    Stack(children: [
                      InkWell(
                        onTap: () {
                          print("Hidden: Monthly Payment Selected");
                          // navigate to payment page
                          //https://replaceme.com/pay/7ea9wkk-sh
                          //https://replaceme.com/pay/u1q48f-oph
                          Navigator.pushNamed(context, '/payments',
                              arguments: {'payment_type': 'monthly', 'title': 'Keepit Pro | Monthly Subscription', 'url': 'https://replaceme.com/pay/7ea9wkk-sh', 'plan_id': '1', 'amount': '19'});
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(
                                    color: Colors.yellow,
                                    width: 5,
                                  )),
                              color: const Color.fromRGBO(43, 104, 210, 1),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Monthly', style: TextStyle(fontWeight: FontWeight.w300, color: Color.fromARGB(255, 241, 239, 239), fontSize: 20.0)),
                                    SizedBox(height: 20.0),
                                    const Text('R19', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35.0)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        child: InkWell(
                          onTap: () {
                            print("Hidden: tapped");
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Popular', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16.0)),
                              ],
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.black,
                      ),
                    ]),
                    InkWell(
                      onTap: () {
                        print("Hidden: Yearly Payment Selected");
                        // navigate to payment page
                        //https://replaceme.com/pay/bg2b6q7xp-
                        //https://replaceme.com/pay/n1jfhvmfqb Duende
                        Navigator.pushNamed(context, '/payments',
                            arguments: {'payment_type': 'yearly', 'title': 'Keepit Pro | Yearly Subscription', 'url': 'https://replaceme.com/pay/bg2b6q7xp-', 'plan_id': '2', 'amount': '99'});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                )),
                            color: const Color.fromRGBO(249, 216, 93, 1),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Yearly', style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white, fontSize: 20.0)),
                                  SizedBox(height: 20.0),
                                  const Text('R99', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(34, 34, 34, 1), fontSize: 35.0)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
