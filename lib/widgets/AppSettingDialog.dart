import 'dart:ui';

import 'package:flutter/material.dart';

class AppSettingDialog extends StatelessWidget {
  final Function() onAppSetting;
  final Function() onRemoveIcon;
  final Function() onIconSetting;

  const AppSettingDialog(
      {Key key, this.onAppSetting, this.onRemoveIcon, this.onIconSetting})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 180,
        child: Column(
          children: [
            InkWell(
              onTap: onAppSetting != null ? onAppSetting : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 40,
                  width: 200,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      width: 100,
                      color: Colors.white.withOpacity(0.4),
                      child: Text("App Setting",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 17,
            ),
            InkWell(
              onTap: onIconSetting != null ? onIconSetting : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 40,
                  width: 200,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      width: 100,
                      color: Colors.white.withOpacity(0.4),
                      child: Text("Icon Setting",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 17,
            ),
            InkWell(
              onTap: onRemoveIcon != null ? onRemoveIcon : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 40,
                  width: 200,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      width: 100,
                      color: Colors.white.withOpacity(0.4),
                      child: Text("Remove Icon",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
