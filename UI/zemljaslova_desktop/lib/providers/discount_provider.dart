import 'dart:async';
import 'package:flutter/material.dart';
import '../models/discount.dart';
import '../models/discount_filters.dart';
import '../services/discount_service.dart';

class DiscountProvider with ChangeNotifier {
  final DiscountService _discountService;
  
  DiscountProvider(this._discountService);
  
  List<Discount> _discounts = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  
  int _currentPage = 0;
  final int _pageSize = 10;
  int _totalCount = 0;
  
  DiscountFilters _filters = const DiscountFilters();
  
  String _searchQuery = '';
  Timer? _searchDebounceTimer;

  List<Discount> get discounts => [..._discounts];
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;
  int get totalPages => (_totalCount / _pageSize).ceil();
  bool get hasPreviousPage => _currentPage > 0;
  bool get hasNextPage => (_currentPage + 1) < totalPages;
  bool get shouldShowPagination => _totalCount > _pageSize;
  DiscountFilters get filters => _filters;

  Future<void> fetchDiscounts({
    DiscountFilters? filters,
    bool resetPage = true,
    String? name,
  }) async {
    if (resetPage) {
      _currentPage = 0;
    }
    
    if (filters != null) {
      _filters = filters;
    }
    
    if (_discounts.isNotEmpty && resetPage) {
      _isUpdating = true;
    } else {
      _isLoading = true;
    }
    _error = null;
    notifyListeners();
    
    try {
      final result = await _discountService.fetchDiscounts(
        filters: _filters.toQueryParams(),
        page: _currentPage,
        pageSize: _pageSize,
        name: name ?? (_searchQuery.isNotEmpty ? _searchQuery : null),
      );
      
      final discountsList = result['discounts'] as List;
      final totalCount = result['totalCount'] as int;
      
      if (resetPage) {
        _discounts = discountsList.cast<Discount>();
      } else {
        _discounts.addAll(discountsList.cast<Discount>());
      }
        
      _totalCount = totalCount;
      
      _isLoading = false;
      _isUpdating = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isUpdating = false;
      notifyListeners();
    }
  }
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    
    _searchDebounceTimer?.cancel();
    
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchDiscounts(resetPage: true);
    });
  }
  
  void clearSearch() {
    _searchQuery = '';
    _searchDebounceTimer?.cancel();
    _discounts.clear();
    fetchDiscounts(resetPage: true);
  }
  
  String get searchQuery => _searchQuery;
  
  // Pagination methods
  Future<void> nextPage() async {
    if (hasNextPage && !_isLoading) {
      _currentPage++;
      await _fetchWithCurrentFilters();
    }
  }
  
  Future<void> previousPage() async {
    if (hasPreviousPage && !_isLoading) {
      _currentPage--;
      await _fetchWithCurrentFilters();
    }
  }
  
  // Helper method to refetch with stored filters
  Future<void> _fetchWithCurrentFilters() async {
    await fetchDiscounts(
      filters: _filters,
      resetPage: false,
    );
  }

  void setFilters(DiscountFilters filters) {
    _filters = filters;
    fetchDiscounts(filters: filters);
  }

  void clearFilters() {
    _filters = const DiscountFilters();
    fetchDiscounts(filters: _filters);
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

      _error = 'Brisanje popusta nije uspjelo.';
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