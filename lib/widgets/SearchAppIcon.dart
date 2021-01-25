import 'package:flutter/material.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    Key key,
    @required this.app,
    this.onAppOpening,
  }) : super(key: key);

  final AppInfo app;
  final Function onAppOpening;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onAppOpening != null) onAppOpening();
        LauncherAssist.launchApp(app);
      },
      child: Container(
          height: 65,
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 50, width: 50, child: Image.memory(app.icon)),
              Container(
                height: 15,
                width: 80,
                child: Text(app.label,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
              )
            ],
          )),
    );
  }
}
