import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:swiftlauncher/Utils/LauncherAssist.dart';

class ProviderSearchContacts extends ChangeNotifier {
  List<Contact> filteredContacts;

  ProviderSearchContacts(this.filteredContacts);

  addApps(Set<Contact> toAdd) {
    this.filteredContacts.clear();
    this.filteredContacts.addAll(toAdd);
    notifyListeners();
  }

  addAppsList(List<Contact> toAdd) {
    this.filteredContacts.clear();
    this.filteredContacts.addAll(toAdd);
    notifyListeners();
  }

  clearFilteredContacts() {
    filteredContacts.clear();
    notifyListeners();
  }

  List<Contact> get getFiltered => filteredContacts;
}
