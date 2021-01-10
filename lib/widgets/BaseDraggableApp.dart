import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:swiftlauncher/Global.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';

class BaseDraggableApp extends StatelessWidget {
  final AppInfo appInfo;
  final Function() dragStarted;
  final Function() dragEnded;

  const BaseDraggableApp(
      {Key key, this.appInfo, this.dragStarted, this.dragEnded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        LauncherAssist.launchApp(appInfo);
      },
      child: LongPressDraggable(
        data: appInfo,
        onDragStarted: () {
          dragStarted();
        },
        onDragCompleted: () {
          if (dragEnded != null) dragEnded();
        },
        onDragEnd: (details) {
          if (dragEnded != null) dragEnded();
        },
        childWhenDragging: Container(
          height: 40 + (Global.isIconTextVis ? 15 : 0).toDouble(),
          width: 60,
        ),
        child: Container(
            height: 40,
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 40, width: 40, child: Image.memory(appInfo.icon)),
                Container(
                  height: 15,
                  width: 60,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(appInfo.label,
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
                      height: 40, width: 40, child: Image.memory(appInfo.icon)),
                  Container(
                    height: 15,
                    width: 60,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(appInfo.label,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
