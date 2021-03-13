import 'package:flutter/cupertino.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';

class ProviderSearchApps extends ChangeNotifier {
  List<AppInfo> filteredApps;

  ProviderSearchApps(this.filteredApps);

  addApps(Set<AppInfo> toAdd) {
    this.filteredApps.clear();
    this.filteredApps.addAll(toAdd);
    notifyListeners();
  }

  addAppsList(List<AppInfo> toAdd) {
    this.filteredApps.clear();
    this.filteredApps.addAll(toAdd);
    notifyListeners();
  }

  clearFilteredApps() {
    filteredApps.clear();
    notifyListeners();
  }

  List<AppInfo> get getFiltered => filteredApps;
}
