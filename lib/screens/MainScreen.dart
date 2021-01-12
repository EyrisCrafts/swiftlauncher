import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:swiftlauncher/widgets/SearchAppIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swiftlauncher/Global.dart';
import 'package:swiftlauncher/Utils.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';
import 'package:swiftlauncher/screens/SearchScreen.dart';
import 'package:swiftlauncher/widgets/AppDrawer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swiftlauncher/widgets/AppSettingDialog.dart';
import 'package:swiftlauncher/widgets/DraggableApp.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

List<AppInfo> allApps;
Map<String, Uint8List> iconPack;

class _MainScreenState extends State<MainScreen> {
  var wallpaper;
  bool isSearchMode;
  List<AppInfo> mainApps;
  List<AppInfo> filteredApps;
  int draggingAppIndex;
  bool isRemoveAppVis;
  GlobalKey<AppDrawerState> drawerKey;
  TextEditingController _searchController;
  FocusNode _searchFocus;
  int numberOfPages;
  List<AppInfo> drawerApps;
  bool draggingFromDrawer;
  @override
  void initState() {
    super.initState();
    iconPack = Map();
    draggingFromDrawer = false;
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    drawerKey = GlobalKey<AppDrawerState>();
    filteredApps = List();
    isRemoveAppVis = false;
    mainApps = List();
    draggingAppIndex = -1;
    setupWallpaper();
    numberOfPages = 0;
    drawerApps = List();
    isSearchMode = false;
    initializeApps().then((value) {
      log("apps loaded");
      loadDrawerSettings();
      initializeMainApps();
    });
  }

  loadDrawerSettings() {
    //TODO Load from prefs

    numberOfPages = (allApps.length / 20).ceil();
    drawerApps.addAll(allApps);
    int diff = (numberOfPages * 20) - drawerApps.length;
    for (int i = 0; i < diff; i++) {
      drawerApps.add(null);
    }
    drawerKey.currentState.setDrawer(numberOfPages, drawerApps);

    // for (int index = 0; index < numberOfPages; index++) {
    //   drawerApps.addAll(allApps
    //       .getRange(
    //           index * 20,
    //           ((index + 1) * 20) > allApps.length
    //               ? allApps.length - 1
    //               : ((index + 1) * 20))
    //       .toList());
    // }
    log("drawer apps ${drawerApps.length}");
  }

  initializeMainApps() {
    //TODO if nothing in prefs
    AppInfo app = findApp('contact');
    if (app != null) mainApps.add(app);
    app = findApp('messag');
    if (app != null) mainApps.add(app);

    app = findApp('camera');
    if (app != null) mainApps.add(app);

    app = findApp('calendar');
    if (app != null) mainApps.add(app);
    setState(() {});
  }

  AppInfo findApp(String package) {
    for (AppInfo info in allApps) {
      if (info.label.toLowerCase().contains(package.toLowerCase())) {
        log("found ${info.package}");
        return info;
      }
    }
    return null;
  }

  Future<void> initializeApps() async {
    allApps = await LauncherAssist.getAllApps();
  }

