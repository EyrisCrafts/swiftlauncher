import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:swiftlauncher/Global.dart';
import 'package:swiftlauncher/Providers/AppThemeProvider.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';

class DraggableApp extends StatefulWidget {
  final AppInfo appInfo;
  final Function(AppInfo) onAccept;
  final Function() dragStarted;
  final Function() dragEnded;
  DraggableApp(this.appInfo, this.onAccept, this.dragStarted, {this.dragEnded});

  @override
  _DraggableAppState createState() => _DraggableAppState();
}

class _DraggableAppState extends State<DraggableApp> {
  bool isVis = true;

  @override
  Widget build(BuildContext context) {
    log("contains ${Global.iconPack.length}");
    return DragTarget<AppInfo>(
      builder: (BuildContext context, List<AppInfo> candidateData,
          List<dynamic> rejectedData) {
        if (candidateData.length == 1 && widget.appInfo == null) {
          return Opacity(
            opacity: 0.4,
            child: Container(
                height: 40 + (Global.isIconTextVis ? 15 : 0).toDouble(),
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 40,
                        width: 40,
                        child: Image.memory(candidateData[0].icon)),
                    Container(
                      height: 15,
                      width: 60,
                      child: Material(
                        color: Colors.transparent,
                        child: Text(candidateData[0].label,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                )),
          );
        }
        return widget.appInfo == null
            ? Container(
                height: 40,
                width: 40,
              )
            : _buildDraggable();
        // : _buildDraggable();
      },
      onWillAccept: (AppInfo app) {
        // print('onWillAccept:$app');
        // onWillAccept(app);
        return true;
      },
      onAccept: (AppInfo app) {
        widget.onAccept(app);
        print('onAccept:$app');
      },
    );
  }

  _buildDraggable() {
    return GestureDetector(
      // onTap: () {
      // log("opening app");
      // LauncherAssist.launchApp(appInfo);
      // },
      onTapDown: (details) {
        log("tap down details");
        // if (!isVis)
        //   setState(() {
        //     isVis = true;
        //   });
      },
      onTapUp: (detials) {
        log("Opening app");
        // LauncherAssist.launchApp(appInfo);

        // if (isVis)
        //   setState(() {
        //     isVis = false;
        //   });
      },
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 400),
        opacity: isVis ? 1 : 0,
        child: LongPressDraggable(
          data: widget.appInfo,
          onDragStarted: () {
            widget.dragStarted();
          },
          onDraggableCanceled: (veloc, a) {
            if (widget.dragEnded != null) widget.dragEnded();
          },
          onDragCompleted: () {
            if (widget.dragEnded != null) widget.dragEnded();
          },
          onDragEnd: (details) {
            if (widget.dragEnded != null) widget.dragEnded();
          },
          childWhenDragging: Container(
            height: 40,
            width: 40,
          ),
          child: Container(
              height: 40 + (Global.isIconTextVis ? 15 : 0).toDouble(),
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: 40,
                      width: 40,
                      child: Image.memory(
                          Global.iconPack[widget.appInfo.package] ??
                              widget.appInfo.icon)),
                  Container(
                    height: 15,
                    width: 60,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(widget.appInfo.label,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              )),
          feedback: Material(
            color: Colors.transparent,
            child: Container(
                height: 40 + (Global.isIconTextVis ? 15 : 0).toDouble(),
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 40,
                        width: 40,
                        child: Image.memory(widget.appInfo.icon)),
                    Container(
                      height: 15,
                      width: 60,
                      child: Material(
                        color: Colors.transparent,
                        child: Text(widget.appInfo.label,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
