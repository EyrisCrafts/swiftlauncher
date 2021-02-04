import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:swiftlauncher/Global.dart';
import 'package:swiftlauncher/Providers/AppThemeProvider.dart';
import 'package:swiftlauncher/Providers/ProviderIconPack.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';
import 'package:swiftlauncher/screens/MainScreen.dart';

class DraggableApp extends StatefulWidget {
  final AppInfo appInfo;
  final Function(AppInfo) onAccept;
  final Function() dragStarted;
  final Function() dragEnded;
  final bool isSubTitle;
  final Function onAppOpening;
  DraggableApp(this.appInfo, this.onAccept, this.dragStarted,
      {this.dragEnded, this.isSubTitle = true, this.onAppOpening});

  @override
  _DraggableAppState createState() => _DraggableAppState();
}

class _DraggableAppState extends State<DraggableApp> {
  bool isVis = true;

  @override
  Widget build(BuildContext context) {
    return DragTarget<AppInfo>(
      builder: (BuildContext context, List<AppInfo> candidateData,
          List<dynamic> rejectedData) {
        if (candidateData.length == 1 && widget.appInfo == null) {
          return Opacity(
            opacity: 0.4,
            child: Container(
                height: 40 + (widget.isSubTitle ? 15 : 0).toDouble(),
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 40,
                        width: 40,
                        child: Image.memory(
                          candidateData[0].icon,
                          height: 40,
                          width: 40,
                          cacheHeight: 40,
                          cacheWidth: 40,
                        )),
                    if (widget.isSubTitle)
                      Container(
                        height: 15,
                        width: 60,
                        margin: EdgeInsets.only(top: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: Text(candidateData[0].label,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: getTextStyle()),
                        ),
                      )
                  ],
                )),
          );
        }
        return widget.appInfo == null
            ? Container(
                height: 40,
                width: 60,
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
    // log("Building draggable");
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
        if (widget.onAppOpening != null) {
          widget.onAppOpening();
        }
        LauncherAssist.launchApp(widget.appInfo);

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
            width: 60,
          ),
          child: Container(
              height: 54 + (widget.isSubTitle ? 15 : 0).toDouble(),
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer<ProviderIconPack>(
                    builder: (context, value, child) => Container(
                        height: 50,
                        width: 50,

                        // child: CachedNetworkImage(
                        //   imageUrl: "http://via.placeholder.com/350x150",
                        //   placeholder: (context, url) =>
                        //       CircularProgressIndicator(),
                        //   errorWidget: (context, url, error) => Icon(Icons.error),
                        // ),
                        // child: Image.file(File(dr.path + "/aa")),

                        child: Image.memory(
                          value.getIcon(widget.appInfo.package) ??
                              widget.appInfo.icon,
                          width: 50,
                          height: 50,
                        )

                        // child: Icon(Icons.ac_unit),
                        ),
                  ),
                  if (widget.isSubTitle)
                    Container(
                      height: 15,
                      width: 60,
                      margin: EdgeInsets.only(top: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: Text(widget.appInfo.label,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: getTextStyle()),
                      ),
                    )
                ],
              )),
          feedback: Material(
            color: Colors.transparent,
            child: Container(
                height: 40 + (widget.isSubTitle ? 15 : 0).toDouble(),
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 40,
                        width: 40,
                        child: Image.memory(
                          widget.appInfo.icon,
                          width: 40,
                          height: 40,
                        )),
                    if (widget.isSubTitle)
                      Container(
                        height: 10,
                        width: 60,
                        margin: EdgeInsets.only(top: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: Text(widget.appInfo.label,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: getTextStyle()),
                        ),
                      )
                  ],
                )),
          ),
        ),
      ),
    );
  }

  TextStyle getTextStyle() {
    return TextStyle(color: Colors.white, fontSize: 11);
  }
}
