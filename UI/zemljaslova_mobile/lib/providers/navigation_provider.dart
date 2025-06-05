import 'package:flutter/material.dart';

enum MobileNavigationItem {
  home,
  cart,
  voucherPurchase,
}

class MobileNavigationProvider with ChangeNotifier {
  MobileNavigationItem _currentItem = MobileNavigationItem.home;
  final List<MobileNavigationItem> _navigationStack = [MobileNavigationItem.home];

  MobileNavigationItem get currentItem => _currentItem;
  List<MobileNavigationItem> get navigationStack => List.unmodifiable(_navigationStack);
  
  bool get canGoBack => _navigationStack.length > 1;
  MobileNavigationItem? get previousItem => 
      _navigationStack.length > 1 ? _navigationStack[_navigationStack.length - 2] : null;

  void setCurrentItem(MobileNavigationItem item) {
    if (_currentItem != item) {
      _currentItem = item;
      notifyListeners();
    }
  }

  void navigateTo(MobileNavigationItem item) {
    if (_currentItem != item) {
      _navigationStack.add(item);
      _currentItem = item;
      notifyListeners();
    }
  }

  void goBack() {
    if (_navigationStack.length > 1) {
      _navigationStack.removeLast();
      _currentItem = _navigationStack.last;
      notifyListeners();
    }
  }

  void resetToHome() {
    _navigationStack.clear();
    _navigationStack.add(MobileNavigationItem.home);
    _currentItem = MobileNavigationItem.home;
    notifyListeners();
  }
} 