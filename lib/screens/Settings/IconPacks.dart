import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:hardware_buttons/hardware_buttons.dart';
import 'package:swiftlauncher/Global.dart';
import 'package:swiftlauncher/Models/IconPack.dart';
import 'package:swiftlauncher/Providers/ProviderIconPack.dart';
import 'package:swiftlauncher/Providers/ProviderSettings.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';
import 'package:swiftlauncher/screens/MainScreen.dart';

class IconPacks extends StatefulWidget {
  @override
  _IconPacksState createState() => _IconPacksState();
}

class _IconPacksState extends State<IconPacks> {
  Future<List<IconPack>> packs;
  String selected;
  Uint8List nIcon;
  bool isLoading;

  @override
  void initState() {
    super.initState();
    selected =
        Provider.of<ProviderSettings>(context, listen: false).getIconPack;
    isLoading = false;
    packs = LauncherAssist.getIconPacks();
    homeButtonEvents.listen((event) {
      log("Home pressed");
      NavigatorState nav = Navigator.of(context);
      nav.pop();
      nav.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Icon Packs"),
        backgroundColor: Global.themeColor,
      ),
      body: FutureBuilder<List<IconPack>>(
          future: packs,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                height: size.height,
                width: size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isLoading) LinearProgressIndicator(),
                    Material(
                      child: InkWell(
                        onTap: () {
                          if (selected != "System") {
                            Provider.of<ProviderSettings>(context,
                                    listen: false)
                                .setIconPack("System");
                            Global.iconPack.clear();
                            setState(() {
                              selected = "System";
                            });
                          }
                        },
                        child: ListTile(
                          title: Text("System"),
                          trailing:
                              selected == "System" ? Icon(Icons.check) : null,
                        ),
                      ),
                    ),
                    for (int i = 0; i < snapshot.data.length; i++)
                      Material(
                        child: InkWell(
                          onTap: () async {
                            if (selected != snapshot.data[i].getName) {
                              Provider.of<ProviderSettings>(context,
                                      listen: false)
                                  .setIconPack(snapshot.data[i].getName);
                              //TODO Add all the icons into iconpack

                              // Uint8List data = await LauncherAssist.loadIcon(
                              //   "com.whatsapp",
                              //   snapshot.data[i].getPackageName,
                              // );
                              // setState(() {
                              //   log("loaded the icon");
                              //   nIcon = data;
                              // });
                              setState(() {
                                isLoading = true;
                              });
                              LauncherAssist.loadIconPack(
                                      snapshot.data[i].getPackageName,
                                      allApps.map((e) => e.package).toList())
                                  .then((value) {
                                if (mounted) {
                                  Provider.of<ProviderIconPack>(context,
                                          listen: false)
                                      .setIconPack(value,
                                          snapshot.data[i].getPackageName);

                                  setState(() {
                                    selected = snapshot.data[i].getName;
                                    isLoading = false;
                                  });
                                }
                              });
                            }
                          },
                          child: ListTile(
                            title: Text(snapshot.data[i].getName),
                            trailing: selected == snapshot.data[i].getName
                                ? Icon(Icons.check)
                                : null,
                          ),
                        ),
                      ),
                    nIcon != null ? Image.memory(nIcon) : Container()
                  ],
                ),
              );
            }
            return CircularProgressIndicator();
          }),
    );
  }
}
