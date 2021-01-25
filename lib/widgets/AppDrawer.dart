import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:hardware_buttons/hardware_buttons.dart';
import 'package:swiftlauncher/Providers/DrawerChangeProvider.dart';
import 'package:swiftlauncher/Providers/DrawerHeightProvider.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';
import 'package:swiftlauncher/screens/Settings/SettingScreen.dart';
import 'package:swiftlauncher/widgets/BaseDraggableApp.dart';
import 'package:swiftlauncher/widgets/CustomDrawer.dart';

import 'AppGridPage.dart';

class AppDrawer extends StatefulWidget {
  final Widget child;
  final List<AppInfo> apps;
  final int numberOfPages;
  final Function(int) draggingApp;
  final Function(DragEndDetails) onVerticalDragEnd;
  final Function(DragUpdateDetails) onVerticalDragUpdate;
  final Function(int numberOfPages) pagesChange;

  const AppDrawer(
      {Key key,
      this.child,
      this.onVerticalDragEnd,
      this.onVerticalDragUpdate,
      this.apps,
      this.pagesChange,
      this.numberOfPages,
      this.draggingApp})
      : super(key: key);

  @override
  AppDrawerState createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
  // double customHeight;
  bool animationEnded;
  // int animationDuration;
  bool isOpen;
  PageController _pageController;
  // int currentPageIndex;
  int numberOfPages;
  List<AppInfo> drawerApps;
  int draggingIndex;
  bool isDragMode;
  @override
  void initState() {
    super.initState();
    homeButtonEvents.listen((event) {
      log("Home pressed");
      if (isOpen) {
        isOpen = false;
        Provider.of<DrawerHeightProvider>(context, listen: false)
            .setUpdateHeight(0, 100);
      }
    });
    lockButtonEvents.listen((event) {
      log("phone locked");
    });

    isDragMode = false;
    draggingIndex = 0;
    _pageController = PageController();
    // currentPageIndex = 0;
    numberOfPages = widget.numberOfPages;
    isOpen = false;
    // animationDuration = 0;
    animationEnded = true;
    // customHeight = 0;
    drawerApps = List();
    drawerApps.addAll(widget.apps);
    log("number of apps ${numberOfPages}");
  }

  setDrawer(int number, List<AppInfo> drawerApps) {
    setState(() {
      numberOfPages = number;
      this.drawerApps = drawerApps;
    });
  }

