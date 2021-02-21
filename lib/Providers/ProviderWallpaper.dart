import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class ProviderWallpaper extends ChangeNotifier {
  Uint8List wallpaper;

  ProviderWallpaper(this.wallpaper);
  get getWallpaper => wallpaper;

  setWallpaper(Uint8List newwall) {
    this.wallpaper = newwall;
    notifyListeners();
  }
}
