import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keepit/providers/category_provider.dart';
import 'package:provider/provider.dart';

import '../../../constants/utils/files.dart';
// import 'bottomsheet_data.dart';

class sharedModalform extends StatefulWidget {
  String _file_path = "";

  sharedModalform(String path) {
    _file_path = path;
  }

  @override
  State<sharedModalform> createState() => sharedModalformState(_file_path);
}

class sharedModalformState extends State<sharedModalform> {
  //GLOBALS
  TextEditingController dateInput = TextEditingController();
  bool show = false;
  List<String> items = ['1 Day', '7 Days', '30 Days', 'Custom Date'];
  String? selectedItem = '30 Days';
  String _file_path = "";

  @override
  void initState() {
    dateInput.text = "";
    super.initState();
  }

  //CONSTRUCTOR
  sharedModalformState(String path) {
    _file_path = path;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        daypicker(),
        Visibility(
          visible: show ? true : false,
          child: datepicker(),
        )
      ],
    );
  }

  late DateTime pickedDate;
  Widget daypicker() => SizedBox(
        width: 240,
        child: DropdownButtonFormField(
          iconEnabledColor: Colors.grey,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width: 1, color: Colors.grey))),
          value: selectedItem,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: TextStyle(fontSize: 16.0)),
                  ))
              .toList(),
          onChanged: (item) => setState(() {
            selectedItem = item as String?;

            if (item == 'Custom Date') {
              show = true;
              print(show);
            } else {
              switch (item) {
                case '1 Day':
                  pickedDate = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      DateTime.now().hour,
                      DateTime.now().minute + 1440);

                              showModalBottomSheet(
                                context: context,
                                enableDrag: false,
                                isDismissible: false,
                                isScrollControlled: false,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20.0),
                                )),
                                // backgroundColor: Colors.transparent,
                                builder: (context) => Padding(
                                  padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                                  child: loader(),
                                ),
                              );
                              

                  break;
                case '7 Days':
                  pickedDate = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      DateTime.now().hour,
                      DateTime.now().minute + 10080);
                  print(
                      "Difference is ${pickedDate.difference(DateTime.now()).inDays.toString()} days");
                  
                               showModalBottomSheet(
                                context: context,
                                enableDrag: false,
                                isDismissible: false,
                                isScrollControlled: false,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20.0),
                                )),
                                // backgroundColor: Colors.transparent,
                                builder: (context) => Padding(
                                  padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                                  child: loader(),
                                ),
                              );
                                               

                  break;
                case '30 Days':
                  pickedDate = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      DateTime.now().hour,
                      DateTime.now().minute + 43200);
                  print(
                      "Provider status Difference is ${pickedDate.difference(DateTime.now()).inDays.toString()} days");
                               showModalBottomSheet(
                                context: context,
                                enableDrag: false,
                                isDismissible: false,
                                isScrollControlled: false,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20.0),
                                )),
                                // backgroundColor: Colors.transparent,
                                builder: (context) => Padding(
                                  padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                                  child: loader(),
                                ),
                              );
                                              
                 
                  break;
              }
              // if(pickedDate != null){
              int deletion_date =  pickedDate.difference(DateTime.now()).inDays + 1;
              print("Deletion date ${deletion_date}");

              Future.delayed(Duration(seconds: 1), () {
                if (item == "1 Day") {
                  print("Multiple files test: KEEP FOR $_file_path");
                  KeepFiles().deleteFromList(_file_path);
                  Provider.of<CategoryProvider>(context, listen: false)
                      .getImages('image');
                } else {
                  print("Multiple files test: KEEP FOR $_file_path");
                  KeepFiles()
                      .addToList(_file_path, "keep_for", pickedDate.toString());
                }
              });

              showModalBottomSheet(
                context: context,
                enableDrag: true,
                isDismissible: true,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.0),
                )),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 25,
                ),
                builder: (context) => KeepItForCustomToast(
                    _file_path.length, context, deletion_date.toString()),
              ).whenComplete(() {
                Navigator.pop(context);
                Navigator.pop(context);
              });

              show = false;
              // }
            }
          }),
        ),
      );


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


  Widget datepicker() => Column(
        children: [
          const SizedBox(height: 20.0),
          const Text('Choose a custom date',
              style: TextStyle(
                  color: Color.fromARGB(255, 75, 75, 75),
                  fontWeight: FontWeight.w800),
              textAlign: TextAlign.center),
          const SizedBox(height: 10.0),
          SizedBox(
            width: 240,
            child: TextField(
              controller: dateInput,
              decoration: InputDecoration(
                  icon: Icon(Icons.calendar_today), labelText: "Enter Date"),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: new DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        DateTime.now().hour,
                        DateTime.now().minute),
                    firstDate: DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        DateTime.now().hour,
                        DateTime.now().minute),
                    //DateTime.now() - not to allow to choose before today.
                    lastDate: DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        DateTime.now().hour,
                        DateTime.now().minute + (525600 * 200)));

                if (pickedDate != null) {
                  print(
                      pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                  print(formattedDate); //formatted date output using intl package =>  2021-03-16
                  
                  String difference = pickedDate.difference(DateTime.now()).inDays.toString();

                      showModalBottomSheet(
                        context: context,
                        enableDrag: false,
                        isDismissible: false,
                        isScrollControlled: false,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.0),
                        )),
                        // backgroundColor: Colors.transparent,
                        builder: (context) => Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                          child: loader(),
                        ),
                      );

                  
                  

                  setState(() async{
                    print("Multiple files test: KEEP FOR $_file_path");
                    bool success  = await KeepFiles().addToList(_file_path, "keep_for", pickedDate.toString());

                    if(success){
                      Future.delayed(Duration(seconds: 2), () {
                        Navigator.pop(context);
                        Navigator.pop(context);

                        showModalBottomSheet(
                          context: context,
                          enableDrag: true,
                          isDismissible: true,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.0),
                          )),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 25,
                          ),
                          builder: (context) => KeepItForCustomToast(
                              _file_path.length, context, difference.toString()),
                        );

                      }).whenComplete(() {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      });                     
                    }
                    

                    dateInput.text =  formattedDate; //set output date to TextField value.
                  });
                }
              },
            ),
          ),
        ],
      );

  Widget KeepItForCustomToast(int length, BuildContext context, String date) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pop();
      // Navigator.of(context).pop();
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0)),
              child: Container(
                color: Colors.amber[700],
                width: 50.0,
                height: 150,
                child: Text(''),
              ),
            ),
            Expanded(
                child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0)),
              child: Container(
                color: Colors.amber[300],
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/keepit_for.png",
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("We're On It!",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10.0),
                            length > 1
                                ? Text(
                                    "Selected file will be deleted in ${date} days. Check the KeepIt bin to restore this file.",
                                    style: TextStyle(
                                        color: Colors.white, height: 1.3))
                                : Text(
                                    "Selected file will be deleted in ${date} days. Check the KeepIt bin to restore this file.",
                                    style: TextStyle(
                                        color: Colors.white, height: 1.3))
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  // Navigator.of(context).pop();
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 25.0, 0, 0),
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 30.0,
                                      )),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 20,
          color: Colors.transparent,
          child: Text(""),
        ),
      ],
    );
  }
}
