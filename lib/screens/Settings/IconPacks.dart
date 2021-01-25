import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:swiftlauncher/Global.dart';
import 'package:swiftlauncher/Models/IconPack.dart';
import 'package:swiftlauncher/Providers/ProviderIconPack.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';
import 'package:swiftlauncher/screens/MainScreen.dart';

class IconPacks extends StatefulWidget {
  @override
  _IconPacksState createState() => _IconPacksState();
}

class _IconPacksState extends State<IconPacks> {
  Future<List<IconPack>> packs;
  int selected;
  Uint8List nIcon;
  @override
  void initState() {
    super.initState();
    //TODO Load from prefs
    selected = 0;
    log("loading packs");
    packs = LauncherAssist.getIconPacks();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Icon Packs"),
      ),
      body: FutureBuilder<List<IconPack>>(
          future: packs,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              log("loading packs ${snapshot.data.first.getPackageName}");
              return Container(
                height: size.height,
                width: size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Material(
                      child: InkWell(
                        onTap: () {
                          if (selected != 0) {
                            Global.iconPack.clear();
                            setState(() {
                              selected = 0;
                            });
                          }
                        },
                        child: ListTile(
                          title: Text("System"),
                          trailing: selected == 0 ? Icon(Icons.check) : null,
                        ),
                      ),
                    ),
                    for (int i = 0; i < snapshot.data.length; i++)
                      Material(
                        child: InkWell(
                          onTap: () async {
                            if (selected != i + 1) {
                              //TODO Add all the icons into iconpack

                              // Uint8List data = await LauncherAssist.loadIcon(
                              //   "com.whatsapp",
                              //   snapshot.data[i].getPackageName,
                              // );
                              // setState(() {
                              //   log("loaded the icon");
                              //   nIcon = data;
                              // });

                              LauncherAssist.loadIconPack(
                                      snapshot.data[i].getPackageName,
                                      allApps.map((e) => e.package).toList())
                                  .then((value) {
                                if (mounted) {
                                  Provider.of<ProviderIconPack>(context,
                                          listen: false)
                                      .setIconPack(value);

                                  setState(() {
                                    selected = i + 1;
                                  });
                                }
                              });
                            }
                          },
                          child: ListTile(
                            title: Text(snapshot.data[i].getName),
                            trailing:
                                selected == i + 1 ? Icon(Icons.check) : null,
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
