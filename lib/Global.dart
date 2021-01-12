import 'dart:collection';
import 'dart:typed_data';

import 'package:swiftlauncher/Utils/LauncherAssist.dart';

class Global {
  static final Set<AppInfo> recentApps = Set();
  static final Map<String, Uint8List> iconPack = Map();
  static bool isIconTextVis = true;

  static final List<String> iconIntents = [
    "com.fede.launcher.THEME_ICONPACK",
    "com.anddoes.launcher.THEME",
    "com.novalauncher.THEME",
    "com.teslacoilsw.launcher.THEME",
    "com.gau.go.launcherex.theme",
    "org.adw.launcher.THEMES",
  ];
}
