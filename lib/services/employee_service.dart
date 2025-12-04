import 'dart:math';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Employee {
  String id;
  String firstName;
  String lastName;
  DateTime dob; // Date of birth
  String position; // 'Field Visitor', 'Manager', 'IT Sector'
  double salary; // Monthly salary in LKR
  String branch;
  DateTime joinedDate; // When employee joined

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.position,
    required this.salary,
    required this.branch,
    required this.joinedDate,
  });

  // Calculate working period in days from joinedDate to today
  int getWorkingDaysFromNow() {
    final now = DateTime.now();
    return now.difference(joinedDate).inDays;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'dob': dob.toIso8601String(),
    'position': position,
    'salary': salary,
    'branch': branch,
    'joinedDate': joinedDate.toIso8601String(),
  };

  factory Employee.fromJson(Map<String, dynamic> m) => Employee(
    id: m['id'] as String,
    firstName: m['firstName'] as String,
    lastName: m['lastName'] as String,
    dob: DateTime.parse(m['dob'] as String),
    position: m['position'] as String,
    salary: (m['salary'] as num).toDouble(),
    branch: m['branch'] as String,
    joinedDate: DateTime.parse(m['joinedDate'] as String),
  );
}

class EmployeeService {
  static final List<Employee> _employees = [];
  static const String _storageKey = 'employees_v1';

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        _employees.clear();
        for (final e in list) {
          try {
            _employees.add(Employee.fromJson(e as Map<String, dynamic>));
          } catch (_) {
            // ignore malformed entries
          }
        }
      }
    } catch (_) {
      // ignore storage errors
    }
  }

  static Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_employees.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {
      // ignore save errors
    }
  }

  static List<Employee> getEmployees() => List.unmodifiable(_employees);

  static void addEmployee(Employee e) {
    _employees.insert(0, e);
    _saveToStorage();
  }

  static void updateEmployee(String id, Employee updated) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx != -1) _employees[idx] = updated;
    _saveToStorage();
  }

  static void deleteEmployee(String id) {
    _employees.removeWhere((e) => e.id == id);
    _saveToStorage();
  }

  static Employee create({
    required String firstName,
    required String lastName,
    required DateTime dob,
    required String position,
    required double salary,
    required String branch,
    required DateTime joinedDate,
  }) {
    final id =
        DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(999).toString();
    return Employee(
      id: id,
      firstName: firstName,
      lastName: lastName,
      dob: dob,
      position: position,
      salary: salary,
      branch: branch,
      joinedDate: joinedDate,
    );
  }

  // List of available positions
  static const List<String> positions = [
    'Field Visitor',
    'Manager',
    'IT Sector',
  ];
}
