import 'package:flutter/material.dart';
import 'package:keepit/common/widgets/custom_button.dart';
import 'package:keepit/common/widgets/custom_textfield.dart';
import 'package:keepit/constants/utils.dart';
import 'package:keepit/features/auth/screens/forgot_password.dart';
import 'package:keepit/features/auth/services/auth_service.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:keepit/features/auth/screens/register_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String routeName = '/reset-password';
  const ResetPasswordScreen({Key? key,  required this.value}) : super(key: key);
  final String value;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final _resetPasswordInFormKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpasswordController = TextEditingController();
  var email;

  final disable_btn = '';

 
 @override
  initState(){
    super.initState();
    setState(() {
      email = widget.value.toString();
    });
    print('The email widget ${email}');
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _cpasswordController.dispose();

  }

  void resetPassword() {
    authService.resetPassword(
      context: context,
      email: email,
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
            const Text('Reset Password'),
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
                    key: _resetPasswordInFormKey,
                    child: Column(
                      children: [

                        CustomPasswordTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                        ),
                       
                        const SizedBox(height: 20.0),

                        CustomPasswordTextField(
                          controller: _cpasswordController,
                          hintText: 'Confirm Password',
                        ),
                       

                        const SizedBox(height: 50),

                        
                        CustomButton(
                          text: 'RESET PASSWORD',
                          buttonColor:GlobalVariables.almostBlack,
                          onTap: () {
                              if (_resetPasswordInFormKey.currentState!.validate()) {
                                if(_passwordController.text!=_cpasswordController.text){
                                  showSnackBar(context, 'Password does not match');
                                }else if(_passwordController.text.length <= 4 || _cpasswordController.text.length <= 4){
                                  showSnackBar(context, 'Password must be longer than 4 characters');
                                }else{
                                  resetPassword();
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
