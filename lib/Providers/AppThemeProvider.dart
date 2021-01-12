import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class AppThemeProvider extends ChangeNotifier {
  // Map<String, Uint8List> icons;

  // AppThemeProvider() {
  //   icons = Map();
  // }

  // set

  String iconPack;

  get getIconPack => iconPack;
  set setIconPack(String iconPack) {
    this.iconPack = iconPack;
    notifyListeners();
  }
}
