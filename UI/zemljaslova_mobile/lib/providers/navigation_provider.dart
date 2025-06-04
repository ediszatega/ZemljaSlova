import 'package:flutter/material.dart';

enum MobileNavigationItem {
  home,
}

class MobileNavigationProvider with ChangeNotifier {
  MobileNavigationItem _currentItem = MobileNavigationItem.home;

  MobileNavigationItem get currentItem => _currentItem;

  void setCurrentItem(MobileNavigationItem item) {
    if (_currentItem != item) {
      _currentItem = item;
      notifyListeners();
    }
  }
} 