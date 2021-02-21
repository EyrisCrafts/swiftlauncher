import 'dart:ui';

import 'package:flutter/material.dart';

class DialogLongPress extends StatelessWidget {
  final Function onHomeScreenChange;
  final Function onLockScreenChange;

  const DialogLongPress(
      {Key key, this.onHomeScreenChange, this.onLockScreenChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: 100,
          child: Column(
            children: [
              InkWell(
                onTap: onHomeScreenChange,
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
                        child: Text("Set HomeScreen",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ),
              // SizedBox(
              //   height: 17,
              // ),
              // InkWell(
              //   onTap: onLockScreenChange,
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(10),
              //     child: Container(
              //       height: 40,
              //       width: 200,
              //       child: BackdropFilter(
              //         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              //         child: Container(
              //           height: 40,
              //           alignment: Alignment.center,
              //           width: 100,
              //           color: Colors.white.withOpacity(0.4),
              //           child: Text("Set Lockscreen",
              //               style: TextStyle(
              //                   color: Colors.white,
              //                   fontWeight: FontWeight.bold)),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
