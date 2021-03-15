import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:provider/provider.dart';
import 'package:swiftlauncher/MyCopies/MyPageView.dart';
import 'package:swiftlauncher/MyCopies/MyScrollBehavior.dart';
import 'package:swiftlauncher/Providers/ProviderHiddenApps.dart';
import 'package:swiftlauncher/Providers/ProviderPageViewIssue.dart';
import 'package:swiftlauncher/Providers/ProviderSearchMode.dart';
import 'package:swiftlauncher/Providers/ProviderSettings.dart';
import 'package:swiftlauncher/screens/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:hardware_buttons/hardware_buttons.dart';
import 'package:swiftlauncher/Providers/DrawerChangeProvider.dart';
import 'package:swiftlauncher/Providers/DrawerHeightProvider.dart';
import 'package:swiftlauncher/Providers/ProviderIconPack.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';
import 'package:swiftlauncher/screens/Settings/SettingScreen.dart';

import '../Global.dart';
import 'AppGridPage.dart';
import 'AppSettingDialog.dart';

class AppDrawer extends StatefulWidget {
  final Widget child;
  final List<AppInfo> apps;
  final int numberOfPages;
  final Function(int) draggingApp;
  final Function(DragEndDetails) onVerticalDragEnd;
  final Function(DragUpdateDetails) onVerticalDragUpdate;
  final Function(int numberOfPages) pagesChange;
  final Function(List<AppInfo>) syncApps;
  // final Function(bool) isRemoveVis;

  const AppDrawer({
    Key key,
    this.child,
    this.onVerticalDragEnd,
    this.onVerticalDragUpdate,
    this.apps,
    this.pagesChange,
    this.numberOfPages,
    this.draggingApp,
    @required this.syncApps,
  }) : super(key: key);

  @override
  AppDrawerState createState() => AppDrawerState();
}

List<AppInfo> drawerApps;

class AppDrawerState extends State<AppDrawer> {
  // double customHeight;
  bool animationEnded;
  // int animationDuration;
  bool isOpen;
  PageController _pageController;
  // int currentPageIndex;
  int numberOfPages;
  int draggingIndex;
  bool isDragMode;
  PageController verticalPageController;

  @override
  void initState() {
    super.initState();
    verticalPageController = PageController(viewportFraction: 0.99);

    homeButtonEvents.listen((event) {
      log("Home pressed");
      if (isOpen) {
        isOpen = false;
        Provider.of<DrawerHeightProvider>(context, listen: false)
            .setUpdateHeight(0, 100);
      }
      verticalPageController.animateToPage(0,
          duration: Duration(milliseconds: 100), curve: Curves.linear);
    });
    // LauncherAssist.handlesCREENChanges().listen((event) {
    //   //Screen just closed
    //   if (isOpen) {
    //     isOpen = false;
    //     log("Closing screen");
    //     Provider.of<DrawerHeightProvider>(context, listen: false)
    //         .setUpdateHeight(0, 100);
    //     _verticalPageController.animateToPage(0,
    //         duration: Duration(milliseconds: 100), curve: Curves.linear);
    //   }
    // });

    isDragMode = false;
    draggingIndex = 0;
    _pageController = PageController(viewportFraction: 0.99);
    // currentPageIndex = 0;
    numberOfPages = widget.numberOfPages;
    isOpen = false;
    // animationDuration = 0;
    animationEnded = true;
    // customHeight = 0;
    drawerApps = [];
    drawerApps.addAll(widget.apps);
  }

  setDrawer(int number, List<AppInfo> mdrawerApps) {
    setState(() {
      numberOfPages = number;
      drawerApps = mdrawerApps;
    });
  }

  closeDrawer() {
    log("closing drawer");
    if (verticalPageController.page == 1.0) {
      isOpen = false;
      Provider.of<DrawerHeightProvider>(context, listen: false)
          .setUpdateHeight(0, 100);
      verticalPageController.jumpToPage(0);
    }
  }

  removeApp(String pkg) {
    for (int i = 0; i < drawerApps.length; i++) {
      if (drawerApps[i] != null && drawerApps[i].package == pkg) {
        drawerApps[i] = null;
      }
    }
  }

