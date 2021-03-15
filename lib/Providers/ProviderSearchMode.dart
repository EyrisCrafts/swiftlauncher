import 'package:flutter/cupertino.dart';

class ProviderSearchMode extends ChangeNotifier {
  bool isSearchMode;

  ProviderSearchMode() {
    isSearchMode = false;
  }

  get getIsSearchMode => isSearchMode;

  setIsSearchMode(bool val) {
    isSearchMode = val;
    notifyListeners();
  }
}
