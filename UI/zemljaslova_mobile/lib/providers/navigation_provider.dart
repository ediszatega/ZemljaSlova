import 'package:flutter/material.dart';

enum MobileNavigationItem {
  home,
  cart,
  favourites,
  profile,
  voucherPurchase,
  booksSellOverview,
  booksRentOverview,
  eventsOverview,
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

  void navigateToBottomNavItem(MobileNavigationItem item, BuildContext context) {
    // Don't navigate if already on the same screen and not in a detail screen
    if (_currentItem == item && !Navigator.canPop(context)) {
      return;
    }
    
    // If we're in a detail screen, pop back to main layout first
    if (Navigator.canPop(context)) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    
    // Check if this item is already in the stack
    final existingIndex = _navigationStack.indexOf(item);
    
    if (existingIndex != -1) {
      // Item exists in stack - remove all items after it and navigate to it
      _navigationStack.removeRange(existingIndex + 1, _navigationStack.length);
      _currentItem = item;
    } else {
      // Item doesn't exist in stack - add it normally
      _navigationStack.add(item);
      _currentItem = item;
    }
    
    notifyListeners();
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