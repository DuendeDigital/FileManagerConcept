import 'package:flutter/material.dart';

String uri = 'https://keep-it.app';

class GlobalVariables {
  // COLORS
  static const appBarGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 0, 36, 34),
      Color.fromARGB(255, 125, 221, 216),
    ],
    stops: [0.5, 1.0],
  );

  // static const secondaryColor = Color.fromARGB(255, 255, 166, 0); //Darshans color
  static const secondaryColor = Color.fromRGBO(252, 198, 79, 1);
  static const backgroundColor = Color.fromARGB(255, 219, 219, 219);
  static const Color greyBackgroundCOlor = Color(0xffebecee);
  static var selectedNavBarColor = Colors.cyan[800]!;
  static const unselectedNavBarColor = Colors.black87;
  static const almostBlack = Color.fromRGBO(38, 38, 38, 1);

  static List<List<String>> file_types = [
    //Images
    [".jpg", ".png", ".gif", ".tiff"],
    //Videos
    [".mp4"],
    //Audio
    [".mp3"],
    //Docs
    //Pdf
    [".pdf"],
    //Word
    [".doc", ".docx"],
    //Excel
    [".xlsx", "xlsm", ".xls", "xlsb", ".xltx"],
    //Open Office
    [".odt"],
    //Text
    [".txt", ".rtf", ".tex", ".wpd"],
    //Code
    [".html", ".css", ".js", ".php", ".jar", ".java", ".cpp", ".apk"],
  ];
}