  closeDrawer() {
    log("closing drawer");
    isOpen = false;
    Provider.of<DrawerHeightProvider>(context, listen: false)
        .setUpdateHeight(0, 100);
    // setState(() {
    //   animationDuration = 100;
    //   customHeight = 0;
    // });
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

      // setState(() {
      //   animationDuration = 100;
      //   customHeight = -size.height;
      // });
    } else if (isOpen && (details.velocity.pixelsPerSecond.dy > 500)) {
      isOpen = false;
      animationEnded = true;

      Provider.of<DrawerHeightProvider>(context, listen: false)
          .setUpdateHeight(0, 100);

      // setState(() {
      //   animationDuration = 100;
      //   customHeight = 0;
      // });
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

        // setState(() {
        //   animationDuration = 100;
        //   customHeight = 0;
        // });
      } else {
        isOpen = true;
        animationEnded = true;
        Provider.of<DrawerHeightProvider>(context, listen: false)
            .setUpdateHeightS(-size.height);
        // setState(() {
        //   customHeight = -size.height;
        // });
      }
    } else {
      if (-Provider.of<DrawerHeightProvider>(context, listen: false)
              .customHeight <
          (size.height / 2)) {
        animationEnded = true;
        isOpen = false;
        Provider.of<DrawerHeightProvider>(context, listen: false)
            .setUpdateHeight(0, 300);

        // setState(() {
        //   animationDuration = 100;
        //   customHeight = 0;
        // });
      } else {
        animationEnded = true;
        Provider.of<DrawerHeightProvider>(context, listen: false)
            .setUpdateHeightS(-size.height);

        // setState(() {
        //   customHeight = -size.height;
        // });
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
      // animationEnded = false;

      // Provider.of<DrawerHeightProvider>(context, listen: false)
      //     .setUpdateHeight(0, 100);

      Provider.of<DrawerHeightProvider>(context, listen: false)
          .setUpdateHeightRR(details.delta.dy, 0);

      // setState(() {
      //   animationDuration = 0;
      //   customHeight += details.delta.dy;
      // });
    } else {
      Provider.of<DrawerHeightProvider>(context, listen: false)
          .setUpdateHeightR(details.delta.dy);

      // customHeight += details.delta.dy;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        Consumer<DrawerHeightProvider>(
          builder: (context, value, child) => AnimatedPositioned(
              curve: Curves.easeOut,
              duration: Duration(
                milliseconds: value.animationDuration,
              ),
              onEnd: () {
                Provider.of<DrawerHeightProvider>(context, listen: false)
                    .setNewDuration();
                animationEnded = true;
              },
              left: 0,
              bottom: (-size.height - value.getCustomHeight),
              child: ClipRRect(
                child: Container(
                  width: size.width,
                  height: size.height,
                  color: Colors.black.withOpacity(0.7),
                  child: Container(
                    // filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      children: [
                        SafeArea(
                          child: Container(
                              height: 50,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              width: size.width,
                              child: isDragMode
                                  ? DragTarget<AppInfo>(onWillAccept: (app) {
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
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ));
                                    })
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                          // Expanded(child: Container()),
                                          // Material(
                                          //   color: Colors.transparent,
                                          //   child: IconButton(
                                          //     icon: Icon(
                                          //       Icons.remove,
                                          //       color: Colors.white,
                                          //     ),
                                          //     onPressed: () {
                                          //       //TODO If current page empty

                                          //       if (isPageEmpty()) {
                                          //         log("page is empty. Removing from ");
                                          //         //Remove the
                                          //         int pg =
                                          //             _pageController.page.toInt();
                                          //         setState(() {
                                          //           drawerApps.removeRange(
                                          //               pg * 20, (pg * 20) + 20);
                                          //           numberOfPages--;
                                          //         });
                                          //       }
                                          //       // widget
                                          //       // .pagesChange(widget.numberOfPages - 1);
                                          //     },
                                          //   ),
                                          // ),
                                          // Material(
                                          //   color: Colors.transparent,
                                          //   child: IconButton(
                                          //     icon: Icon(Icons.add,
                                          //         color: Colors.white),
                                          //     onPressed: () {
                                          //       //Add
                                          //       setState(() {
                                          //         numberOfPages++;
                                          //         drawerApps.addAll(List.generate(
                                          //             20, (index) => null));
                                          //         log("added page");
                                          //       });

                                          //     },
                                          //   ),
                                          // ),
                                          // Material(
                                          //   color: Colors.transparent,
                                          //   child: IconButton(
                                          //     icon: Icon(Icons.settings,
                                          //         color: Colors.white),
                                          //     onPressed: () {
                                          //       Navigator.push(
                                          //           context,
                                          //           MaterialPageRoute(
                                          //               builder: (context) =>
                                          //                   SettingScreen()));
                                          //     },
                                          //   ),
                                          // ),
                                          Container(
                                            height: 40,
                                            width: 40,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: PopupMenuButton(
                                                  icon: Icon(Icons.more_vert,
                                                      color: Colors.white),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  color: Colors.white,
                                                  onSelected: (int val) {
                                                    switch (val) {
                                                      case 1:
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        SettingScreen()));
                                                        break;
                                                      case 2:
                                                        setState(() {
                                                          numberOfPages++;
                                                          drawerApps.addAll(
                                                              List.generate(
                                                                  20,
                                                                  (index) =>
                                                                      null));
                                                          log("added page");
                                                        });
                                                        break;
                                                      case 3:
                                                        if (isPageEmpty()) {
                                                          log("page is empty. Removing from ");
                                                          //Remove the
                                                          int pg =
                                                              _pageController
                                                                  .page
                                                                  .toInt();
                                                          setState(() {
                                                            drawerApps
                                                                .removeRange(
                                                                    pg * 20,
                                                                    (pg * 20) +
                                                                        20);
                                                            numberOfPages--;
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
                                                                Icon(Icons
                                                                    .settings),
                                                                SizedBox(
                                                                    width: 10),
                                                                Text("Settings")
                                                              ],
                                                            )),
                                                        PopupMenuItem(
                                                            value: 2,
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.add),
                                                                SizedBox(
                                                                    width: 10),
                                                                Text("New Page")
                                                              ],
                                                            )),
                                                        PopupMenuItem(
                                                            value: 3,
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons
                                                                    .remove),
                                                                SizedBox(
                                                                    width: 10),
                                                                Text(
                                                                    "Remove Page")
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
                                Provider.of<DrawerChangeProvider>(context,
                                        listen: false)
                                    .setCurrentPage = newIndex;
                                // setState(() {
                                //   currentPageIndex = newIndex;
                                // });
                              },
                              itemCount: numberOfPages,
                              itemBuilder: (context, pageIndex) => AppGridPage(
                                    apps: drawerApps
                                        .getRange(
                                            pageIndex * 20,
                                            ((pageIndex + 1) * 20) >
                                                    drawerApps.length
                                                ? drawerApps.length - 1
                                                : ((pageIndex + 1) * 20))
                                        .toList(),
                                    onDragStarted: (int index) {
                                      int actualIndex =
                                          (pageIndex * 20) + index;
                                      widget.draggingApp(actualIndex);
                                      draggingIndex = actualIndex;
                                      setState(() {
                                        isDragMode = true;
                                      });

                                      //inform main that you are dragging from drawer
                                    },
                                    onDragEnded: (int index) {
                                      log("Drag ended");
                                      setState(() {
                                        isDragMode = false;
                                      });
                                    },
                                    onAccepted: (int index, AppInfo app) {
                                      int actualIndex =
                                          (pageIndex * 20) + index;
                                      log("accepted at index $actualIndex }");
                                      if (drawerApps[actualIndex] == null) {
                                        log("swapping places $draggingIndex and $actualIndex");
                                        swapPlaces(draggingIndex, actualIndex);
                                        setState(() {});
                                      }
                                    },
                                    onAppOpening: () {
                                      closeDrawer();
                                    },
                                  )),
                        ),
                        Container(
                            height: 50,
                            width: size.width,
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
                                      builder: (context, value, child) =>
                                          DragTarget<AppInfo>(
                                        onWillAccept: (app) {
                                          if (_pageController.page.toInt() != i)
                                            _pageController.animateToPage(i,
                                                duration:
                                                    Duration(milliseconds: 300),
                                                curve: Curves.easeIn);
                                          return true;
                                        },
                                        builder:
                                            (context, candidates, rejects) {
                                          return Icon(Icons.circle,
                                              color: value.getCurrentPage == i
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.4));
                                        },
                                      ),
                                    ),
                                  )
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
              )),
        )
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
