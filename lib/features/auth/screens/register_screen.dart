import 'package:flutter/material.dart';
import 'package:keepit/common/widgets/custom_button.dart';
import 'package:keepit/common/widgets/custom_textfield.dart';
import 'package:keepit/features/auth/services/auth_service.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:keepit/features/auth/screens/auth_screen.dart';

class Register extends StatefulWidget {
  static const String routeName = '/register';
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _signUpFormKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool disabled_btn = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
  }

  void signUpUser() {
    authService.signUpUser(
      context: context,
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Create Account'),
            Image.asset(
              "assets/logo_screens.png",
              width: 40,
              height: 40,
            )
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            // image: DecorationImage(Image.asset("mobile_bg.png"),fit: BoxFit.cover),
            image: DecorationImage(
                image: AssetImage("assets/mobile_bg.png"), fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                const SizedBox(height: 120),
                
                Center(
                  child: Image.asset("assets/safe.png"),
                ),
                
                const SizedBox(height: 30),

                Container(
                  child: Form(
                    key: _signUpFormKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Name',
                        ),

                        const SizedBox(height: 20.0),

                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                        ),

                        const SizedBox(height: 20.0),

                        CustomPasswordTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                        ),

                        const SizedBox(height: 50.0),

                        CustomButton(
                          text: 'CREATE ACCOUNT',
                          buttonColor:GlobalVariables.secondaryColor,
                          onTap: () {
                            if(disabled_btn){
                              null;
                            }else{
                              if (_signUpFormKey.currentState!.validate()) {
                                signUpUser();
                                setState(() {
                                  disabled_btn = true;
                                  print('Disabled');
                                });
                              }
                            }
                          }
                        ),

                        const SizedBox(height: 50),
                        Container(
                          child: Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: (){
                                Navigator.pushNamedAndRemoveUntil(context, AuthScreen.routeName, (route) => true);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Already have an account? ", style: TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center),
                                  Text("Login", style: TextStyle(color: Color.fromRGBO(252, 198, 79, 1), fontSize: 14), textAlign: TextAlign.center),
                                ],
                              ),
                            )
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
