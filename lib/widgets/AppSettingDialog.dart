import 'dart:ui';

import 'package:flutter/material.dart';

class AppSettingDialog extends StatelessWidget {
  final Function() onAppSetting;
  final Function() onRemoveIcon;
  final Function() onIconSetting;
  final Function() onAppUninstall;

  const AppSettingDialog(
      {Key key,
      this.onAppSetting,
      this.onRemoveIcon,
      this.onIconSetting,
      this.onAppUninstall})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: 250,
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
              if (onRemoveIcon != null)
                SizedBox(
                  height: 17,
                ),
              if (onRemoveIcon != null)
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
              SizedBox(
                height: 17,
              ),
              InkWell(
                onTap: onAppUninstall != null ? onAppUninstall : null,
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
                        color: Colors.red.withOpacity(0.4),
                        child: Text("Uninstall App",
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
      ),
    );
  }
}