  addNewApp(String pkgName) async {
    //Get full app info
    AppInfo appInfo = await LauncherAssist.getAppInfo(pkgName);
    //Icon Pack
    if (Global.iconPack.length != 0) {
      Uint8List bitmap = await LauncherAssist.loadIcon(
          Provider.of<ProviderIconPack>(context, listen: false).getIconPackName,
          appInfo.package);
      Provider.of<ProviderIconPack>(context, listen: false)
          .addNewIcon(pkgName, bitmap);
    }
    //Add to next empty drawer
    for (int i = 0; i < drawerApps.length; i++) {
      if (drawerApps[i] == null) {
        //replace with new app
        drawerApps[i] = appInfo;
        widget.syncApps(drawerApps);

        break;
      }
    }
    setState(() {
      allApps.add(appInfo);
    });
  }

  onVerticalDragEnd(Size size, DragEndDetails details) {
    bool hasChanged = isOpen;
    if (!isOpen && (details.velocity.pixelsPerSecond.dy > 500)) {
      log("Velocity is ${details.velocity.pixelsPerSecond.dy}");
      LauncherAssist.openNotificationShader();
    }
    if (!isOpen && (-details.velocity.pixelsPerSecond.dy > 500)) {
      isOpen = true;
      animationEnded = true;

      Provider.of<DrawerHeightProvider>(context, listen: false)
          .setUpdateHeight(-size.height, 100);
    } else if (isOpen && (details.velocity.pixelsPerSecond.dy > 500)) {
      isOpen = false;
      animationEnded = true;

      Provider.of<DrawerHeightProvider>(context, listen: false)
          .setUpdateHeight(0, 100);
    }
    if (hasChanged != isOpen) return;
    //Regular drag
    if (!isOpen) {
      if (-Provider.of<DrawerHeightProvider>(context, listen: false)
              .getCustomHeight <
          (size.height / 2)) {
        animationEnded = true;
        Provider.of<DrawerHeightProvider>(context, listen: false)
            .setUpdateHeight(0, 300);
      } else {
        isOpen = true;
        animationEnded = true;
        Provider.of<DrawerHeightProvider>(context, listen: false)
            .setUpdateHeightS(-size.height);
      }
    } else {
      if (-Provider.of<DrawerHeightProvider>(context, listen: false)
              .customHeight <
          (size.height / 2)) {
        animationEnded = true;
        isOpen = false;
        Provider.of<DrawerHeightProvider>(context, listen: false)
            .setUpdateHeight(0, 300);
      } else {
        animationEnded = true;
        Provider.of<DrawerHeightProvider>(context, listen: false)
            .setUpdateHeightS(-size.height);
      }
    }
  }

  onVerticalDragUpdate(Size size, DragUpdateDetails details) {
    if (isOpen &&
        (-details.delta.dy -
                Provider.of<DrawerHeightProvider>(context, listen: false)
                    .customHeight >
            size.height)) return;
    if (animationEnded) {
      Provider.of<DrawerHeightProvider>(context, listen: false)
          .setUpdateHeightRR(details.delta.dy, 0);
    } else {
      Provider.of<DrawerHeightProvider>(context, listen: false)
          .setUpdateHeightR(details.delta.dy);
    }
  }

