import 'package:flutter/material.dart';
import '../models/voucher.dart';
import '../services/voucher_service.dart';

class VoucherProvider with ChangeNotifier {
  final VoucherService _voucherService;
  
  VoucherProvider(this._voucherService);
  
  List<Voucher> _vouchers = [];
  bool _isLoading = false;
  String? _error;

  // Simple pagination state
  int _currentPage = 0;
  final int _pageSize = 10;
  int _totalCount = 0;
  
  // Store current filters to maintain them across pagination
  Map<String, dynamic> _currentFilters = {};

  List<Voucher> get vouchers => [..._vouchers];
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;
  int get totalPages => (_totalCount / _pageSize).ceil();
  bool get hasPreviousPage => _currentPage > 0;
  bool get hasNextPage => (_currentPage + 1) < totalPages;
  bool get shouldShowPagination => _totalCount > _pageSize;

  Future<void> fetchVouchers({
    int? memberId,
    bool? isUsed,
    String? code,
    DateTime? expirationDateFrom,
    DateTime? expirationDateTo,
    bool resetPage = true,
  }) async {
    if (resetPage) {
      _currentPage = 0;
    }
    
    // Store current filters
    _currentFilters = {
      'memberId': memberId,
      'isUsed': isUsed,
      'code': code,
      'expirationDateFrom': expirationDateFrom,
      'expirationDateTo': expirationDateTo,
    };
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _voucherService.fetchVouchers(
        memberId: memberId,
        isUsed: isUsed,
        code: code,
        expirationDateFrom: expirationDateFrom,
        expirationDateTo: expirationDateTo,
        page: _currentPage,
        pageSize: _pageSize,
      );
      
      _vouchers = result['vouchers'] as List<Voucher>;
      _totalCount = result['totalCount'] as int;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
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
    await fetchVouchers(
      memberId: _currentFilters['memberId'],
      isUsed: _currentFilters['isUsed'],
      code: _currentFilters['code'],
      expirationDateFrom: _currentFilters['expirationDateFrom'],
      expirationDateTo: _currentFilters['expirationDateTo'],
      resetPage: false, // Don't reset page since we're navigating
    );
  }

  Future<Voucher?> getVoucherById(int id) async {
    try {
      return await _voucherService.getVoucherById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Voucher?> getVoucherByCode(String code) async {
    try {
      return await _voucherService.getVoucherByCode(code);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createAdminVoucher({
    required double value,
    required DateTime expirationDate,
    String? code,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final voucher = await _voucherService.createAdminVoucher(
        value: value,
        expirationDate: expirationDate,
        code: code,
      );

      if (voucher != null) {
        _vouchers.add(voucher);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to create admin voucher';
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

  Future<bool> deleteVoucher(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _voucherService.deleteVoucher(id);

      if (success) {
        _vouchers.removeWhere((voucher) => voucher.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to delete voucher';
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<Voucher> get memberVouchers => _vouchers.where((v) => v.isPurchasedByMember).toList();
  List<Voucher> get promotionalVouchers => _vouchers.where((v) => v.isPromotional).toList();
  List<Voucher> get activeVouchers => _vouchers.where((v) => !v.isUsed).toList();
  List<Voucher> get usedVouchers => _vouchers.where((v) => v.isUsed).toList();
  List<Voucher> get expiredVouchers => _vouchers.where((v) => v.expirationDate.isBefore(DateTime.now())).toList();
} 