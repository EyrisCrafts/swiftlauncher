import 'package:flutter/cupertino.dart';

class DrawerChangeProvider extends ChangeNotifier {
  int currentPage;

  DrawerChangeProvider() {
    currentPage = 0;
  }

  get getCurrentPage => currentPage;

  set setCurrentPage(int page) {
    currentPage = page;
    notifyListeners();
  }
}
