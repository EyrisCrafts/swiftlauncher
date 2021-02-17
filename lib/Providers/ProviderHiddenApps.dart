import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';

class ProviderHiddenApps extends ChangeNotifier {
  List<String> hiddenApps;
  List<AppInfo> recentReAdd;

  ProviderHiddenApps(this.hiddenApps) {
    // log("HIDDEN APPS ARE IN PROVIDER ${hiddenApps.length}");
    recentReAdd = List();
  }

  setHiddenApps(List<String> loaded) {
    hiddenApps = loaded;
    notifyListeners();
  }

  List<AppInfo> get getRecentAdds => recentReAdd;

  List<String> get getHiddenApps => hiddenApps;

  addRecentApp(AppInfo recentapp) {
    recentReAdd.add(recentapp);
    notifyListeners();
  }

  removeRecentApp() {
    recentReAdd.clear();
  }

  addHiddenApp(String package) {
    hiddenApps.add(package);
    SharedPreferences.getInstance()
        .then((value) => value.setStringList('hiddenapps', hiddenApps));
    notifyListeners();
  }

  removeHiddenApp(String package) {
    hiddenApps.removeWhere((element) => element == package);
    SharedPreferences.getInstance()
        .then((value) => value.setStringList('hiddenapps', hiddenApps));
  }
}
