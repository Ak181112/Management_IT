import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../services/employee_service.dart';

// Upper-case formatter (top-level so it can be reused safely).
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();
    return newValue.copyWith(text: upper, selection: newValue.selection);
  }
}

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  @override
  void initState() {
    super.initState();
    EmployeeService.init().then((_) {
      setState(() {});
    });
  }

  // (UpperCase formatter defined at top-level)

  void _openAddEditDialog({Employee? employee}) async {
    final isEdit = employee != null;
    final firstNameCtrl = TextEditingController(
      text: employee?.firstName ?? '',
    );
    final lastNameCtrl = TextEditingController(text: employee?.lastName ?? '');
    DateTime? selectedDob = employee?.dob;
    String? selectedPosition = employee?.position;
    final salaryCtrl = TextEditingController(
      text: employee != null ? employee.salary.toString() : '',
    );
    final branchCtrl = TextEditingController(text: employee?.branch ?? '');
    DateTime? selectedJoinedDate = employee?.joinedDate;
    String workingDays = employee != null
        ? '${employee.getWorkingDaysFromNow()}'
        : '0';

    // We'll apply the formatter directly to the TextFields via inputFormatters.

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Employee' : 'Add Employee'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: firstNameCtrl,
                      inputFormatters: [_UpperCaseTextFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: lastNameCtrl,
                      inputFormatters: [_UpperCaseTextFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDob ?? DateTime.now(),
                          firstDate: DateTime(1960),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => selectedDob = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDob != null
                                  ? DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(selectedDob!)
                                  : 'Select Date of Birth',
                              style: TextStyle(
                                color: selectedDob != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Position *',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: selectedPosition,
                      items: EmployeeService.positions
                          .map(
                            (pos) =>
                                DropdownMenuItem(value: pos, child: Text(pos)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedPosition = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Position is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: salaryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Salary (LKR)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: branchCtrl,
                      inputFormatters: [_UpperCaseTextFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Branch',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedJoinedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          selectedJoinedDate = picked;
                          final days = DateTime.now()
                              .difference(selectedJoinedDate!)
                              .inDays;
                          setState(() {
                            workingDays = '$days';
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedJoinedDate != null
                                  ? DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(selectedJoinedDate!)
                                  : 'Select Joined Date',
                              style: TextStyle(
                                color: selectedJoinedDate != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey[50],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Working Days:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            workingDays,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final firstName = firstNameCtrl.text.trim().toUpperCase();
                    final lastName = lastNameCtrl.text.trim().toUpperCase();
                    final salary =
                        double.tryParse(salaryCtrl.text.trim()) ?? 0.0;
                    final branch = branchCtrl.text.trim().toUpperCase();

                    if (firstName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('First name is required')),
                      );
                      return;
                    }
                    if (lastName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Last name is required')),
                      );
                      return;
                    }
                    if (selectedDob == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Date of birth is required'),
                        ),
                      );
                      return;
                    }
                    if (selectedPosition == null || selectedPosition!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Position is required')),
                      );
                      return;
                    }
                    if (selectedJoinedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Joined date is required'),
                        ),
                      );
                      return;
                    }
                    if (salary <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Salary must be positive'),
                        ),
                      );
                      return;
                    }
                    if (branch.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Branch is required')),
                      );
                      return;
                    }

                    if (isEdit) {
                      final updated = Employee(
                        id: employee.id,
                        firstName: firstName,
                        lastName: lastName,
                        dob: selectedDob!,
                        position: selectedPosition!,
                        salary: salary,
                        branch: branch,
                        joinedDate: selectedJoinedDate!,
                      );
                      EmployeeService.updateEmployee(employee.id, updated);
                    } else {
                      final created = EmployeeService.create(
                        firstName: firstName,
                        lastName: lastName,
                        dob: selectedDob!,
                        position: selectedPosition!,
                        salary: salary,
                        branch: branch,
                        joinedDate: selectedJoinedDate!,
                      );
                      EmployeeService.addEmployee(created);
                    }

                    setState(() {});
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final employees = EmployeeService.getEmployees();

    return Scaffold(
      appBar: AppBar(title: const Text('Employees')),
      body: employees.isEmpty
          ? Center(
              child: Text(
                'No employees yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: employees.length,
              itemBuilder: (context, i) {
                final emp = employees[i];
                final workingDays = emp.getWorkingDaysFromNow();
                final joinedStr = DateFormat(
                  'yyyy-MM-dd',
                ).format(emp.joinedDate);

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        '${emp.firstName[0]}${emp.lastName[0]}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('${emp.firstName} ${emp.lastName}'),
                    subtitle: Text(
                      '${emp.position} • ${emp.branch}\nJoined: $joinedStr • Working: $workingDays days\nSalary: LKR ${emp.salary.toStringAsFixed(2)}/month',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _openAddEditDialog(employee: emp),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Delete'),
                                content: const Text('Delete this employee?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(c).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(c).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              EmployeeService.deleteEmployee(emp.id);
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
