import 'package:flutter/material.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';
import 'package:swiftlauncher/screens/Settings/IconPacks.dart';

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
        title: Text("Swift Settings"),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            RaisedButton(
              child: Text("icon Packs"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => IconPacks()));
              },
            ),
            RaisedButton(
              child: Text("load whatsapp"),
              onPressed: () {
                LauncherAssist.loadIcon(
                    'com.natewren.flightlite', 'com.whatsapp');
              },
            )
          ],
        ),
      ),
    );
  }
}
