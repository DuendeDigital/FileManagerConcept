import 'package:flutter/material.dart';
import 'package:keepit/common/widgets/custom_button.dart';
import 'package:keepit/common/widgets/custom_textfield.dart';
import 'package:keepit/constants/utils.dart';
import 'package:keepit/features/auth/screens/otp_screen.dart';
import 'package:keepit/features/auth/services/auth_service.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:keepit/features/auth/screens/register_screen.dart';

class ForgotPassword extends StatefulWidget {
  static const String routeName = '/forgot-password';
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  //Auth _auth = Auth.signup;
  final _getOTPFormKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  final TextEditingController _emailController = TextEditingController();

  final disable_btn = '';
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  void request_otp() {
    authService.request_otp(
      context: context,
      email: _emailController.text,
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
            const Text('Forgot Password'),
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
                    key: _getOTPFormKey,
                    child: Column(
                      children: [
                        const Text("Don't worry.\nEnter your email and we'll send you a 4 digit code to reset your password.", style: TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 50),

                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                        ),
                       
                        const SizedBox(height: 50),
                        
                        CustomButton(
                          text: 'FORGOT PASSWORD',
                          buttonColor:GlobalVariables.almostBlack,
                          onTap: () async{
                            
                              if (_getOTPFormKey.currentState!.validate()) {
                                if(_emailController.text.length!=0 || _emailController.text.length!=0  < 4){

                                  bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text);
                                  if(emailValid){
                                    request_otp();
                                  }else{
                                    showSnackBar(context, 'The entered email address is invalid');
                                  }
                                }else{
                                   showSnackBar(context, 'The entered email address is invalid');
                                }
                                  

                              }
                          }
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
