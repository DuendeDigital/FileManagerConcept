 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget loader(){
   return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
     children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 180.0),
            child: Column(
              children: [
                CircularProgressIndicator(
                    backgroundColor: Colors.blue[900],
                    color: Colors.yellow[600],
                    strokeWidth: 10,
                ),
                const SizedBox(height: 20.0),
                const Text('Please wait...',textAlign: TextAlign.center,style: TextStyle(color: Color.fromRGBO(22,86,176,1,))),
              ],
            ),
          ),
        )
     ],
   );     
}
