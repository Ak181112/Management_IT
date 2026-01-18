import 'dart:io';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/employee_service.dart';
import '../services/member_service.dart';
import 'employee_page.dart';
import 'members_page.dart';
import 'product_page.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  List<int> _monthlyNewMembers() {
    final now = DateTime.now();
    final counts = List<int>.filled(12, 0);
    final members = MemberService.getMembers();
    for (final m in members) {
      final jd = m.joinedDate;
      if (jd == null) continue;
      for (int i = 0; i < 12; i++) {
        final monthDate = DateTime(now.year, now.month - 11 + i, 1);
        if (jd.year == monthDate.year && jd.month == monthDate.month) {
          counts[i]++;
        }
      }
    }
    return counts;
  }

  List<int> _monthlyNewEmployees() {
    final now = DateTime.now();
    final counts = List<int>.filled(12, 0);
    final employees = EmployeeService.getEmployees();
    for (final e in employees) {
      final jd = e.joinedDate;
      for (int i = 0; i < 12; i++) {
        final monthDate = DateTime(now.year, now.month - 11 + i, 1);
        if (jd.year == monthDate.year && jd.month == monthDate.month) {
          counts[i]++;
        }
      }
    }
    return counts;
  }

  List<List<double>> _monthlyMemberBuySell() {
    final now = DateTime.now();
    final buy = List<double>.filled(12, 0.0);
    final sell = List<double>.filled(12, 0.0);
    final members = MemberService.getMembers();
    for (final m in members) {
      for (final t in m.transactions) {
        final dt = t.date;
        for (int i = 0; i < 12; i++) {
          final monthDate = DateTime(now.year, now.month - 11 + i, 1);
          if (dt.year == monthDate.year && dt.month == monthDate.month) {
            if (t.type == 'buy') buy[i] += t.amount;
            if (t.type == 'sell') sell[i] += t.amount;
          }
        }
      }
    }
    return [buy, sell];
  }

  List<Map<String, dynamic>> _topSellingProducts(int limit) {
    final products = ProductService.getProducts();
    final list = products.map((p) {
      final revenue = p.soldPerMonth * p.price;
      return {'product': p, 'revenue': revenue};
    }).toList();
    list.sort(
      (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double),
    );
    return list.take(limit).toList();
  }

  List<Map<String, dynamic>> _salaryHistory() {
    return EmployeeService.getSalaryPayments();
  }

  Widget _cardMetric(String title, String value, {IconData? icon}) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24, color: Colors.blue),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardAnalytics() {
    final income = ProductService.totalSelling();
    final outcome = ProductService.totalBuying();
    final incomeSeries = ProductService.monthlyIncome();
    final outcomeSeries = ProductService.monthlyOutcome();
    final memberTotal = MemberService.getMembers().length;
    final memberSeries = _monthlyNewMembers();
    final memberBought = MemberService.getMembers().fold<double>(
      0.0,
      (s, m) => s + m.totalBought,
    );
    final memberSold = MemberService.getMembers().fold<double>(
      0.0,
      (s, m) => s + m.totalSold,
    );
    final employeeTotal = EmployeeService.getEmployees().length;
    final employeeSeries = _monthlyNewEmployees();
    final positionCounts = <String, int>{};
    for (final pos in EmployeeService.roles) {
      positionCounts[pos] = EmployeeService.getEmployees()
          .where((e) => e.position == pos)
          .length;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _cardMetric(
                    'Total Income',
                    'LKR ${income.toStringAsFixed(2)}',
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _cardMetric(
                    'Total Outcome',
                    'LKR ${outcome.toStringAsFixed(2)}',
                    icon: Icons.trending_down,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Products - Income vs Outcome',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: _MiniLineChart.doubleSeries(
                        incomeSeries,
                        outcomeSeries,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _cardMetric(
                    'Members',
                    '$memberTotal',
                    icon: Icons.group,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _cardMetric(
                    'Bought',
                    'LKR ${memberBought.toStringAsFixed(2)}',
                    icon: Icons.shopping_cart,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _cardMetric(
                    'Sold',
                    'LKR ${memberSold.toStringAsFixed(2)}',
                    icon: Icons.store,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Members - New per Month',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 90,
                      child: _MiniLineChart.points(memberSeries),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _cardMetric(
                    'Employees',
                    '$employeeTotal',
                    icon: Icons.work,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _cardMetric(
                    'Managers',
                    '${positionCounts['Manager'] ?? 0}',
                    icon: Icons.person,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _cardMetric(
                    'Visitors',
                    '${positionCounts['Field Visitor'] ?? 0}',
                    icon: Icons.location_on,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Employees - New per Month',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 90,
                      child: _MiniLineChart.points(employeeSeries),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Selling Products',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._topSellingProducts(5).map((p) {
                      final prod = p['product'];
                      final revenue = p['revenue'] as double;
                      return ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text(
                          prod.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          'Revenue: LKR ${revenue.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Text(
                          'Stock: ${prod.currentStock}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Members - Buy vs Sell',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: Builder(
                        builder: (context) {
                          final series = _monthlyMemberBuySell();
                          return _MiniLineChart.doubleSeries(
                            series[0],
                            series[1],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Salary Payout History',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._salaryHistory().take(6).map((rec) {
                      final dt = rec['date'] as DateTime;
                      final total = rec['total'] as double;
                      return ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text(
                          DateFormat('yyyy-MM-dd').format(dt),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          'LKR ${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  final List<Widget> _pages = [
    Container(), // placeholder for Home/Dashboard - will be built dynamically
    const ProductPage(),
    const EmployeePage(),
    const MembersPage(),
  ];

  @override
  void initState() {
    super.initState();
    ProductService.init().then((_) => setState(() {}));
    EmployeeService.init().then((_) => setState(() {}));
    MemberService.init().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Dashboard', 'Products', 'Employees', 'Members'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          titles[_selectedIndex],
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    (AuthService.avatarPath != null &&
                        AuthService.avatarPath!.isNotEmpty)
                    ? FileImage(File(AuthService.avatarPath!))
                    : null,
                child:
                    (AuthService.avatarPath == null ||
                        AuthService.avatarPath!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              onPressed: () {
                // Navigate to new Profile Screen
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    )
                    .then((_) {
                      // Refresh state on return in case avatar changed
                      setState(() {});
                    });
              },
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildDashboardAnalytics()
          : IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.dashboard, color: Colors.blue),
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            activeIcon: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.inventory_2, color: Colors.blue),
            ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work_outline),
            activeIcon: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.work, color: Colors.blue),
            ),
            label: 'Employees',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group_outlined),
            activeIcon: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.group, color: Colors.blue),
            ),
            label: 'Members',
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const SizedBox(
            height: 60.0,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: SizedBox.shrink(),
            ),
          ),
          _buildDrawerItem(
            text: 'DashBoard',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            text: 'Products',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProductPage())),
          ),
          _buildDrawerItem(
            text: 'Employees',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const EmployeePage())),
          ),
          _buildDrawerItem(text: 'Members', onTap: () {}),
          _buildDrawerItem(text: 'Analysis', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required String text, required VoidCallback onTap}) {
    return ListTile(
      title: Text(text, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}

// lightweight chart painter
class _MiniLineChart extends StatelessWidget {
  final List<double> seriesA;
  final List<double>? seriesB;
  final List<int>? points;

  const _MiniLineChart._(this.seriesA, this.seriesB, this.points);

  factory _MiniLineChart.points(List<int> pts) {
    return _MiniLineChart._(pts.map((e) => e.toDouble()).toList(), null, pts);
  }

  factory _MiniLineChart.doubleSeries(List<double> a, List<double> b) {
    return _MiniLineChart._(a, b, null);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MiniPainter(seriesA, seriesB),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class _MiniPainter extends CustomPainter {
  final List<double> a;
  final List<double>? b;
  _MiniPainter(this.a, this.b);

  @override
  void paint(Canvas canvas, Size size) {
    if (a.isEmpty || size.width <= 0 || size.height <= 0) return;

    // Add padding to prevent drawing outside bounds
    const padding = 4.0;
    final drawWidth = size.width - (padding * 2);
    final drawHeight = size.height - (padding * 2);

    final paintA = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paintB = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dot = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final maxVal = a.fold<double>(0.0, (p, e) => e > p ? e : p);
    final span = (maxVal == 0) ? 1.0 : maxVal;
    final stepX = (a.length > 1) ? (drawWidth / (a.length - 1)) : 0.0;

    // Draw series A
    final pathA = Path();
    for (int i = 0; i < a.length; i++) {
      final x = padding + (stepX * i);
      final y = padding + drawHeight - ((a[i] / span) * drawHeight);
      if (i == 0) {
        pathA.moveTo(x, y);
      } else {
        pathA.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 1.5, dot);
    }
    canvas.drawPath(pathA, paintA);

    // Draw series B if present
    if (b != null && b!.isNotEmpty) {
      final maxB = b!.fold<double>(0.0, (p, e) => e > p ? e : p);
      final spanB = (maxB == 0) ? 1.0 : maxB;
      final stepXB = (b!.length > 1) ? (drawWidth / (b!.length - 1)) : 0.0;

      final pathB = Path();
      for (int i = 0; i < b!.length; i++) {
        final x = padding + (stepXB * i);
        final y = padding + drawHeight - ((b![i] / spanB) * drawHeight);
        if (i == 0) {
          pathB.moveTo(x, y);
        } else {
          pathB.lineTo(x, y);
        }
      }
      canvas.drawPath(pathB, paintB);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniPainter oldDelegate) => true;
}
