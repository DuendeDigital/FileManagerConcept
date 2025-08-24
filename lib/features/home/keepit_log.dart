import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class keepitLog extends StatefulWidget{
  @override
  State<keepitLog> createState() => _keepitLogState();
}

class _keepitLogState extends State<keepitLog> {

  Future<Widget> showItems(context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> deletedFiles = (prefs.getStringList('deletedFiles') ?? List.empty());

    return SingleChildScrollView(
      child: Container(
        child: Row(
          children: [
            ListView.builder(
              itemCount: deletedFiles.length,
              itemBuilder: (context,int index){
                return ListTile(
                  leading: Icon(Icons.delete_forever),
                  title: Text(deletedFiles[index].split("/").last),
                );
              }
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
      future: showItems(context),
      builder: (BuildContext, AsyncSnapshot){
        return Center(child: CircularProgressIndicator());
      }
    );
  }
}