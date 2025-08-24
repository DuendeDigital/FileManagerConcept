import 'package:flutter/material.dart';
import 'package:keepit/common/widgets/custom_button.dart';
import 'package:keepit/common/widgets/custom_textfield.dart';
import 'package:keepit/features/auth/screens/forgot_password.dart';
import 'package:keepit/features/auth/services/auth_service.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:keepit/features/auth/screens/register_screen.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth-screen';
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  //Auth _auth = Auth.signup;
  final _signInFormKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final disable_btn = '';
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
  }

  void signInUser() {
    authService.signInUser(
      context: context,
      email: _emailController.text,
      password: _passwordController.text,
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
            const Text('Login'),
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
                SizedBox(height: 120),
                Center(
                  child: Image.asset("assets/finger.png"),
                ),
                SizedBox(height: 30),
                Container(
                  child: Form(
                    key: _signInFormKey,
                    child: Column(
                      children: [

                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                        ),
                       
                        const SizedBox(height: 20.0),

                        CustomPasswordTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                        ),
                       

                        const SizedBox(height: 30),
                  
                        Container(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: (){
                                Navigator.push(context,MaterialPageRoute(builder: (context) => const ForgotPassword()));
                              },
                              child: Text('Forgot Password?', style: TextStyle(color: Color.fromRGBO(252, 198, 79, 1), fontSize: 14), textAlign: TextAlign.right))
                          )
                        ),
                  
                        const SizedBox(height: 50),
                        
                        CustomButton(
                          text: 'LOGIN',
                          buttonColor:GlobalVariables.almostBlack,
                          onTap: () {
                              if (_signInFormKey.currentState!.validate()) {
                                signInUser();

                              }
                          }
                        ),

                        const SizedBox(height: 50),
                        Container(
                          child: Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: (() {
                                Navigator.pushNamedAndRemoveUntil(context, Register.routeName, (route) => true);
                              }),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Dont't have an account? ", style: TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center),
                                  Text("Create Account", style: TextStyle(color: Color.fromRGBO(252, 198, 79, 1), fontSize: 14), textAlign: TextAlign.center),
                                ],
                              ),
                            )
                          )
                        ),

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
