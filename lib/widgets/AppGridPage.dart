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
  const AppGridPage(
      {Key key,
      @required this.apps,
      this.onDragStarted,
      this.onDragEnded,
      this.onAccepted,
      this.onAppOpening})
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
      ),
      // BaseDraggableApp(appInfo: apps[index], dragStarted: onDragStarted),
    );
  }
}
