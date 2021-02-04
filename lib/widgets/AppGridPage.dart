import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';
import 'package:swiftlauncher/widgets/BaseDraggableApp.dart';
import 'package:swiftlauncher/widgets/DraggableApp.dart';

class AppGridPage extends StatelessWidget {
  final List<AppInfo> apps;
  final Function(int) onDragStarted;
  final Function(int) onDragEnded;
  final Function onAppOpening;
  final Function(int, AppInfo) onAccepted;
  final bool isSubTitle;

  const AppGridPage(
      {Key key,
      @required this.apps,
      this.onDragStarted,
      this.onDragEnded,
      this.onAccepted,
      this.onAppOpening,
      this.isSubTitle = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemCount: apps.length,
      itemBuilder: (context, index) => DraggableApp(
        apps[index],
        (appinfo) => onAccepted(index, appinfo),
        () => onDragStarted(index),
        dragEnded: () => onDragEnded(index),
        onAppOpening: onAppOpening,
        isSubTitle: isSubTitle,
      ),
    );
    // if (apps.length % 20 != 0) return Container();

    // return ListView.builder(
    //     itemCount: 5,
    //     physics: NeverScrollableScrollPhysics(),
    //     itemBuilder: (context, index) => Row(
    //           children: [
    //             DraggableApp(
    //               apps[index * 4],
    //               (appinfo) => onAccepted(index, appinfo),
    //               () => onDragStarted(index),
    //               dragEnded: () => onDragEnded(index),
    //               onAppOpening: onAppOpening,
    //               isSubTitle: isSubTitle,
    //             ),
    //             DraggableApp(
    //               apps[(index * 4) + 1],
    //               (appinfo) => onAccepted(index, appinfo),
    //               () => onDragStarted(index),
    //               dragEnded: () => onDragEnded(index),
    //               onAppOpening: onAppOpening,
    //               isSubTitle: isSubTitle,
    //             ),
    //             DraggableApp(
    //               apps[(index * 4) + 2],
    //               (appinfo) => onAccepted(index, appinfo),
    //               () => onDragStarted(index),
    //               dragEnded: () => onDragEnded(index),
    //               onAppOpening: onAppOpening,
    //               isSubTitle: isSubTitle,
    //             ),
    //             DraggableApp(
    //               apps[(index * 4) + 3],
    //               (appinfo) => onAccepted(index, appinfo),
    //               () => onDragStarted(index),
    //               dragEnded: () => onDragEnded(index),
    //               onAppOpening: onAppOpening,
    //               isSubTitle: isSubTitle,
    //             ),
    //           ],
    //         ));
  }
}
