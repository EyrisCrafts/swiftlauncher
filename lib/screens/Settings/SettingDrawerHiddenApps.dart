import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiftlauncher/Providers/ProviderHiddenApps.dart';

import '../../Global.dart';
import 'package:swiftlauncher/screens/MainScreen.dart';

class SettingDrawerHiddenApps extends StatefulWidget {
  @override
  _SettingDrawerHiddenAppsState createState() =>
      _SettingDrawerHiddenAppsState();
}

class _SettingDrawerHiddenAppsState extends State<SettingDrawerHiddenApps> {
  //Show all Apps, hidden => Remove from drawer

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Global.themeColor,
          title: Text("Hidden Apps"),
        ),
        body: Consumer<ProviderHiddenApps>(
          builder: (context, value, child) => ListView.builder(
              itemCount: allApps.length,
              itemBuilder: (context, index) => SwitchListTile(
                  title: Text(allApps[index].label),
                  secondary: Image.memory(
                    allApps[index].icon,
                    width: 40,
                    height: 40,
                  ),
                  value: value.getHiddenApps.contains(allApps[index].package),
                  onChanged: (val) {
                    if (val)
                      Provider.of<ProviderHiddenApps>(context, listen: false)
                          .addHiddenApp(allApps[index].package);
                    else
                      Provider.of<ProviderHiddenApps>(context, listen: false)
                          .removeHiddenApp(allApps[index].package);
                  })),
        ));
  }
}

class AppCheck {
  String package;
  bool isChecked;
  AppCheck(this.package, this.isChecked);
}
