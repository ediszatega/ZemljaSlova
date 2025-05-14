import 'package:json_annotation/json_annotation.dart';

part 'employee.g.dart';

@JsonSerializable()
class Employee {
  final int id;
  final int userId;
  final String accessLevel;
  final String firstName;
  final String lastName;
  final String email;
  final String? gender;
  final bool isActive;
  final String? profileImageUrl;

  Employee({
    required this.id,
    required this.userId,
    required this.accessLevel,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.gender,
    required this.isActive,
    this.profileImageUrl,
  });

  String get fullName => '$firstName $lastName';

  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeToJson(this);
} 