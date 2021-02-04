import 'package:flutter/cupertino.dart';

class ProviderPageViewIssue extends ChangeNotifier {
  bool isDrawerOpen;

  ProviderPageViewIssue() {
    isDrawerOpen = false;
  }
  get getIsDrawerOpen => isDrawerOpen;

  setIsDrawerOpen(bool isopen) {
    isDrawerOpen = isopen;
    notifyListeners();
  }
}