  @override
  Widget build(BuildContext context) {
    log("building Appdrawer");
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned.fill(child: widget.child),

        Consumer<ProviderPageViewIssue>(
          builder: (context, value, child) => GestureDetector(
            behavior: value.getIsDrawerOpen
                ? HitTestBehavior.opaque
                : HitTestBehavior.translucent,
            child: Container(),
          ),
        ),
        ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: Consumer<ProviderSearchMode>(
            builder: (context, value, child) => MyPageView(
              physics: value.getIsSearchMode
                  ? NeverScrollableScrollPhysics()
                  : AlwaysScrollableScrollPhysics(),
              controller: verticalPageController,
              onPageChanged: (int isPageChanged) {
                if (isPageChanged == 1) {
                  Provider.of<ProviderPageViewIssue>(context, listen: false)
                      .setIsDrawerOpen(true);
                } else {
                  Provider.of<ProviderPageViewIssue>(context, listen: false)
                      .setIsDrawerOpen(false);
                }
              },
              scrollDirection: Axis.vertical,
              children: [
                Container(),
                ClipRRect(
                    child: Container(
                  width: size.width,
                  height: size.height,
                  child: Consumer<ProviderSettings>(
                      builder: (context, value, child) {
                    if (value.getDrawerBackground == DrawerBackground.DARK) {
                      return Container(
                        // filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        color: Colors.black.withOpacity(0.7),
                        child: buildMainDrawer(size, context),
                      );
                    } else if (value.getDrawerBackground ==
                        DrawerBackground.LIGHT) {
                      return Container(
                        // filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        color: Colors.white.withOpacity(0.7),
                        child: buildMainDrawer(size, context),
                      );
                    } else {
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: buildMainDrawer(size, context),
                      );
                    }
                  }),
                )),
              ],
            ),
          ),
        )
        // Consumer<DrawerHeightProvider>(
        //   builder: (context, value, child) => AnimatedPositioned(
        //       curve: Curves.easeOut,
        //       duration: Duration(
        //         milliseconds: value.animationDuration,
        //       ),
        //       onEnd: () {
        //         Provider.of<DrawerHeightProvider>(context, listen: false)
        //             .setNewDuration();
        //         animationEnded = true;
        //       },
        //       left: 0,
        //       bottom: (-size.height - value.getCustomHeight),
        //       child: ClipRRect(
        //         child: Container(
        //           width: size.width,
        //           height: size.height,
        //           child: Consumer<ProviderSettings>(
        //               builder: (context, value, child) {
        //             if (value.getDrawerBackground == DrawerBackground.DARK) {
        //               return Container(
        //                 // filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        //                 color: Colors.black.withOpacity(0.7),
        //                 child: buildMainDrawer(size, context),
        //               );
        //             } else if (value.getDrawerBackground ==
        //                 DrawerBackground.LIGHT) {
        //               return Container(
        //                 // filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        //                 color: Colors.white.withOpacity(0.7),
        //                 child: buildMainDrawer(size, context),
        //               );
        //             } else {
        //               return BackdropFilter(
        //                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        //                 child: buildMainDrawer(size, context),
        //               );
        //             }
        //           }),
        //         ),
        //       )),
        // )
      ],
    );
  }

  Column buildMainDrawer(Size size, BuildContext context) {
    return Column(
      children: [
        SafeArea(
          child: Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: size.width,
              child: isDragMode
                  ? Row(
                      children: [
                        Expanded(
                          child: DragTarget<AppInfo>(onWillAccept: (app) {
                            log("closing drawer");
                            closeDrawer();
                            return true;
                          }, builder: (context, candidates, rejects) {
                            return Container(
                                width: size.width,
                                alignment: Alignment.center,
                                height: 50,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text("Close Drawer",
                                      style: TextStyle(color: Colors.white)),
                                ));
                          }),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10)),
                          alignment: Alignment.center,
                          child: DragTarget<AppInfo>(
                              onAccept: (data) {
                                showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AppSettingDialog(onAppSetting: () {
                                          Navigator.pop(context);

                                          log("index is ");
                                          LauncherAssist.launchAppSetting(
                                              drawerApps[draggingIndex]);
                                        }, onAppUninstall: () {
                                          Navigator.pop(context);
                                          //TODO Uninstall
                                          LauncherAssist.uninstallApp(
                                              drawerApps[draggingIndex]
                                                  .package);
                                        }));
                              },
                              builder: (context, candidates, rejs) => Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                  )),
                        ),
                      ],
                    )
                  : Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Container(
                        height: 40,
                        width: 40,
                        child: Material(
                          color: Colors.transparent,
                          child: PopupMenuButton(
                              icon: Icon(Icons.more_vert, color: Colors.white),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onSelected: (int val) {
                                switch (val) {
                                  case 1:
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SettingScreen()));
                                    break;
                                  case 2:
                                    setState(() {
                                      numberOfPages++;
                                      drawerApps.addAll(
                                          List.generate(20, (index) => null));
                                      widget.syncApps(drawerApps);
                                      log("added page");
                                    });
                                    break;
                                  case 3:
                                    if (isPageEmpty()) {
                                      log("page is empty. Removing from ");
                                      //Remove the
                                      int pg = _pageController.page.toInt();
                                      setState(() {
                                        drawerApps.removeRange(
                                            pg * 20, (pg * 20) + 20);
                                        numberOfPages--;
                                        widget.syncApps(drawerApps);
                                      });
                                    }
                                    break;
                                  default:
                                }
                              },
                              itemBuilder: (context) => [
                                    PopupMenuItem(
                                        value: 1,
                                        child: Row(
                                          children: [
                                            Icon(Icons.settings),
                                            SizedBox(width: 10),
                                            Text(
                                              "Settings",
                                            )
                                          ],
                                        )),
                                    PopupMenuItem(
                                        value: 2,
                                        child: Row(
                                          children: [
                                            Icon(Icons.add),
                                            SizedBox(width: 10),
                                            Text("New Page")
                                          ],
                                        )),
                                    PopupMenuItem(
                                        value: 3,
                                        child: Row(
                                          children: [
                                            Icon(Icons.remove),
                                            SizedBox(width: 10),
                                            Text("Remove Page")
                                          ],
                                        ))
                                  ]),
                        ),
                      ),
                    ])),
        ),
        Expanded(
          child: PageView.builder(
              controller: _pageController,
              onPageChanged: (newIndex) {
                log("current Page $newIndex");
                Provider.of<DrawerChangeProvider>(context, listen: false)
                    .setCurrentPage = newIndex;
                // setState(() {
                //   currentPageIndex = newIndex;
                // });
              },
              itemCount: numberOfPages,
              itemBuilder: (context, pageIndex) => Consumer<ProviderHiddenApps>(
                      builder: (fcontext, hiddenprovider, fchild) {
                    log("rebuilding hidden apps");
                    //TODO 1. Set to null instead of removing
                    //TODO 2. In case the hidden is turned off, add to drawer app

                    // drawerApps.removeWhere((element) =>
                    //     element != null &&
                    //     hiddenprovider.getHiddenApps.contains(element.package));

                    for (int j = 0;
                        j < hiddenprovider.recentReAdd.length;
                        j++) {
                      for (int i = 0; i < drawerApps.length; i++) {
                        if (drawerApps[i] == null) {
                          drawerApps[i] = hiddenprovider.recentReAdd[j];

                          break;
                        }
                      }
                    }
                    Provider.of<ProviderHiddenApps>(context, listen: false)
                        .removeRecentApp();

                    for (int i = 0; i < drawerApps.length; i++) {
                      if (drawerApps[i] != null &&
                          hiddenprovider.getHiddenApps
                              .contains(drawerApps[i].package)) {
                        drawerApps[i] = null;
                        break;
                      }
                    }

                    return Consumer<ProviderSettings>(
                      builder: (context, value, child) => AppGridPage(
                        apps: drawerApps
                            .getRange(
                                pageIndex * 20,
                                ((pageIndex + 1) * 20) > drawerApps.length
                                    ? drawerApps.length - 1
                                    : ((pageIndex + 1) * 20))
                            .toList(),
                        onDragStarted: (int index) {
                          int actualIndex = (pageIndex * 20) + index;
                          widget.draggingApp(actualIndex);
                          draggingIndex = actualIndex;
                          setState(() {
                            isDragMode = true;
                            // widget.isRemoveVis(true);
                          });

                          //inform main that you are dragging from drawer
                        },
                        onDragEnded: (int index) {
                          log("Drag ended");
                          setState(() {
                            isDragMode = false;
                            // widget.isRemoveVis(false);
                          });
                        },
                        onAccepted: (int index, AppInfo app) {
                          int actualIndex = (pageIndex * 20) + index;
                          log("accepted at index $actualIndex }");
                          if (drawerApps[actualIndex] == null) {
                            log("swapping places $draggingIndex and $actualIndex");
                            swapPlaces(draggingIndex, actualIndex);
                            widget.syncApps(drawerApps);
                            setState(() {});
                          }
                        },
                        onAppOpening: () {
                          closeDrawer();
                        },
                        isSubTitle: value.drawerAppTextVis,
                      ),
                    );
                  })),
        ),
        Container(
            height: 50,
            width: size.width,
            alignment: Alignment.topCenter,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < numberOfPages; i++)
                  GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(i,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    },
                    child: Consumer<DrawerChangeProvider>(
                      builder: (context, value, child) => DragTarget<AppInfo>(
                        onWillAccept: (app) {
                          if (_pageController.page.toInt() != i)
                            _pageController.animateToPage(i,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          return true;
                        },
                        builder: (context, candidates, rejects) {
                          return AnimatedContainer(
                            height: 25,
                            width: 25,
                            duration: Duration(milliseconds: 2000),
                            decoration: BoxDecoration(
                                color: value.getCurrentPage == i
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(30)),
                          );
                        },
                      ),
                    ),
                  )
              ],
            ))
      ],
    );
  }

  bool isPageEmpty() {
    int currentPage = _pageController.page.toInt();
    List<AppInfo> nlist = drawerApps
        .getRange(
            currentPage * 20,
            ((currentPage + 1) * 20) > drawerApps.length
                ? drawerApps.length - 1
                : ((currentPage + 1) * 20))
        .toList();
    return nlist
        .map((e) => e == null)
        .reduce((value, element) => value && element);
  }

  swapPlaces(int dragginIndex, int index) {
    List<AppInfo> newList = List();
    for (int i = 0; i < drawerApps.length; i++) {
      if (i == index)
        newList.add(drawerApps[dragginIndex]);
      else if (i == dragginIndex)
        newList.add(drawerApps[index]);
      else
        newList.add(drawerApps[i]);
    }
    drawerApps = newList;
  }
}
