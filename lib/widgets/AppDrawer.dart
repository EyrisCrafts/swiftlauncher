import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
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
  double customHeight;
  bool animationEnded;
  int animationDuration;
  bool isOpen;
  PageController _pageController;
  int currentPageIndex;
  int numberOfPages;
  List<AppInfo> drawerApps;
  int draggingIndex;
  bool isDragMode;
  @override
  void initState() {
    super.initState();
    isDragMode = false;
    draggingIndex = 0;
    _pageController = PageController();
    currentPageIndex = 0;
    numberOfPages = widget.numberOfPages;
    isOpen = false;
    animationDuration = 0;
    animationEnded = true;
    customHeight = 0;
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
    setState(() {
      animationDuration = 100;
      customHeight = 0;
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
      setState(() {
        animationDuration = 100;
        customHeight = -size.height;
      });
    } else if (isOpen && (details.velocity.pixelsPerSecond.dy > 500)) {
      isOpen = false;
      animationEnded = true;
      setState(() {
        animationDuration = 100;
        customHeight = 0;
      });
    }
    if (hasChanged != isOpen) return;
    //Regular drag
    if (!isOpen) {
      if (-customHeight < (size.height / 2)) {
        animationEnded = true;
        setState(() {
          animationDuration = 100;
          customHeight = 0;
        });
      } else {
        isOpen = true;
        animationEnded = true;
        setState(() {
          customHeight = -size.height;
        });
      }
    } else {
      if (-customHeight < (size.height / 2)) {
        animationEnded = true;
        isOpen = false;
        setState(() {
          animationDuration = 100;
          customHeight = 0;
        });
      } else {
        animationEnded = true;
        setState(() {
          customHeight = -size.height;
        });
      }
    }
  }

  onVerticalDragUpdate(Size size, DragUpdateDetails details) {
    if (isOpen && (-details.delta.dy - customHeight > size.height)) return;
    if (animationEnded) {
      // animationEnded = false;
      setState(() {
        animationDuration = 0;
        customHeight += details.delta.dy;
      });
    } else {
      customHeight += details.delta.dy;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        AnimatedPositioned(
            duration: Duration(
              milliseconds: animationDuration,
            ),
            onEnd: () {
              animationDuration = 0;
              animationEnded = true;
            },
            left: 0,
            bottom: (-size.height - customHeight),
            child: ClipRRect(
              child: Container(
                width: size.width,
                height: size.height,
                color: Colors.transparent,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  // child: Text("hello"),
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
                                : Row(children: [
                                    Expanded(
                                        child: Material(
                                            color: Colors.transparent,
                                            child: Text("Page Name",
                                                style: TextStyle(
                                                    color: Colors.white)))),
                                    Material(
                                      color: Colors.transparent,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          //TODO If last page empty
                                          // widget
                                          // .pagesChange(widget.numberOfPages - 1);
                                        },
                                      ),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: IconButton(
                                        icon: Icon(Icons.add,
                                            color: Colors.white),
                                        onPressed: () {
                                          //Add
                                          setState(() {
                                            numberOfPages++;
                                            drawerApps.addAll(List.generate(
                                                20, (index) => null));
                                            log("added page");
                                          });
                                          // widget
                                          //     .pagesChange(widget.numberOfPages + 1);
                                        },
                                      ),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: IconButton(
                                        icon: Icon(Icons.settings,
                                            color: Colors.white),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SettingScreen()));
                                        },
                                      ),
                                    ),
                                  ])),
                      ),
                      Expanded(
                        child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (newIndex) {
                              log("current Page $newIndex");
                              setState(() {
                                currentPageIndex = newIndex;
                              });
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
                                    int actualIndex = (pageIndex * 20) + index;
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
                                    int actualIndex = (pageIndex * 20) + index;
                                    log("accepted at index $actualIndex }");
                                    if (drawerApps[actualIndex] == null) {
                                      log("swapping places $draggingIndex and $actualIndex");
                                      swapPlaces(draggingIndex, actualIndex);
                                      setState(() {});
                                    }
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
                                  child: DragTarget<AppInfo>(
                                    onWillAccept: (app) {
                                      if (_pageController.page.toInt() != i)
                                        _pageController.animateToPage(i,
                                            duration:
                                                Duration(milliseconds: 300),
                                            curve: Curves.easeIn);
                                      return true;
                                    },
                                    builder: (context, candidates, rejects) {
                                      return Icon(
                                          currentPageIndex == i
                                              ? Icons.crop_free
                                              : Icons.crop_square,
                                          color: Colors.white);
                                    },
                                  ),
                                )
                            ],
                          ))
                    ],
                  ),
                ),
              ),
            ))
      ],
    );
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
