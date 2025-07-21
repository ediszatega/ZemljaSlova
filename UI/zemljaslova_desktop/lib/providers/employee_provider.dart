import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';
import '../widgets/paginated_data_widget.dart';

class EmployeeProvider with ChangeNotifier implements PaginatedDataProvider<Employee> {
  final EmployeeService _employeeService;
  
  EmployeeProvider(this._employeeService);
  
  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _error;
  
  // Pagination state
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalCount = 0;
  bool _hasMoreData = true;

  List<Employee> get employees => [..._employees];
  
  // PaginatedDataProvider interface implementation
  @override
  List<Employee> get items => employees;
  
  bool get isLoading => _isLoading;
  @override
  bool get isInitialLoading => _isLoading && _employees.isEmpty;
  @override
  bool get isLoadingMore => _isLoading && _employees.isNotEmpty;
  @override
  String? get error => _error;
  int get currentPage => _currentPage;
  @override
  int get pageSize => _pageSize;
  @override
  int get totalCount => _totalCount;
  @override
  bool get hasMoreData => _hasMoreData;
  int get totalPages => (_totalCount / _pageSize).ceil();

  Future<void> fetchEmployees({bool isUserIncluded = true, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _employees.clear();
      _hasMoreData = true;
      _error = null;
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _employeeService.fetchEmployees(
        isUserIncluded: isUserIncluded,
        page: _currentPage,
        pageSize: _pageSize,
      );
      
      final List<Employee> newEmployees = result['employees'] as List<Employee>;
      _totalCount = result['totalCount'] as int;
      
      if (refresh || _employees.isEmpty) {
        _employees = newEmployees;
      } else {
        _employees.addAll(newEmployees);
      }
      
      _hasMoreData = _employees.length < _totalCount;
      
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  @override
  Future<void> loadMore({bool isUserIncluded = true}) async {
    if (_isLoading || !_hasMoreData) return;
    
    _currentPage++;
    await fetchEmployees(isUserIncluded: isUserIncluded, refresh: false);
  }
  
  @override
  Future<void> refresh({bool isUserIncluded = true}) async {
    await fetchEmployees(isUserIncluded: isUserIncluded, refresh: true);
  }
  
  @override
  void setPageSize(int newPageSize) {
    if (newPageSize != _pageSize) {
      _pageSize = newPageSize;
      refresh();
    }
  }

  Future<Employee?> getEmployeeById(int id) async {
    try {
      return await _employeeService.getEmployeeById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  Future<bool> addEmployee(
    String firstName,
    String lastName,
    String email,
    String password,
    String accessLevel,
    String? gender,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final employee = await _employeeService.createEmployee(
        firstName,
        lastName,
        email,
        password,
        accessLevel,
        gender,
      );

      if (employee != null) {
        // Refresh to get updated pagination
        await refresh();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to add employee';
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
  
  Future<Employee?> updateEmployee(
    int id,
    String firstName,
    String lastName,
    String email,
    String accessLevel,
    String? gender,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEmployee = await _employeeService.updateEmployee(
        id,
        firstName,
        lastName,
        email,
        accessLevel,
        gender,
      );

      if (updatedEmployee != null) {
        final index = _employees.indexWhere((employee) => employee.id == id);
        if (index >= 0) {
          _employees[index] = updatedEmployee;
        }
        
        _isLoading = false;
        notifyListeners();
        return updatedEmployee;
      }

      _error = 'Failed to update employee';
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  Future<bool> deleteEmployee(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _employeeService.deleteEmployee(id);

      if (success) {
        // Refresh to get updated pagination
        await refresh();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to delete employee';
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
}
