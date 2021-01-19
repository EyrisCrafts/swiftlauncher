import 'dart:developer';

import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:swiftlauncher/Global.dart';
import 'package:swiftlauncher/Models/IconPack.dart';

class LauncherAssist {
  static const MethodChannel _channel = const MethodChannel('launcher_assist');

  /// Returns a list of apps installed on the user's device
  static Future<List<AppInfo>> getAllApps() async {
    List<dynamic> data =
        await _channel.invokeMethod<List<dynamic>>('getAllApps');
    List<Map<String, dynamic>> allApps = data
        .cast<Map<dynamic, dynamic>>()
        .map((data) => data.cast<String, dynamic>())
        .toList();
    List<AppInfo> toReturn = allApps
        .map<AppInfo>((Map<String, dynamic> data) => AppInfo.fromMap(data))
        .toList();
    toReturn.sort((app1, app2) {
      return app1.label.compareTo(app2.label);
    });
    return toReturn;
  }

  /// Launches an app using its package name
  static void launchApp(AppInfo packageName) {
    Global.recentApps.add(packageName);
    _channel.invokeMethod("launchApp", {"packageName": packageName.package});
  }

  static Future<List<IconPack>> getIconPacks() async {
    String str = await _channel.invokeMethod("getIconPacks", {});
    List<IconPack> packs = List();
    str.split('\n').forEach((element) {
      if (element.length != 0) {
        packs.add(IconPack(
            name: element.split(',')[0], packageName: element.split(',')[1]));
      }
    });
    return packs;
  }

  static Future<Uint8List> loadIcon(String iconpack, String iconPackage) async {
    Uint8List data = await _channel
        .invokeMethod("getIcon", {"pckg": iconPackage, "key": iconpack});
    return data;
  }

  static openNotificationShader() {
    _channel.invokeMethod("expand");
  }

  static Future<void> loadIconPack(
      String iconPackage, List<String> listOfApps) async {
    listOfApps.forEach((element) async {
      Uint8List data = await _channel
          .invokeMethod("getIcon", {"pckg": iconPackage, "key": element});
      if (data != null) Global.iconPack.addEntries([MapEntry(element, data)]);
    });
    return;
  }

  static void launchAppSetting(AppInfo packageName) {
    _channel.invokeMethod("openSetting", {"package": packageName.package});
  }

  static void searchGoogle(String query) {
    _channel.invokeMethod("searchGoogle", {"query": query});
  }

  static void searchPlaystore(String query) {
    _channel.invokeMethod("searchPlaystore", {"query": query});
  }

  static void searchYoutube(String query) {
    _channel.invokeMethod("searchYoutube", {"query": query});
  }

  static void searchYanced(String query) {
    _channel.invokeMethod("searchVanced", {"query": query});
  }

  /// Gets you the current wallpaper on the user's device. This method
  /// needs the READ_EXTERNAL_STORAGE permission on Android Oreo.
  static Future<Uint8List> getWallpaper() async {
    Uint8List data = await _channel.invokeMethod<Uint8List>('getWallpaper');
    return data;
  }
}

/// A representation of the app info
class AppInfo {
  /// Complete package name (ie: com.example.app)
  final String package;

  /// User readable app name
  final String label;

  /// App icon
  final Uint8List icon;

  AppInfo.fromMap(Map<String, dynamic> data)
      : package = data['package'],
        label = data['label'],
        icon = data['icon'];
}
