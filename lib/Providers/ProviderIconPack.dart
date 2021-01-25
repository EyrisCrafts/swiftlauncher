import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';

class ProviderIconPack extends ChangeNotifier {
  Map<String, Uint8List> iconPack = Map();

  ProviderIconPack(this.iconPack);

  Uint8List getIcon(String pkg) {
    return iconPack[pkg];
  }

  setIconPack(Map<String, Uint8List> newIcons) {
    this.iconPack.clear();
    this.iconPack.addAll(newIcons);
    notifyListeners();
  }
}
