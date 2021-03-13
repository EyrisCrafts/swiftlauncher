import 'package:shared_preferences/shared_preferences.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';

import '../Global.dart';

class ProviderPreferences {
  static void saveMainApps(List<AppInfo> mainApps) async {
    //Convert to string list
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'mainApps', mainApps.map((e) => e == null ? "" : e.package).toList());
    //Save the list
  }

  static Future<List<AppInfo>> loadMainApps(List<AppInfo> allApps) async {
    //Load the Packages String list
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('mainApps');
    if (list == null) {
      return List();
    }
    List<AppInfo> toReturn = List();
    //Convert to AppInfo list
    list.forEach((element) {
      if (element == "")
        toReturn.add(null);
      else
        for (int i = 0; i < allApps.length; i++) {
          if (allApps[i].package == element) {
            toReturn.add(allApps[i]);
            break;
          }
        }
    });
    return toReturn;
  }

  static void saveRecents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('recentApps',
        Global.recentApps.map((e) => e == null ? "" : e.package).toList());
    //Save the list
  }

  static Future<List<AppInfo>> loadRecentApps(List<AppInfo> allApps) async {
    //Load the Packages String list
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('recentApps');
    if (list == null) {
      return List();
    }
    List<AppInfo> toReturn = List();
    //Convert to AppInfo list
    list.forEach((element) {
      if (element == "")
        toReturn.add(null);
      else
        for (int i = 0; i < allApps.length; i++) {
          if (allApps[i].package == element) {
            toReturn.add(allApps[i]);
            break;
          }
        }
    });
    return toReturn;
  }
}
