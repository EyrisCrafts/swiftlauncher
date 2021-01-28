import 'package:flutter/cupertino.dart';

enum DrawerBackground { DARK, LIGHT, BLUR }
enum SearchPosition { TOP, BOTTOM }

class ProviderSettings extends ChangeNotifier {
  bool homeScreenAppText;
  bool isDarkTheme;
  String iconPack;
  bool drawerAppTextVis;
  DrawerBackground _drawerBackground;
  bool mainAppsText;
  bool homeGridText;
  bool isSearchEnable;
  SearchPosition _searchPosition;

  SearchPosition get getSearchPosition => _searchPosition;

  setSearchPosition(SearchPosition searchPosition) {
    _searchPosition = searchPosition;
    notifyListeners();
  }

  bool get getIsSearchEnable => isSearchEnable;

  setIsSearchEnable(bool isSearchEnable) {
    this.isSearchEnable = isSearchEnable;
    notifyListeners();
  }

  bool get getMainAppsText => mainAppsText;

  setMainAppsText(bool mainAppsText) {
    this.mainAppsText = mainAppsText;
    notifyListeners();
  }

  bool get getHomeGridText => homeGridText;

  setHomeGridText(bool homeGridText) {
    this.homeGridText = homeGridText;
    notifyListeners();
  }

  DrawerBackground get getDrawerBackground => _drawerBackground;

  setDrawerBackground(DrawerBackground background) {
    _drawerBackground = background;
    notifyListeners();
  }

  bool get getDrawerAppTextVis => drawerAppTextVis;

  setDrawerAppTextVis(bool drawerAppTextVis) {
    this.drawerAppTextVis = drawerAppTextVis;
    notifyListeners();
  }

  ProviderSettings() {
    isDarkTheme = false;
    iconPack = "System";
    drawerAppTextVis = true;
    mainAppsText = false;
    homeGridText = true;
    isSearchEnable = true;
    _searchPosition = SearchPosition.BOTTOM;
    _drawerBackground = DrawerBackground.BLUR;
  }

  bool get getHomeScreenAppText => homeScreenAppText;

  setHomeScreenAppText(bool homeScreenAppText) =>
      this.homeScreenAppText = homeScreenAppText;

  bool get getIsDarkTheme => isDarkTheme;

  setIsDarkTheme(bool isDarkTheme) {
    this.isDarkTheme = isDarkTheme;
    notifyListeners();
  }

  String get getIconPack => iconPack;

  setIconPack(String iconPack) {
    this.iconPack = iconPack;
    notifyListeners();
  }
}
