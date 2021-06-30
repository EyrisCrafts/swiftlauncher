import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiftlauncher/Global.dart';
import 'package:swiftlauncher/Providers/ProviderSettings.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';
import 'package:swiftlauncher/screens/Settings/IconPacks.dart';
import 'package:swiftlauncher/screens/Settings/SettingDrawer.dart';
import 'package:swiftlauncher/screens/Settings/SettingHome.dart';
import 'package:swiftlauncher/screens/Settings/SettingSearch.dart';

import 'SettingTheme.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Global.themeColor,
        title: Text("Swift Settings"),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingTheme()));
                },
                title: Text("Theme"),
                subtitle: Consumer<ProviderSettings>(
                  builder: (context, value, child) =>
                      Text(value.isDarkTheme ? "Dark" : "Light"),
                ),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => IconPacks()));
                },
                title: Text("Icon Packs"),
                subtitle: Consumer<ProviderSettings>(
                  builder: (context, value, child) => Text(value.getIconPack),
                ),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingDrawer()));
                },
                title: Text("Drawer Settings"),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingHome()));
                },
                title: Text("Home Screen"),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingSearch()));
                },
                title: Text("SwiftSearch"),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
