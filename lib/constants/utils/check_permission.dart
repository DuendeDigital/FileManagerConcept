import 'package:keepit/features/splash/screens/splash_screen.dart';
// import 'package:flutter_background/flutter_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class check_permission{

  Future<List<String>> checkPermission() async {
    bool has_permission_storage = false;
    bool has_permission_background = false;
    List<String> permissions_allowed;
    try{
      //Storage Permission
      final status = await Permission.storage.request();
      if (status == PermissionStatus.granted) {
          has_permission_storage = true;
      } else if (status == PermissionStatus.denied) {
          has_permission_storage = false;
          // Navigator.pushNamedAndRemoveUntil(context, SplashScreen.routeName, (route) => true);
      } else if (status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      //Check Ext storage permission
        //ask for permission
      var _status = await Permission.manageExternalStorage.request();
      if (_status == PermissionStatus.granted) {
          has_permission_storage = true;
      } else if (_status == PermissionStatus.denied) {
          has_permission_storage = false;
          // Navigator.pushNamedAndRemoveUntil(context, SplashScreen.routeName, (route) => true);
      } else if (_status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      //End

      //Background permissions
      // has_permission_background = await _runAppbackground();
    }
    catch(e){
      print("Error $e");
      has_permission_storage = false;
      has_permission_background = false;
    }

    if(has_permission_storage && has_permission_storage){
      permissions_allowed = ["success"];
    }else{
      permissions_allowed = ["failed","storage:$has_permission_storage","background:$has_permission_background"];
    }

    return permissions_allowed;
  }

}