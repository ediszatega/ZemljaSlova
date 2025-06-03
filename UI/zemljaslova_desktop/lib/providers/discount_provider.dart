import 'package:flutter/material.dart';
import '../models/discount.dart';
import '../services/discount_service.dart';

class DiscountProvider with ChangeNotifier {
  final DiscountService _discountService;
  
  DiscountProvider(this._discountService);
  
  List<Discount> _discounts = [];
  bool _isLoading = false;
  String? _error;

  List<Discount> get discounts => [..._discounts];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDiscounts({
    bool? isActive,
    String? code,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? endDateFrom,
    DateTime? endDateTo,
    int? scope,
    double? minPercentage,
    double? maxPercentage,
    bool? hasUsageLimit,
    int? bookId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _discounts = await _discountService.fetchDiscounts(
        isActive: isActive,
        code: code,
        startDateFrom: startDateFrom,
        startDateTo: startDateTo,
        endDateFrom: endDateFrom,
        endDateTo: endDateTo,
        scope: scope,
        minPercentage: minPercentage,
        maxPercentage: maxPercentage,
        hasUsageLimit: hasUsageLimit,
        bookId: bookId,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Discount?> getDiscountById(int id) async {
    try {
      return await _discountService.getDiscountById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Discount?> getDiscountByCode(String code) async {
    try {
      return await _discountService.getDiscountByCode(code);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createDiscount({
    required double discountPercentage,
    required DateTime startDate,
    required DateTime endDate,
    String? code,
    required String name,
    String? description,
    required int scope,
    int? maxUsage,
    bool isActive = true,
    List<int>? bookIds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final discount = await _discountService.createDiscount(
        discountPercentage: discountPercentage,
        startDate: startDate,
        endDate: endDate,
        code: code,
        name: name,
        description: description,
        scope: scope,
        maxUsage: maxUsage,
        bookIds: bookIds,
      );

      if (discount != null) {
        _discounts.add(discount);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to create discount';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDiscount({
    required int id,
    required double discountPercentage,
    required DateTime startDate,
    required DateTime endDate,
    String? code,
    required String name,
    String? description,
    required int scope,
    int? maxUsage,
    bool isActive = true,
    List<int>? bookIds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final discount = await _discountService.updateDiscount(
        id: id,
        discountPercentage: discountPercentage,
        startDate: startDate,
        endDate: endDate,
        code: code,
        name: name,
        description: description,
        scope: scope,
        maxUsage: maxUsage,
        isActive: isActive,
        bookIds: bookIds,
      );

      if (discount != null) {
        final index = _discounts.indexWhere((d) => d.id == id);
        if (index != -1) {
          _discounts[index] = discount;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to update discount';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDiscount(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _discountService.deleteDiscount(id);

      if (success) {
        _discounts.removeWhere((discount) => discount.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to delete discount';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<int> cleanupExpiredDiscounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final removedCount = await _discountService.cleanupExpiredDiscounts();
      
      // Refresh the discount list after cleanup
      await fetchDiscounts();
      
      return removedCount;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return 0;
    }
  }

  Future<List<Discount>> getExpiredDiscounts() async {
    try {
      return await _discountService.getExpiredDiscounts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBooksWithDiscount(int discountId) async {
    try {
      return await _discountService.getBooksWithDiscount(discountId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper getters
  List<Discount> get bookDiscounts => _discounts.where((d) => d.scope == 1).toList();
  List<Discount> get orderDiscounts => _discounts.where((d) => d.scope == 2).toList();
  List<Discount> get activeDiscounts => _discounts.where((d) => d.isValid).toList();
  List<Discount> get expiredDiscounts => _discounts.where((d) => d.isExpired).toList();
  List<Discount> get inactiveDiscounts => _discounts.where((d) => !d.isActive).toList();
} 