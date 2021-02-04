import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as IMG;
import 'package:path_provider/path_provider.dart';
import 'package:swiftlauncher/Interfaces/DrawerSync.dart';
import 'package:swiftlauncher/Providers/ProviderSettings.dart';
import 'package:swiftlauncher/widgets/AppGridPage.dart';
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
import 'package:hardware_buttons/hardware_buttons.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

List<AppInfo> allApps;
Map<String, Uint8List> iconPack;
Directory dr;

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
  Future<int> initialization;
  int currentPageIndex;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    currentPageIndex = 0;

    iconPack = Map();
    draggingFromDrawer = false;
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    drawerKey = GlobalKey<AppDrawerState>();
    filteredApps = List();
    isRemoveAppVis = false;
    _pageController = PageController();
    allApps = List();
    mainApps = List();
    draggingAppIndex = -1;
    setupWallpaper();
    numberOfPages = 0;
    drawerApps = List();
    isSearchMode = false;
    initialization = initializeApps();
    LauncherAssist.initAppsChangeListener();
    homeButtonEvents.listen((event) {
      if (isSearchMode) {
        log("closing search mode");
        setState(() {
          filteredApps.clear();
          isSearchMode = false;
          _searchController.clear();
          FocusScope.of(context).unfocus();
        });
      }
    });
    LauncherAssist.handlesCREENChanges().listen((event) {
      //Screen just closed
      log("SCREEN JUST CLOSED");
      if (isSearchMode) {
        log("closing search mode");
        setState(() {
          filteredApps.clear();
          isSearchMode = false;
          _searchController.clear();
          FocusScope.of(context).unfocus();
        });
      }
      if (drawerKey.currentState.mounted) {
        drawerKey.currentState.closeDrawer();
      }
    });

    LauncherAssist.newAppListener().listen((pkg) {
      // Added or removed app !!!
      String type = pkg.toString()[0];
      String pkgname = pkg.toString().substring(1);
      if (type == "R") {
        log("App Removed");
        //Replace with empty from drawer apps, mainApps, allApps and appdrawer drawerapps
        setState(() {
          for (int i = 0; i < drawerApps.length; i++) {
            if (drawerApps[i] != null && drawerApps[i].package == pkgname) {
              drawerApps[i] = null;
            }
          }
          for (int i = 0; i < mainApps.length; i++) {
            if (mainApps[i] != null && mainApps[i].package == pkgname) {
              mainApps[i] = null;
            }
          }
          allApps.removeWhere((element) => element.package == pkgname);
          drawerKey.currentState.removeApp(pkgname);
        });
      } else if (type == "A") {
        log("new App installed");
        drawerKey.currentState.addNewApp(pkgname);
      }
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
    // drawerKey.currentState.setDrawer(numberOfPages, drawerApps);

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

    int total = 52;
    int diff = total - mainApps.length;

    for (int i = 0; i < diff; i++) {
      mainApps.add(null);
    }

    setState(() {});
  }

  AppInfo findApp(String package) {
    for (AppInfo info in allApps) {
      if (info != null &&
          info.label.toLowerCase().contains(package.toLowerCase())) {
        log("found ${info.package}");
        return info;
      }
    }
    return null;
  }

  Uint8List resizeImage(Uint8List data) {
    Uint8List resizedData = data;
    IMG.Image img = IMG.decodeImage(data);
    IMG.Image resized = IMG.copyResize(img, width: 50, height: 50);
    resizedData = IMG.encodePng(resized);
    return resizedData;
  }

  Future<int> initializeApps() async {
    allApps = await LauncherAssist.getAllApps();
    // List<AppInfo> temp = await LauncherAssist.getAllApps();
    // allApps.addAll(temp.take(5));
    // allApps.addAll(List.generate(20, (index) => null));
    allApps.map((e) {
      e.icon = resizeImage(e.icon);
    });
    allApps.forEach((element) {
      precacheImage(MemoryImage(element.icon), context);
    });
    // dr = await getTemporaryDirectory();
    // File(dr.path + "/aa").writeAsBytes(temp.first.icon, flush: true);
    // log("File ${await File(dr.path + "/aa").exists()}");
    loadDrawerSettings();
    initializeMainApps();
    return 2;
  }

  setupIconInFile() async {}

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
    log("building mainscreen");
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
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
        if (drawerKey.currentState.mounted) {
          drawerKey.currentState.closeDrawer();
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
          child: FutureBuilder<int>(
              future: initialization,
              builder: (context, snapshot) {
                if (snapshot == null || !snapshot.hasData) return Container();
                return AppDrawer(
                  draggingApp: (index) {
                    draggingFromDrawer = true;
                    draggingAppIndex = index;
                  },
                  numberOfPages: numberOfPages,
                  apps: drawerApps,
                  key: drawerKey,
                  syncApps: (List<AppInfo> aps) {
                    log("drawers length ${aps.length} original length ${drawerApps.length}");

                    this.drawerApps = aps;
                  },
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
                                  Opacity(
                                    opacity: isRemoveAppVis ? 1 : 0,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.4),
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
                                                      Navigator.pop(context);
                                                      LauncherAssist.launchAppSetting(
                                                          draggingFromDrawer
                                                              ? drawerApps[
                                                                  draggingAppIndex]
                                                              : mainApps[
                                                                  draggingAppIndex]);
                                                    }, onRemoveIcon: () {
                                                      Navigator.pop(context);
                                                      if (!draggingFromDrawer)
                                                        setState(() {
                                                          mainApps.removeAt(
                                                              draggingAppIndex);
                                                          mainApps.insert(
                                                              draggingAppIndex,
                                                              null);
                                                        });
                                                    }, onAppUninstall: () {
                                                      Navigator.pop(context);
                                                      LauncherAssist.uninstallApp(
                                                          draggingFromDrawer
                                                              ? drawerApps[
                                                                      draggingAppIndex]
                                                                  .package
                                                              : mainApps[
                                                                      draggingAppIndex]
                                                                  .package);
                                                    }));
                                          },
                                          builder:
                                              (context, candidates, rejs) =>
                                                  Icon(
                                                    Icons.settings,
                                                    color: Colors.white,
                                                  )),
                                    ),
                                  ),
                                  Consumer<ProviderSettings>(
                                    builder: (context, value, child) =>
                                        value.getSearchPosition ==
                                                SearchPosition.TOP
                                            ? buildSearchBar(size, true)
                                            : Container(),
                                  ),
                                  Container(
                                    height: size.height - 50 - 240,
                                    margin: EdgeInsets.only(top: 40),
                                    width: size.width,
                                    child: PageView.builder(
                                        controller: _pageController,
                                        onPageChanged: (newIndex) {
                                          log("current Page $newIndex");
                                          setState(() {
                                            currentPageIndex = newIndex;
                                          });
                                        },
                                        itemCount: 3,
                                        itemBuilder: (context, pageIndex) =>
                                            Consumer<ProviderSettings>(
                                              builder:
                                                  (context, value, child) =>
                                                      AppGridPage(
                                                apps: mainApps
                                                    .getRange(
                                                        (pageIndex * 16) + 4,
                                                        ((pageIndex + 1) * 16) +
                                                            4)
                                                    .toList(),
                                                onDragStarted: (int index) {
                                                  int actualIndex =
                                                      (pageIndex * 16) +
                                                          index +
                                                          4;

                                                  if (draggingFromDrawer)
                                                    draggingFromDrawer = false;
                                                  setState(() {
                                                    isRemoveAppVis = true;
                                                  });
                                                  draggingAppIndex =
                                                      actualIndex;
                                                  log("Started Drag from $draggingAppIndex");
                                                },
                                                onDragEnded: (int index) {
                                                  setState(() {
                                                    isRemoveAppVis = false;
                                                  });
                                                },
                                                onAccepted:
                                                    (int index, AppInfo app) {
                                                  int actualIndex =
                                                      (pageIndex * 16) +
                                                          index +
                                                          4;

                                                  log("lookng for acceptance. total size, ${drawerApps.length}");
                                                  if (draggingFromDrawer) {
                                                    log("dragged from drawer");
                                                  }
                                                  if (drawerApps[
                                                          draggingAppIndex] !=
                                                      null) {
                                                    log("not null in drawer list");
                                                  }
                                                  if (mainApps[actualIndex] ==
                                                          null &&
                                                      !draggingFromDrawer) {
                                                    swapPlaces(draggingAppIndex,
                                                        actualIndex);
                                                    setState(() {});
                                                  } else if (mainApps[
                                                              actualIndex] ==
                                                          null &&
                                                      draggingFromDrawer &&
                                                      drawerApps[
                                                              draggingAppIndex] !=
                                                          null) {
                                                    //coming from drawer
                                                    //TODO Update the drawer apps list arrangement
                                                    setState(() {
                                                      mainApps[actualIndex] =
                                                          app;
                                                    });
                                                  }
                                                },
                                                isSubTitle:
                                                    value.getHomeGridText,
                                              ),
                                            )),
                                  ),
                                  Consumer<ProviderSettings>(
                                    builder: (context, value, child) =>
                                        Container(
                                      height: (160 -
                                              (value.getSearchPosition ==
                                                      SearchPosition.TOP
                                                  ? 80
                                                  : 0))
                                          .toDouble(),
                                      width: size.width,
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          if (value.getSearchPosition ==
                                              SearchPosition.BOTTOM)
                                            buildSearchBar(size, false),
                                          buildMainApps(),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Consumer<ProviderSettings>(
                          builder: (context, value, child) {
                        if (value.getIsSearchEnable)
                          return buildSearchOverlay(
                              size, context, value.getSearchPosition);
                        return Container();
                      })
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  Container buildMainApps() {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
              4,
              (index) => Consumer<ProviderSettings>(
                    builder: (context, value, child) => DraggableApp(
                      mainApps[index],
                      (app) {
                        // if empty place
                        if (mainApps[index] == null && !draggingFromDrawer) {
                          swapPlaces(draggingAppIndex, index);
                          setState(() {});
                        } else if (mainApps[index] == null &&
                            draggingFromDrawer &&
                            drawerApps[draggingAppIndex] != null) {
                          //coming from drawer
                          setState(() {
                            mainApps[index] = app;
                          });
                        }
                      },
                      () {
                        // Drag started
                        if (draggingFromDrawer) draggingFromDrawer = false;
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
                      isSubTitle: value.getMainAppsText,
                    ),
                  ))),
    );
  }

  Container buildSearchBar(Size size, bool isTop) {
    return Container(
        height: 80,
        //TODO Change to bottom center
        alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
        child: Consumer<ProviderSettings>(builder: (context, value, child) {
          if (value.getIsSearchEnable) {
            return GestureDetector(
              onTap: () {
                filteredApps.addAll(Global.recentApps);
                _searchFocus.requestFocus();
                setState(() {
                  isSearchMode = true;
                });
              },
              child: Container(
                height: 40,
                width: size.width - (isSearchMode ? 20 : 70),
                padding: EdgeInsets.only(right: 15),
                margin:
                    EdgeInsets.symmetric(horizontal: (isSearchMode ? 10 : 35)),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(30)),
              ),
            );
          }
          return Container();
        }));
  }

  IgnorePointer buildSearchOverlay(
      Size size, BuildContext context, SearchPosition pos) {
    return IgnorePointer(
      ignoring: !isSearchMode,
      child: Scaffold(
        resizeToAvoidBottomInset: pos == SearchPosition.BOTTOM,
        backgroundColor: Colors.transparent,
        body: BackdropFilter(
          filter: isSearchMode
              ? ImageFilter.blur(sigmaX: 4, sigmaY: 4)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            height: size.height - 100,
            child: Consumer<ProviderSettings>(
              builder: (context, value, child) => SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: value.getSearchPosition == SearchPosition.BOTTOM
                          ? 0
                          : null,
                      bottom: value.getSearchPosition == SearchPosition.BOTTOM
                          ? null
                          : -90,
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
                                    itemBuilder: (context, index) => AppIcon(
                                          app: filteredApps[index],
                                          onAppOpening: () {
                                            if (isSearchMode) {
                                              setState(() {
                                                filteredApps.clear();
                                                isSearchMode = false;
                                                _searchController.clear();
                                                FocusScope.of(context)
                                                    .unfocus();
                                              });
                                            }
                                          },
                                        )),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: value.getSearchPosition == SearchPosition.BOTTOM
                          ? 0
                          : null,
                      top: value.getSearchPosition == SearchPosition.BOTTOM
                          ? null
                          : 50,
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            width: size.width - (isSearchMode ? 20 : 70),
                            padding: EdgeInsets.only(right: 15),
                            margin: EdgeInsets.symmetric(
                                horizontal: (isSearchMode ? 10 : 35)),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(30)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    focusNode: _searchFocus,
                                    onFieldSubmitted: (String query) {
                                      if (query.length != 0) {
                                        LauncherAssist.searchGoogle(query);
                                      }
                                    },
                                    onChanged: (String query) {
                                      setState(() {
                                        filteredApps = allApps
                                            .where((element) => element.label
                                                .toLowerCase()
                                                .contains(query.toLowerCase()))
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
                                    textInputAction: TextInputAction.done,
                                    style: TextStyle(color: Colors.white),
                                    cursorColor: Colors.white,
                                    decoration: InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.white),
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
                                      if (_searchController.text.isNotEmpty) {
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
                                      if (_searchController.text.isNotEmpty) {
                                        if (allApps
                                            .where((element) => element.package
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
