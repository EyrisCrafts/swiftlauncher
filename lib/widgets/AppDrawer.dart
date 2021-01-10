import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';
import 'package:swiftlauncher/widgets/BaseDraggableApp.dart';
import 'package:swiftlauncher/widgets/CustomDrawer.dart';

import 'AppGridPage.dart';

class AppDrawer extends StatefulWidget {
  final Widget child;
  final List<AppInfo> apps;
  final int numberOfPages;
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
      this.numberOfPages})
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
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    currentPageIndex = 0;
    numberOfPages = widget.numberOfPages;
    isOpen = false;
    animationDuration = 0;
    animationEnded = true;
    customHeight = 0;
  }

  closeDrawer() {
    isOpen = false;
    setState(() {
      animationDuration = 100;
      customHeight = 0;
    });
  }

  onVerticalDragEnd(Size size, DragEndDetails details) {
    bool hasChanged = isOpen;
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
                            child: Row(children: [
                              Expanded(
                                  child: Material(
                                      color: Colors.transparent,
                                      child: Text("Page Name",
                                          style:
                                              TextStyle(color: Colors.white)))),
                              Material(
                                color: Colors.transparent,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    //TODO If last page empty
                                    widget
                                        .pagesChange(widget.numberOfPages - 1);
                                  },
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: IconButton(
                                  icon: Icon(Icons.add, color: Colors.white),
                                  onPressed: () {
                                    widget
                                        .pagesChange(widget.numberOfPages + 1);
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
                            itemCount: (widget.apps.length / 20).ceil(),
                            itemBuilder: (context, index) => AppGridPage(
                                  apps: widget.apps
                                      .getRange(
                                          index * 20,
                                          ((index + 1) * 20) >
                                                  widget.apps.length
                                              ? widget.apps.length - 1
                                              : ((index + 1) * 20))
                                      .toList(),
                                  onDragStarted: () {
                                    // closeDrawer();
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
                              for (int i = 0; i < widget.numberOfPages; i++)
                                if (currentPageIndex == i)
                                  Icon(Icons.crop_free, color: Colors.white)
                                else
                                  Icon(Icons.crop_square, color: Colors.white)
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
}
