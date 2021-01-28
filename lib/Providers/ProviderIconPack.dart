import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';

class ProviderIconPack extends ChangeNotifier {
  Map<String, Uint8List> iconPack = Map();
  String iconPackName;

  ProviderIconPack(this.iconPack, this.iconPackName);

  get getIconPackName => iconPackName;

  set setIconPackName(String str) {
    iconPackName = str;
  }

  Uint8List getIcon(String pkg) {
    return iconPack[pkg];
  }

  addNewIcon(String pkg, Uint8List icon) {
    this.iconPack.addEntries([MapEntry(pkg, icon)]);
  }

  setIconPack(Map<String, Uint8List> newIcons, String pkgName) {
    this.iconPack.clear();
    this.iconPack.addAll(newIcons);
    this.iconPackName = pkgName;
    notifyListeners();
  }
}
