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
}
