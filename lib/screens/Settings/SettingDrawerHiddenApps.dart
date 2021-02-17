import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiftlauncher/Providers/ProviderHiddenApps.dart';
import 'package:swiftlauncher/widgets/AppDrawer.dart';
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
        builder: (context, hid, child) => ListView.builder(
            itemCount: allApps.length,
            itemBuilder: (context, index) => SwitchListTile(
                title: Text(allApps[index].label),
                secondary: Image.memory(
                  allApps[index].icon,
                  width: 40,
                  height: 40,
                ),
                value: hid.getHiddenApps.contains(allApps[index].package),
                // value: hiddenApps.contains(allApps[index].package),
                onChanged: (val) {
                  if (val) {
                    // setState(() {
                    //   hiddenApps.add(allApps[index].package);
                    //   //Remove from appdrawer
                    //   drawerApps.removeWhere((element) =>
                    //       element != null &&
                    //       element.package == allApps[index].package);
                    // });
                    Provider.of<ProviderHiddenApps>(context, listen: false)
                        .addHiddenApp(allApps[index].package);
                  } else {
                    Provider.of<ProviderHiddenApps>(context, listen: false)
                        .addRecentApp(allApps[index]);
                    // setState(() {
                    //   hiddenApps.removeWhere(
                    //       (element) => allApps[index].package == element);
                    //   //Remove from appdrawer
                    //   drawerApps.add(allApps[index]);
                    // });
                    Provider.of<ProviderHiddenApps>(context, listen: false)
                        .removeHiddenApp(allApps[index].package);
                  }
                })),
      ),
    );
  }
}

class AppCheck {
  String package;
  bool isChecked;
  AppCheck(this.package, this.isChecked);
}
