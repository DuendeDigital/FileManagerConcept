import 'dart:ffi';
import 'package:flutter/cupertino.dart';

class TraverseModel {
  String thumbnail;
  String name;
  DateTime date_created;
  int file_size;
  bool isSelected;
  String file_type;
  String can_open;

  TraverseModel(this.thumbnail, this.name, this.date_created, this.file_size,
      this.isSelected, this.file_type, this.can_open);
}
