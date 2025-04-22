import 'package:flutter/material.dart';

enum NavigationItem {
  booksSell,
  bookRent,
  events,
  members,
  reports,
  profile,
  authors,
}

class NavigationProvider with ChangeNotifier {
  NavigationItem _currentItem = NavigationItem.members;

  NavigationItem get currentItem => _currentItem;

  void setCurrentItem(NavigationItem item) {
    if (_currentItem != item) {
      _currentItem = item;
      notifyListeners();
    }
  }
} 