  setupWallpaper() async {
    if (await Permission.storage.request().isGranted) {
      LauncherAssist.getWallpaper().then((value) {
        log("loaded image");
        setState(() {
          wallpaper = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      //TODO Close the search on back press
      onWillPop: () {
        log("Back pressed");
        if (isSearchMode) {
          setState(() {
            filteredApps.clear();
            isSearchMode = false;
            _searchController.clear();
            FocusScope.of(context).unfocus();
          });
        }
        return Future.value(false);
      },
      child: Container(
        decoration: BoxDecoration(
            image: wallpaper != null
                ? DecorationImage(image: MemoryImage(wallpaper))
                : null),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragEnd: (details) {
            drawerKey.currentState.onVerticalDragEnd(size, details);
          },
          onVerticalDragUpdate: (details) {
            drawerKey.currentState.onVerticalDragUpdate(size, details);
          },
          onTap: () {
            log("clicked me");
            if (isSearchMode) {
              setState(() {
                filteredApps.clear();
                isSearchMode = false;
                _searchController.clear();
                FocusScope.of(context).unfocus();
              });
            }
          },
          child: AppDrawer(
            draggingApp: (index) {
              draggingFromDrawer = true;
              draggingAppIndex = index;
            },
            numberOfPages: numberOfPages,
            apps: allApps,
            key: drawerKey,
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: SafeArea(
                      child: Container(
                        height: size.height - 20,
                        width: size.width,
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Column(
                                      children: [
                                        SizedBox(height: 200),
                                        RaisedButton(
                                            onPressed: () {
                                              //TOTAL APPS
                                              log("app 3 is ${allApps[3].label} and 4 ${allApps[4].label}");
                                              allApps.sort((app1, app2) {
                                                return app1.label
                                                    .compareTo(app2.label);
                                              });
                                            },
                                            child: Text("click me"))
                                        // DraggableApp(
                                        //     mainApps[1], (app) {}, () {})
                                      ],
                                    ),
                                  ),
                                  if (isRemoveAppVis)
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.4),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        alignment: Alignment.center,
                                        child: DragTarget<AppInfo>(
                                            onAccept: (data) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AppSettingDialog(
                                                        onAppSetting: () {
                                                          LauncherAssist.launchAppSetting(
                                                              draggingFromDrawer
                                                                  ? drawerApps[
                                                                      draggingAppIndex]
                                                                  : mainApps[
                                                                      draggingAppIndex]);
                                                        },
                                                        onRemoveIcon: () {
                                                          Navigator.pop(
                                                              context);
                                                          if (!draggingFromDrawer)
                                                            setState(() {
                                                              mainApps.removeAt(
                                                                  draggingAppIndex);
                                                              mainApps.insert(
                                                                  draggingAppIndex,
                                                                  null);
                                                            });
                                                        },
                                                      ));
                                            },
                                            builder: (context, candidates,
                                                    rejs) =>
                                                Container(
                                                  height: 40,
                                                  width: 40,
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.all(10),
                                                  child: Icon(
                                                    Icons.settings,
                                                    color: Colors.white,
                                                  ),
                                                )),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              height: 160,
                              width: size.width,
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Container(
                                      height: 80,
                                      alignment: Alignment.center,
                                      child: GestureDetector(
                                        onTap: () {
                                          //
                                          filteredApps
                                              .addAll(Global.recentApps);
                                          _searchFocus.requestFocus();
                                          setState(() {
                                            isSearchMode = true;
                                          });
                                        },
                                        child: Container(
                                          height: 40,
                                          width: size.width -
                                              (isSearchMode ? 20 : 70),
                                          padding: EdgeInsets.only(right: 15),
                                          margin: EdgeInsets.symmetric(
                                              horizontal:
                                                  (isSearchMode ? 10 : 35)),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                        ),
                                      )),
                                  Container(
                                    height: 80,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: List.generate(
                                            mainApps.length,
                                            (index) => DraggableApp(
                                                  mainApps[index],
                                                  (app) {
                                                    // if empty place
                                                    if (mainApps[index] ==
                                                            null &&
                                                        !draggingFromDrawer) {
                                                      swapPlaces(
                                                          draggingAppIndex,
                                                          index);
                                                      setState(() {});
                                                    } else if (mainApps[
                                                                index] ==
                                                            null &&
                                                        draggingFromDrawer &&
                                                        drawerApps[
                                                                draggingAppIndex] !=
                                                            null) {
                                                      //coming from drawer
                                                      //TODO Update the drawer apps list arrangement
                                                      setState(() {
                                                        mainApps[index] = app;
                                                      });
                                                    }
                                                  },
                                                  () {
                                                    // Drag started
                                                    //TODO cross visible
                                                    if (draggingFromDrawer)
                                                      draggingFromDrawer =
                                                          false;
                                                    setState(() {
                                                      isRemoveAppVis = true;
                                                    });
                                                    draggingAppIndex = index;
                                                  },
                                                  dragEnded: () {
                                                    setState(() {
                                                      isRemoveAppVis = false;
                                                    });
                                                    // draggingAppIndex = -1;
                                                  },
                                                ))),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  ignoring: !isSearchMode,
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: BackdropFilter(
                      filter: isSearchMode
                          ? ImageFilter.blur(sigmaX: 4, sigmaY: 4)
                          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Container(
                        height: size.height - 100,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Opacity(
                                opacity: isSearchMode ? 1 : 0,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    log("stack above clicked");
                                    setState(() {
                                      filteredApps.clear();
                                      isSearchMode = false;
                                      _searchController.clear();
                                      FocusScope.of(context).unfocus();
                                    });
                                  },
                                  child: Container(
                                    height: size.height - 150,
                                    width: !isSearchMode ? 1 : size.width,
                                    child: !isSearchMode
                                        ? Container()
                                        : GridView.builder(
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4),
                                            itemCount: filteredApps.length,
                                            itemBuilder: (context, index) =>
                                                AppIcon(
                                                  app: filteredApps[index],
                                                )),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              bottom: 0,
                              child: Column(
                                children: [
                                  Container(
                                    height: 40,
                                    width:
                                        size.width - (isSearchMode ? 20 : 70),
                                    padding: EdgeInsets.only(right: 15),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: (isSearchMode ? 10 : 35)),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.4),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            focusNode: _searchFocus,
                                            onFieldSubmitted: (String query) {
                                              if (query.length != 0) {
                                                LauncherAssist.searchGoogle(
                                                    query);
                                              }
                                            },
                                            onChanged: (String query) {
                                              setState(() {
                                                filteredApps = allApps
                                                    .where((element) => element
                                                        .label
                                                        .toLowerCase()
                                                        .contains(query
                                                            .toLowerCase()))
                                                    .toList();
                                              });
                                            },
                                            controller: _searchController,
                                            onTap: () {
                                              log("going to search Mode");
                                              // setState(() {
                                              //   isSearchMode = true;
                                              // });
                                            },
                                            textInputAction:
                                                TextInputAction.done,
                                            style:
                                                TextStyle(color: Colors.white),
                                            cursorColor: Colors.white,
                                            decoration: InputDecoration(
                                                hintStyle: TextStyle(
                                                    color: Colors.white),
                                                prefixIcon: Icon(
                                                  Icons.search,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                                focusColor: Colors.white,
                                                hintText: "Search",
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                border: InputBorder.none),
                                          ),
                                        ),
                                        Opacity(
                                          opacity: isSearchMode ? 1 : 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              //TODO Impleent search on google play
                                              if (_searchController
                                                  .text.isNotEmpty) {
                                                LauncherAssist.searchPlaystore(
                                                    _searchController.text);
                                              }
                                            },
                                            child: SvgPicture.asset(
                                              'assets/google-play.svg',
                                              height: 18,
                                              width: 18,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Opacity(
                                          opacity: isSearchMode ? 1 : 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              //TODO Impleent search on youtube/vanced
                                              log("Searching on youtube");
                                              if (_searchController
                                                  .text.isNotEmpty) {
                                                if (allApps
                                                    .where((element) => element
                                                        .package
                                                        .contains('vanced'))
                                                    .isNotEmpty) {
                                                  LauncherAssist.searchYanced(
                                                      _searchController.text);
                                                } else {
                                                  LauncherAssist.searchYoutube(
                                                      _searchController.text);
                                                }
                                              }
                                            },
                                            child: SvgPicture.asset(
                                              'assets/youtube.svg',
                                              height: 18,
                                              width: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  swapPlaces(int dragginIndex, int index) {
    List<AppInfo> newList = List();
    for (int i = 0; i < mainApps.length; i++) {
      if (i == index)
        newList.add(mainApps[dragginIndex]);
      else if (i == dragginIndex)
        newList.add(mainApps[index]);
      else
        newList.add(mainApps[i]);
    }
    mainApps = newList;
  }
}
