import 'package:flutter/material.dart';
import '../../data/db/database_helper.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}
bool _animate = false;

class _InsightsScreenState extends State<InsightsScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final months = const [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ================= MONTH & YEAR SELECTOR =================
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: selectedMonth,
                  decoration: const InputDecoration(labelText: 'Month'),
                  items: List.generate(
                    12,
                        (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(months[index]),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => selectedMonth = value!);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: selectedYear,
                  decoration: const InputDecoration(labelText: 'Year'),
                  items: List.generate(
                    5,
                        (index) {
                      final year = DateTime.now().year - index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    },
                  ),
                  onChanged: (value) {
                    setState(() => selectedYear = value!);
                  },
                ),
              ),
            ],
          ),
        ),

        // ================= ALL ANALYTICS =================
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: Future.wait([
              DatabaseHelper.instance
                  .getMonthlyIncome(selectedYear, selectedMonth),
              DatabaseHelper.instance
                  .getMonthlyExpense(selectedYear, selectedMonth),
              DatabaseHelper.instance
                  .getCategoryExpense(selectedYear, selectedMonth),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final income = snapshot.data![0] as double;
              final expense = snapshot.data![1] as double;
              final categoryData =
              snapshot.data![2] as Map<String, double>;

              final balance = income - expense;
              if (!_animate) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    setState(() => _animate = true);
                  }
                });
              }

              return AnimatedOpacity(
                  opacity: _animate ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: AnimatedSlide(
                      offset: _animate ? Offset.zero : const Offset(0, 0.05),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      child: SingleChildScrollView(

                      padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= SUMMARY CARDS =================
                    Row(
                      children: [
                        _summaryCard(
                          title: 'Income',
                          amount: income,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _summaryCard(
                          title: 'Expense',
                          amount: expense,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _summaryCard(
                          title: 'Balance',
                          amount: balance,
                          color:
                          balance >= 0 ? Colors.blue : Colors.orange,
                          fullWidth: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ================= CATEGORY BREAKDOWN =================
                    const Text(
                      'Spending by Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (categoryData.isEmpty)
                      const Text('No expense data available')
                    else
                      _buildCategoryBars(categoryData),

                    const SizedBox(height: 24),

                    // ================= SMART INSIGHTS =================
                    const Text(
                      'Insights',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildInsightsText(
                      income: income,
                      expense: expense,
                      categoryData: categoryData,
                    ),
                  ],
                ),
                      ),
                  ),
              );

            },
          ),
        ),
      ],
    );
  }

  // ================= SUMMARY CARD =================
  Widget _summaryCard({
    required String title,
    required double amount,
    required Color color,
    bool fullWidth = false,
  }) {
    return Expanded(
      flex: fullWidth ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.1,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Rs ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ================= CATEGORY BARS =================
  Widget _buildCategoryBars(Map<String, double> data) {
    final maxAmount =
    data.values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: data.entries.map((entry) {
        final percent = entry.value / maxAmount;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(entry.key),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percent,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('Rs${entry.value.toStringAsFixed(0)}'),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ================= SMART INSIGHTS =================
  Widget _buildInsightsText({
    required double income,
    required double expense,
    required Map<String, double> categoryData,
  }) {
    if (income == 0 && expense == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'No data yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add income or expenses to see insights for this month.',
            ),
          ],
        ),
      );
    }


    final spendingRate =
    income == 0 ? 1 : (expense / income);

    String spendingInsight;
    if (spendingRate > 0.9) {
      spendingInsight =
      'You spent most of your income this month. Try reducing expenses.';
    } else if (spendingRate > 0.6) {
      spendingInsight =
      'Your spending is moderate. You can improve savings.';
    } else {
      spendingInsight =
      'Great job! You are saving a good portion of your income.';
    }

    String categoryInsight = '';
    if (categoryData.isNotEmpty) {
      final topCategory = categoryData.entries.reduce(
            (a, b) => a.value > b.value ? a : b,
      );
      categoryInsight =
      'Highest spending category: ${topCategory.key}.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(spendingInsight),
          const SizedBox(height: 8),
          Text(categoryInsight),
        ],
      ),
    );
  }
}
