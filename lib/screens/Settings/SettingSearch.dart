import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:swiftlauncher/Providers/ProviderSettings.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../Global.dart';

class SettingSearch extends StatefulWidget {
  @override
  _SettingSearchState createState() => _SettingSearchState();
}

class _SettingSearchState extends State<SettingSearch> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Swift Search"),
        backgroundColor: Global.themeColor,
      ),
      body: Consumer<ProviderSettings>(
        builder: (context, setting, child) => Column(
          children: [
            SwitchListTile(
                title: Text("Enabled"),
                value: setting.getIsSearchEnable,
                onChanged: (b) {
                  Provider.of<ProviderSettings>(context, listen: false)
                      .setIsSearchEnable(b);
                }),
            Consumer<ProviderSettings>(
                builder: (context, value, child) => ListTile(
                      onTap: () {
                        if (value.getSearchPosition == SearchPosition.TOP)
                          Provider.of<ProviderSettings>(context, listen: false)
                              .setSearchPosition(SearchPosition.BOTTOM);
                        else
                          Provider.of<ProviderSettings>(context, listen: false)
                              .setSearchPosition(SearchPosition.TOP);
                      },
                      title: Text("Position"),
                      trailing: Text(
                          value.getSearchPosition == SearchPosition.TOP
                              ? "Top"
                              : "Bottom"),
                    ))
          ],
        ),
      ),
    );
  }
}
