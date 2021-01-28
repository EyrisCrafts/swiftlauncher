import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:swiftlauncher/Providers/ProviderSettings.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../Global.dart';

class SettingDrawer extends StatefulWidget {
  @override
  _SettingDrawerState createState() => _SettingDrawerState();
}

class _SettingDrawerState extends State<SettingDrawer> {
  @override
  void initState() {
    super.initState();
    options = [
      DrawerBackground.LIGHT,
      DrawerBackground.BLUR,
      DrawerBackground.DARK,
    ];
  }

  List<DrawerBackground> options;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Drawer Settings"),
        backgroundColor: Global.themeColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Consumer<ProviderSettings>(
            builder: (context, val, child) => SwitchListTile(
                title: Text("App SubText"),
                value: val.drawerAppTextVis,
                onChanged: (b) {
                  Provider.of<ProviderSettings>(context, listen: false)
                      .setDrawerAppTextVis(b);
                }),
          ),
          SizedBox(
            height: 17,
          ),
          Container(
            width: size.width,
            padding: const EdgeInsets.only(left: 17),
            child: Text(
              "Background",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SizedBox(
            height: 17,
          ),
          Container(
            padding: const EdgeInsets.only(left: 17),
            alignment: Alignment.centerLeft,
            child: Consumer<ProviderSettings>(
              builder: (context, value, child) => ToggleSwitch(
                activeBgColor: Global.themeColor,
                initialLabelIndex:
                    getBackgroundIndex(value.getDrawerBackground),
                inactiveBgColor: Theme.of(context).primaryColor == Colors.black
                    ? Colors.grey[800]
                    : Colors.grey[350],
                labels: ['LIGHT', 'BLUR', 'DARK'],
                onToggle: (index) {
                  DrawerBackground bg = DrawerBackground.LIGHT;
                  if (index == 0) bg = DrawerBackground.LIGHT;
                  if (index == 1) bg = DrawerBackground.BLUR;
                  if (index == 2) bg = DrawerBackground.DARK;
                  log("Setting background $bg");
                  Provider.of<ProviderSettings>(context, listen: false)
                      .setDrawerBackground(bg);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  int getBackgroundIndex(DrawerBackground bg) {
    if (bg == DrawerBackground.LIGHT) return 0;
    if (bg == DrawerBackground.BLUR) return 1;
    return 2;
  }
}
