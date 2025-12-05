import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/product_service.dart';
import '../services/employee_service.dart';
import '../services/member_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    ProductService.init().then((_) => setState(() {}));
    EmployeeService.init().then((_) => setState(() {}));
    MemberService.init().then((_) => setState(() {}));
  }

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

  // Monthly buy/sell totals across all members (last 12 months oldest->newest)
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

  // Top selling products by monthly revenue
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

  // Salary payout history
  List<Map<String, dynamic>> _salaryHistory() {
    return EmployeeService.getSalaryPayments();
  }

  Widget _cardMetric(String title, String value, {IconData? icon}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(width: 12),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
    for (final pos in EmployeeService.positions) {
      positionCounts[pos] = EmployeeService.getEmployees()
          .where((e) => e.position == pos)
          .length;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: _cardMetric(
                      'Total Income (12m)',
                      'LKR ${income.toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _cardMetric(
                      'Total Outcome (12m)',
                      'LKR ${outcome.toStringAsFixed(2)}',
                      icon: Icons.trending_down,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Products - Monthly Income vs Outcome',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
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
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: _cardMetric(
                      'Members',
                      '$memberTotal',
                      icon: Icons.group,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _cardMetric(
                      'Member Bought',
                      'LKR ${memberBought.toStringAsFixed(2)}',
                      icon: Icons.shopping_cart,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _cardMetric(
                      'Member Sold',
                      'LKR ${memberSold.toStringAsFixed(2)}',
                      icon: Icons.store,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Members - New per Month',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: _MiniLineChart.points(memberSeries),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: _cardMetric(
                      'Employees',
                      '$employeeTotal',
                      icon: Icons.work,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _cardMetric(
                      'Managers',
                      '${positionCounts['Manager'] ?? 0}',
                      icon: Icons.person,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _cardMetric(
                      'Field Visitors',
                      '${positionCounts['Field Visitor'] ?? 0}',
                      icon: Icons.location_on,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Employees - New per Month',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: _MiniLineChart.points(employeeSeries),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Top selling products
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top Selling Products',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._topSellingProducts(5).map((p) {
                        final prod = p['product'];
                        final revenue = p['revenue'] as double;
                        return ListTile(
                          title: Text(prod.name),
                          subtitle: Text(
                            'Monthly revenue: LKR ${revenue.toStringAsFixed(2)}',
                          ),
                          trailing: Text('Stock: ${prod.currentStock}'),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Member buy/sell trends
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Members - Buy vs Sell (monthly)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
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

            // Salary payout history
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Salary Payout History',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._salaryHistory().take(6).map((rec) {
                        final dt = rec['date'] as DateTime;
                        final total = rec['total'] as double;
                        return ListTile(
                          dense: true,
                          title: Text(DateFormat('yyyy-MM-dd').format(dt)),
                          trailing: Text('LKR ${total.toStringAsFixed(2)}'),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
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
    final paintA = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    final paintB = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    final dot = Paint()..color = Colors.blue;

    if (a.isEmpty) return;
    final maxVal = a.fold<double>(0.0, (p, e) => e > p ? e : p);
    final span = (maxVal == 0) ? 1.0 : maxVal;
    final stepX = size.width / (a.length - 1).clamp(1, double.infinity);

    final pathA = Path();
    for (int i = 0; i < a.length; i++) {
      final x = stepX * i;
      final y = size.height - ((a[i] / span) * size.height);
      if (i == 0) {
        pathA.moveTo(x, y);
      } else {
        pathA.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 2, dot);
    }
    canvas.drawPath(pathA, paintA);

    if (b != null) {
      final maxB = b!.fold<double>(0.0, (p, e) => e > p ? e : p);
      final spanB = (maxB == 0) ? 1.0 : maxB;
      final stepXB = size.width / (b!.length - 1).clamp(1, double.infinity);
      final pathB = Path();
      for (int i = 0; i < b!.length; i++) {
        final x = stepXB * i;
        final y = size.height - ((b![i] / spanB) * size.height);
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
