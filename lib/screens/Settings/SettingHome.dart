import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiftlauncher/Global.dart';
import 'package:swiftlauncher/Providers/ProviderSettings.dart';

class SettingHome extends StatefulWidget {
  @override
  _SettingHomeState createState() => _SettingHomeState();
}

class _SettingHomeState extends State<SettingHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        backgroundColor: Global.themeColor,
      ),
      body: Column(
        children: [
          Consumer<ProviderSettings>(
            builder: (context, val, child) => SwitchListTile(
                title: Text("Main Apps Text"),
                subtitle: Text("Apps on the bottom"),
                value: val.getMainAppsText,
                onChanged: (b) {
                  Provider.of<ProviderSettings>(context, listen: false)
                      .setMainAppsText(b);
                }),
          ),
          Consumer<ProviderSettings>(
            builder: (context, val, child) => SwitchListTile(
                title: Text("Grid Apps Text"),
                subtitle: Text("Apps in the Grid"),
                value: val.getHomeGridText,
                onChanged: (b) {
                  Provider.of<ProviderSettings>(context, listen: false)
                      .setHomeGridText(b);
                }),
          ),
        ],
      ),
    );
  }
}
