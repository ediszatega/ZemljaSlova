import 'package:flutter/material.dart';

enum NavigationItem {
  booksSell,
  bookRent,
  events,
  members,
  memberships,
  reports,
  profile,
  authors,
  employees,
  vouchers,
  discounts,
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