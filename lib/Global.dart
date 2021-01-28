import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';

class Global {
  static final Set<AppInfo> recentApps = Set();
  static final Map<String, Uint8List> iconPack = Map();
  static bool isIconTextVis = true;

  static final Color themeColor = Color(0xff00cdcd);

  static final List<String> iconIntents = [
    "com.fede.launcher.THEME_ICONPACK",
    "com.anddoes.launcher.THEME",
    "com.novalauncher.THEME",
    "com.teslacoilsw.launcher.THEME",
    "com.gau.go.launcherex.theme",
    "org.adw.launcher.THEMES",
  ];
}
