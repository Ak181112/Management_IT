import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Employee {
  // Use userId for the functional ID (e.g. MGR-KM-000001)
  String userId;
  String fullName;
  String email;
  String phone;
  DateTime dob;
  String role; // 'manager', 'field_visitor', 'it_sector'
  String position; // Display name
  double salary;
  String branchName;
  String branchId;
  DateTime joinedDate;
  String password; // Only for creation payload really, usually not returned
  String status;

  // Bank details
  String bankName;
  String bankBranch;
  String accountNo;
  String accountHolder;

  Employee({
    this.userId = '', // Assigned by backend
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.role,
    this.position = '',
    required this.salary,
    required this.branchName,
    this.branchId = '',
    required this.joinedDate,
    this.password = '',
    this.status = 'active',
    this.bankName = '',
    this.bankBranch = '',
    this.accountNo = '',
    this.accountHolder = '',
  });

  // Calculate working period in days from joinedDate to today
  int getWorkingDaysFromNow() {
    final now = DateTime.now();
    return now.difference(joinedDate).inDays;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'dob': dob.toIso8601String(),
    'role': role,
    'position': position,
    'salary': salary,
    'branchName': branchName,
    'branchId': branchId,
    'joinedDate': joinedDate.toIso8601String(),
    'status': status,
    'bankName': bankName,
    'bankBranch': bankBranch,
    'accountNo': accountNo,
    'accountHolder': accountHolder,
  };

  factory Employee.fromJson(Map<String, dynamic> m) => Employee(
    userId: m['userId'] as String? ?? '',
    fullName: m['fullName'] as String? ?? '',
    email: m['email'] as String? ?? '',
    phone: m['phone'] as String? ?? '',
    dob: DateTime.tryParse(m['dob'] as String? ?? '') ?? DateTime.now(),
    role: m['role'] as String? ?? '',
    position: m['position'] as String? ?? '',
    salary: (m['salary'] as num?)?.toDouble() ?? 0.0,
    branchName: m['branchName'] as String? ?? '',
    branchId: m['branchId'] as String? ?? '',
    joinedDate:
        DateTime.tryParse(m['joinedDate'] as String? ?? '') ?? DateTime.now(),
    status: m['status'] as String? ?? 'active',
    bankName: m['bankName'] as String? ?? '',
    bankBranch: m['bankBranch'] as String? ?? '',
    accountNo: m['accountNo'] as String? ?? '',
    accountHolder: m['accountHolder'] as String? ?? '',
  );

  // Backwards compatibility for UI code that used 'id'
  String get id => userId;
  set id(String val) => userId = val;
  String get firstName => fullName.split(' ').first;
  set firstName(String val) =>
      fullName = '$val ${fullName.split(' ').skip(1).join(' ')}';
  String get lastName => fullName.split(' ').length > 1
      ? fullName.split(' ').skip(1).join(' ')
      : '';
  String get branch => branchName;
  set branch(String val) => branchName = val;
}

class EmployeeService {
  static final List<Employee> _employees = [];
  // For Windows, localhost is often accessible but sometimes requires 127.0.0.1
  static const String _baseUrl = 'http://localhost:3000/api/employees';

  static Future<void> init() async {
    await fetchEmployees();
    await _loadSalaryHistory();
  }

  static Future<void> fetchEmployees() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        _employees.clear();
        for (final e in list) {
          try {
            _employees.add(Employee.fromJson(e as Map<String, dynamic>));
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Error fetching employees: $e');
    }
  }

  // salary payments history (each entry: {'date': DateTime, 'total': double})
  static final List<Map<String, dynamic>> _salaryPayments = [];

  static List<Map<String, dynamic>> getSalaryPayments() => List.unmodifiable(
    _salaryPayments.map(
      (m) => {'date': m['date'] as DateTime, 'total': m['total'] as double},
    ),
  );

  static DateTime? _lastSalaryPaid;

  static DateTime? getLastSalaryPaid() => _lastSalaryPaid;

