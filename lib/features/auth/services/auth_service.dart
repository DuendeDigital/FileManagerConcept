import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:keepit/constants/error_handling.dart';
import 'package:keepit/constants/utils.dart';
import 'package:keepit/features/auth/screens/auth_screen.dart';
import 'package:keepit/features/auth/screens/otp_screen.dart';
import 'package:keepit/features/auth/screens/reset_password.dart';
import 'package:keepit/features/splash/screens/splash_screen.dart';
import 'package:keepit/models/user.dart';
import 'package:keepit/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:keepit/features/home/dashboard.dart';
import 'package:keepit/features/loader/loader.dart';
import 'package:logger/logger.dart';

class AuthService {
  checkInternetconnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      var intenetStatus = await checkInternetconnection();
      if (intenetStatus == true) {
        User user = User(
          id: '',
          name: name,
          email: email,
          password: password,
          token: dotenv.env['TOKEN_KEY'] ?? 'TOKEN KEY NOT FOUND',
        );

        http.Response res = await http.post(
          Uri.parse('$uri/api/v1/create_user.php'),
          body: user.toJson(),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        httpErrorHandle(
            response: res,
            context: context,
            onSuccess: () {
              showSnackBar(
                context,
                'User created successfully',
              );

              Navigator.pushNamedAndRemoveUntil(
                  context, LoaderScreen.routeName, (route) => false);
            });
      } else {
        showSnackBar(context, 'No Internet Connection');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      var intenetStatus = await checkInternetconnection();
      if (intenetStatus == true) {
        http.Response res = await http.post(
          Uri.parse('$uri/api/v1/sign_in.php'),
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        //print(res.body);
        httpErrorHandle(
            response: res,
            context: context,
            onSuccess: () async {
              print("Sign in response: ${res.body}");
              SharedPreferences prefs = await SharedPreferences.getInstance();
              Provider.of<UserProvider>(context, listen: false)
                  .setUser(res.body);
              await prefs.setString(
                  'x-auth-token', jsonDecode(res.body)['token']);
              await prefs.setString('name', jsonDecode(res.body)['name']);
              await prefs.setString('email', jsonDecode(res.body)['email']);
              await prefs.setString('id', jsonDecode(res.body)['id']);
              await prefs.setString(
                  'sub_plan', jsonDecode(res.body)['sub_plan']);
              await prefs.setString(
                  'sub_signup_date', jsonDecode(res.body)['sub_signup_date']);
              await prefs.setString(
                  'sub_end_date', jsonDecode(res.body)['sub_end_date']);
              await prefs.setString(
                  'sub_active', jsonDecode(res.body)['sub_active']);
              await prefs.setString(
                  'customer_id', jsonDecode(res.body)['customer_id']);
              Navigator.pushNamedAndRemoveUntil(
                  context, HomeScreen.routeName, (route) => false);
              // context, SplashScreen.routeName, (route) => false);
            });
      } else {
        showSnackBar(context, 'No Internet Connection');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }





  void resetPassword({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      var intenetStatus = await checkInternetconnection();
      if (intenetStatus == true) {
        http.Response res = await http.post(
          Uri.parse('$uri/api/v1/reset_password.php'),
          body: jsonEncode({
            'email':email,
            'password':password,
          }),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        //print(res.body);
        httpErrorHandle(
            response: res,
            context: context,
            onSuccess: () async {
              print("Password response: ${res.body.toString()}");
              if(res.body=="true"){
                  showSnackBar(context, 'Password successfully reseted');
                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.push(context,MaterialPageRoute(builder: (context) =>  const AuthScreen()));
                  });

              }else{
                showSnackBar(context, 'Something went wrong');
              }
            });
      } else {
        showSnackBar(context, 'No Internet Connection');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }




  Future<bool> VerifyOTP({
    required BuildContext context,
    required String otp,
    required String email,
  }) async {
    try {
      var intenetStatus = await checkInternetconnection();      

      if (intenetStatus == true) {
        http.Response res = await http.post(
          Uri.parse('$uri/api/v1/verify_otp.php'),
          body: jsonEncode({
            'otp':otp,
            'email':email,
          }),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        //print(res.body);
        httpErrorHandle(
            response: res,
            context: context,
            onSuccess: () async {
              print("Verify response: ${res.body}");
              if(res.body=="true"){
                 Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => ResetPasswordScreen(value: email.toString())));
              }else{
                showSnackBar(context, 'The entered OTP is incorrect');

              }
            });
            return true;
      } else {
        
        showSnackBar(context, 'No Internet Connection');
        return false;
      }

      
    } catch (e) {
      showSnackBar(context, e.toString());
      return false;
    }
  }




  void request_otp({
    required BuildContext context,
    required String email,
  }) async {
    try {
      var intenetStatus = await checkInternetconnection();


      if (intenetStatus == true) {
        http.Response res = await http.post(
          Uri.parse('$uri/api/v1/request_otp.php'),
          body: jsonEncode({
            'email':email.trim(),
            // 'token':token,
          }),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        //print(res.body);
        httpErrorHandle(
            response: res,
            context: context,
            onSuccess: () async {
              print("Request response: ${res.body}");
                
              // showSnackBar(context, 'Returned value ${res.body}');
              if(res.body=="true"){
                 Navigator.push(context,MaterialPageRoute(builder: (context) => OTP(value: email.toString())));
              }else{
                showSnackBar(context, 'A user with this email address does not exist');
              }
            });

      } else {
        
        showSnackBar(context, 'No Internet Connection');

      }

      
    } catch (e) {
      showSnackBar(context, e.toString());
    
    }
  }



  void getUserData({
    required BuildContext context,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');
      String? name = prefs.getString('name');
      String? email = prefs.getString('email');
      String? id = prefs.getString('id');
      String? sub_plan = prefs.getString('sub_plan');
      String? sub_signup_date = prefs.getString('sub_signup_date');
      String? sub_end_date = prefs.getString('sub_end_date');
      String? sub_active = prefs.getString('sub_active');
      String? customer_id = prefs.getString('customer_id');

      if (token == null) {
        prefs.setString('x-auth-token', '');
        prefs.setString('name', '');
        prefs.setString('email', '');
        prefs.setString('id', '');
        prefs.setString('sub_plan', '');
        prefs.setString('sub_signup_date', '');
        prefs.setString('sub_end_date', '');
        prefs.setString('sub_active', '');
        prefs.setString('customer_id', '');

        var tokenRes = await http.post(
          Uri.parse('$uri/api/v1/tokenIsValid.php'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token!,
            'name': name!,
            'email': email!,
            'id': id!,
          },
        );

        var response = jsonDecode(tokenRes.body);
        print("Auth response: ${response}");
        if (response == true) {
          var userToken = jsonEncode({
            'token': token,
            'name': name,
            'email': email,
            'id': id,
          });

          var userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.setUser(userToken);
        }
      } else {
        var userToken = jsonEncode({
          'token': token,
          'name': name,
          'email': email,
          'id': id,
        });

        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userToken);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
