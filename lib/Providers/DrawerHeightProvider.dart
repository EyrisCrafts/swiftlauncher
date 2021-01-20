import 'package:flutter/cupertino.dart';

class DrawerHeightProvider extends ChangeNotifier {
  double customHeight;
  int animationDuration;

  DrawerHeightProvider() {
    customHeight = 0;
    animationDuration = 0;
  }

  get getCustomHeight => customHeight;
  get getDuration => animationDuration;

  setUpdateHeight(double customHeight, int animationDuration) {
    this.customHeight = customHeight;
    this.animationDuration = animationDuration;
    notifyListeners();
  }

  setNewDuration() {
    this.animationDuration = 0;
  }

  setUpdateHeightS(double customHeight) {
    this.customHeight = customHeight;
    notifyListeners();
  }

  setUpdateHeightR(double newHeight) {
    this.customHeight += newHeight;
    notifyListeners();
  }

  setUpdateHeightRR(double newHeight, int duration) {
    this.customHeight += newHeight;
    this.animationDuration = duration;
    notifyListeners();
  }
}
