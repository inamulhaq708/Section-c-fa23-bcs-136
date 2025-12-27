import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/db/database_helper.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  double _income = 0;
  double _expense = 0;

  final int selectedMonth = DateTime.now().month;
  final int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final income = await DatabaseHelper.instance.getTotalIncome();
    final expense = await DatabaseHelper.instance.getTotalExpense();

    setState(() {
      _income = income;
      _expense = expense;
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = _income - _expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _balanceCard(balance),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    'Income',
                    _income,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    'Expense',
                    _expense,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Monthly Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 🔥 CHART ADDED HERE
            _monthlyOverviewChart(
              year: selectedYear,
              month: selectedMonth,
            ),
          ],
        ),
      ),
    );
  }

  // ================= BALANCE CARD =================
  Widget _balanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade400,
            Colors.indigo.shade700,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Rs ${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SUMMARY CARD =================
  Widget _summaryCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: color),
          ),
          const SizedBox(height: 8),
          Text(
            'Rs ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= MONTHLY OVERVIEW CHART =================
  Widget _monthlyOverviewChart({
    required int year,
    required int month,
  }) {
    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: FutureBuilder<List<double>>(
        future: Future.wait([
          DatabaseHelper.instance.getMonthlyIncome(year, month),
          DatabaseHelper.instance.getMonthlyExpense(year, month),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final income = snapshot.data![0];
          final expense = snapshot.data![1];

          if (income == 0 && expense == 0) {
            return const Center(
              child: Text(
                'No data for this month',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final maxY = (income > expense ? income : expense) + 500;

          return BarChart(
            BarChartData(
              maxY: maxY,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),

              // 🔥 REMOVE RANDOM NUMBERS
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          value == 0 ? 'Income' : 'Expense',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return Text(
                          'Rs${income.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        );
                      } else if (value == 1) {
                        return Text(
                          'Rs${expense.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: income,
                      width: 30,
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: expense,
                      width: 30,
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ],
            ),
          );

        },
      ),
    );
  }
}