  static Future<void> _loadSalaryHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPaid = prefs.getString('salary_last_paid');
      if (lastPaid != null && lastPaid.isNotEmpty) {
        try {
          _lastSalaryPaid = DateTime.parse(lastPaid);
        } catch (_) {}
      }
      final paymentsJson = prefs.getString('salary_payments');
      if (paymentsJson != null && paymentsJson.isNotEmpty) {
        try {
          final List<dynamic> list = jsonDecode(paymentsJson);
          _salaryPayments.clear();
          for (final p in list) {
            _salaryPayments.add({
              'date': DateTime.parse(p['date']),
              'total': (p['total'] as num).toDouble(),
            });
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  static Future<void> _persistSalaryPayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _salaryPayments
            .map(
              (m) => {
                'date': (m['date'] as DateTime).toIso8601String(),
                'total': m['total'],
              },
            )
            .toList(),
      );
      await prefs.setString('salary_payments', encoded);
    } catch (_) {}
  }

  static Future<void> _setLastSalaryPaid(DateTime dt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('salary_last_paid', dt.toIso8601String());
      _lastSalaryPaid = dt;
    } catch (_) {}
  }

  static void _addSalaryPaymentRecord(DateTime date, double total) {
    _salaryPayments.insert(0, {'date': date, 'total': total});
    _persistSalaryPayments();
  }

  static List<Employee> getEmployees() => List.unmodifiable(_employees);

  static Future<void> addEmployee(Employee e) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(e.toJson()),
      );
      if (response.statusCode == 201) {
        // Since backend adds ID and Password, we should fetch list again or parse response
        // Simplest is to just fetch fresh list to be safe
        await fetchEmployees();
      }
    } catch (e) {
      debugPrint('Error adding employee: $e');
    }
  }

  static Future<void> updateEmployee(String id, Employee updated) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updated.toJson()),
      );
      if (response.statusCode == 200) {
        final idx = _employees.indexWhere((e) => e.userId == id); // Use userId
        if (idx != -1) _employees[idx] = updated;
      }
    } catch (e) {
      debugPrint('Error updating employee: $e');
    }
  }

  static Future<void> deleteEmployee(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200) {
        _employees.removeWhere((e) => e.userId == id);
      }
    } catch (e) {
      debugPrint('Error deleting employee: $e');
    }
  }

  static Employee create({
    required String fullName,
    required String email,
    required String phone,
    required DateTime dob,
    required String role,
    // required String position,
    required double salary,
    required String branchName,
    required DateTime joinedDate,
    String? userId,
    String bankName = '',
    String bankBranch = '',
    String accountNo = '',
    String accountHolder = '',
  }) {
    // ID generated in backend now
    return Employee(
      userId: userId ?? '',
      fullName: fullName,
      email: email,
      phone: phone,
      dob: dob,
      role: role,
      position: role,
      salary: salary,
      branchName: branchName,
      bankName: bankName,
      bankBranch: bankBranch,
      accountNo: accountNo,
      accountHolder: accountHolder,
      joinedDate: joinedDate,
    );
  }

  // Prepare payout items and total
  static Map<String, dynamic> prepareSalaryPayouts() {
    final items = _employees.map((e) {
      return {
        'id': e.userId,
        // 'name': '${e.firstName} ${e.lastName}', // firstName/lastName getters handle full name split
        'name': e.fullName,
        'bankName': e.bankName,
        'bankBranch': e.bankBranch,
        'accountNo': e.accountNo,
        'accountHolder': e.accountHolder,
        'amount': e.salary,
      };
    }).toList();
    final total = _employees.fold<double>(0.0, (s, e) => s + e.salary);
    return {'total': total, 'items': items};
  }

  // Mark salaries as paid now
  static Future<void> markSalariesPaidNow() async {
    final now = DateTime.now();
    final prepared = prepareSalaryPayouts();
    final total = prepared['total'] as double;
    await _setLastSalaryPaid(now);
    _addSalaryPaymentRecord(now, total);
  }

  // Check if salaries can be paid now (only once per month and between day 3-10)
  static bool canPaySalariesNow() {
    final now = DateTime.now();
    if (now.day < 3 || now.day > 10) return false;
    if (_lastSalaryPaid != null) {
      if (_lastSalaryPaid!.year == now.year &&
          _lastSalaryPaid!.month == now.month) {
        return false;
      }
    }
    return true;
  }

  // List of available positions / roles
  static const List<String> roles = ['Manager', 'Field Visitor', 'IT Sector'];

  static const List<String> branches = [
    'Kalmunai',
    'Trincomalee',
    'Chavakachcheri',
    'Kondavil',
    'Jaffna', // Fallback
  ];
}
