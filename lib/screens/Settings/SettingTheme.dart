import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiftlauncher/Global.dart';
import 'package:swiftlauncher/Providers/ProviderSettings.dart';

class SettingTheme extends StatefulWidget {
  @override
  _SettingThemeState createState() => _SettingThemeState();
}

class _SettingThemeState extends State<SettingTheme> {
  int selectedTheme;

  @override
  void initState() {
    super.initState();
    selectedTheme =
        Provider.of<ProviderSettings>(context, listen: false).getIsDarkTheme
            ? 1
            : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Global.themeColor,
        title: Text("Theme"),
      ),
      body: Container(
        child: Column(
          children: [
            ListTile(
              onTap: () {
                if (selectedTheme != 0) {
                  Provider.of<ProviderSettings>(context, listen: false)
                      .setIsDarkTheme(false);
                  setState(() {
                    selectedTheme = 0;
                  });
                }
              },
              title: Text("Light"),
              trailing: selectedTheme == 0 ? Icon(Icons.check) : null,
            ),
            ListTile(
              onTap: () {
                if (selectedTheme != 1) {
                  Provider.of<ProviderSettings>(context, listen: false)
                      .setIsDarkTheme(true);
                  setState(() {
                    selectedTheme = 1;
                  });
                }
              },
              title: Text("Dark"),
              trailing: selectedTheme == 1 ? Icon(Icons.check) : null,
            ),
          ],
        ),
      ),
    );
  }
}
