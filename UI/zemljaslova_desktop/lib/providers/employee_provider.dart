import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';

class EmployeeProvider with ChangeNotifier {
  final EmployeeService _employeeService;
  
  EmployeeProvider(this._employeeService);
  
  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _error;

  List<Employee> get employees => [..._employees];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEmployees({bool isUserIncluded = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = await _employeeService.fetchEmployees(isUserIncluded: isUserIncluded);
      for (var employee in _employees) {
        print(employee.firstName);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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
        _employees.add(employee);
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
}
