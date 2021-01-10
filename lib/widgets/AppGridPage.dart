import 'package:flutter/material.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';
import 'package:swiftlauncher/widgets/BaseDraggableApp.dart';

class AppGridPage extends StatelessWidget {
  final List<AppInfo> apps;
  final Function onDragStarted;
  const AppGridPage({Key key, @required this.apps, this.onDragStarted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemCount: apps.length,
      itemBuilder: (context, index) =>
          BaseDraggableApp(appInfo: apps[index], dragStarted: onDragStarted),
    );
  }
}
