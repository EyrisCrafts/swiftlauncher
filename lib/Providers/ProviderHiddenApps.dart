import 'package:flutter/cupertino.dart';

class ProviderHiddenApps extends ChangeNotifier {
  List<String> hiddenApps;
  ProviderHiddenApps(this.hiddenApps);

  List<String> get getHiddenApps => hiddenApps;

  addHiddenApp(String package) {
    hiddenApps.add(package);
    notifyListeners();
  }

  removeHiddenApp(String package) {
    hiddenApps.removeWhere((element) => element == package);

    notifyListeners();
  }
}
