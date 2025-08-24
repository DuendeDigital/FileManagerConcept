import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keepit/common/widgets/custom_button.dart';
import 'package:keepit/common/widgets/custom_textfield.dart';
import 'package:keepit/constants/utils.dart';
import 'package:keepit/features/auth/screens/reset_password.dart';
import 'package:keepit/features/auth/services/auth_service.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:keepit/features/auth/screens/register_screen.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

class OTP extends StatefulWidget {
  static const String routeName = '/otp';
  // const OTP({Key? key}) : super(key: key);
  const OTP({Key? key, required this.value,
  }) : super(key: key);

  final String value;
  
  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  //Auth _auth = Auth.signup;
  final _verifyFormKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  Timer? _timer;
  int _start = 59;
  
  var _preceding = 4;
  
  String otp = '';
  var email;

  final disable_btn = '';
  @override
  void dispose() {
    super.dispose();
  }

 @override
  initState(){
    super.initState();
    startTimer();
    email = widget.value.toString();
  }

  void startTimer() {
    const oneSec =  Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            if(_preceding==0){
              timer.cancel();
              print("End of timer");
              Navigator.of(context).pop();
            }else{
              _start=59;
              _preceding--;
            }
          });

        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }


  void VerifyOTP() {
    authService.VerifyOTP(
      context: context,
      otp: otp,
      email: email,
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
            const Text('Verification'),
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
                    key: _verifyFormKey,
                    child: Column(
                      children: [
                        const Text("Enter Your Verification Code", style: TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(height: 20),
                        Text("${_preceding} : ${_start}", style: TextStyle(color: Colors.white, fontSize: 24)),

                        
                        const SizedBox(height: 50),
                        OTPTextField(
                          length: 4,
                          width: MediaQuery.of(context).size.width,
                          fieldWidth: 80,
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white
                          ),
                          textFieldAlignment: MainAxisAlignment.spaceAround,
                          fieldStyle: FieldStyle.underline,
                          otpFieldStyle: OtpFieldStyle(borderColor: Colors.white,enabledBorderColor: Colors.amber, focusBorderColor: Colors.amber,errorBorderColor: Colors.red),
                          onCompleted: (pin) {
                            print("Completed: " + pin);
                            setState(() {
                              otp = pin;
                            });
                          },
                        ),

                        const SizedBox(height: 50),                        
                    
                        RichText(
                          text: TextSpan(
                            text: "We sent a verification code to your email",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            children: <TextSpan>[
                              TextSpan(text: '\n${email}.', style: TextStyle(color: Colors.amber)),
                              TextSpan(text: ' You can \ncheck your inbox.', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 50),
                        CustomButton(
                          text: 'VERIFY',
                          buttonColor:GlobalVariables.almostBlack,
                          onTap: () async{
                              if (_verifyFormKey.currentState!.validate()) {
                                if(otp.toString().length==4 || otp !=''){
                                  VerifyOTP();
        
                                }else{
                                   showSnackBar(context, 'Please enter 4 digits verification code');
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
