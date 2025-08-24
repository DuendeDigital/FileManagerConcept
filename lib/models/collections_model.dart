import 'dart:ffi';
import 'package:flutter/cupertino.dart';

class CollectionsModel{
  String thumbnail;
  String name;
  String date_created;
  String file_size;
  bool isSelected;
  String file_type;


  CollectionsModel(this.thumbnail ,this.name, this.date_created, this.file_size, this.isSelected, this.file_type);
}