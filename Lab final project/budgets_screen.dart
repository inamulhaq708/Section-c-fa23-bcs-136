import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/db/database_helper.dart';
import '../../data/models/budget_model.dart';
import 'add_budget_screen.dart';
import '../../core/notifications/notification_service.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  late String _month;

  /// prevents repeated notifications
  final Set<int> _notifiedBudgets = {};

  @override
  void initState() {
    super.initState();
    _month = DateFormat('yyyy-MM').format(DateTime.now());
  }

  Future<List<BudgetModel>> _loadBudgets() {
    return DatabaseHelper.instance.getBudgets(_month);
  }

  // 🗑 DELETE BUDGET
  Future<void> _deleteBudget(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
    _notifiedBudgets.remove(id);
    setState(() {});
  }

  Color _progressColor(double progress) {
    if (progress >= 1) return Colors.red;
    if (progress >= 0.8) return Colors.orange;
    return Colors.green;
  }

  String _statusText(double progress) {
    if (progress >= 1) return 'Exceeded';
    if (progress >= 0.8) return 'Warning';
    return 'Safe';
  }

  void _sendBudgetNotification(BudgetModel budget, double spent) {
    if (_notifiedBudgets.contains(budget.id)) return;

    _notifiedBudgets.add(budget.id!);

    NotificationService.showNotification(
      title: 'Budget Exceeded 🚨',
      body:
      '${budget.category} budget exceeded.\nSpent ₹${spent.toStringAsFixed(0)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: FutureBuilder<List<BudgetModel>>(
        future: _loadBudgets(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final budgets = snapshot.data!;

          if (budgets.isEmpty) {
            return const Center(
              child: Text(
                'No budgets set',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (_, index) {
              final budget = budgets[index];

              return FutureBuilder<double>(
                future: DatabaseHelper.instance.getSpentForCategory(
                  budget.category,
                  _month,
                ),
                builder: (_, spentSnapshot) {
                  final double spent =
                  (spentSnapshot.data ?? 0).toDouble();

                  final double progress =
                  (spent / budget.limitAmount).clamp(0.0, 2.0);

                  // 🔔 Trigger notification once
                  if (progress >= 1 && budget.id != null) {
                    _sendBudgetNotification(budget, spent);
                  }

                  return Dismissible(
                    key: ValueKey(budget.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      padding: const EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Budget'),
                          content: const Text(
                              'Are you sure you want to delete this budget?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) => _deleteBudget(budget.id!),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                budget.category,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _progressColor(progress)
                                      .withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _statusText(progress),
                                  style: TextStyle(
                                    color: _progressColor(progress),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: progress > 1 ? 1 : progress,
                            minHeight: 8,
                            color: _progressColor(progress),
                            backgroundColor:
                            Colors.grey.shade200,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Rs ${spent.toStringAsFixed(0)} spent of Rs ${budget.limitAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (progress >= 1)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(
                                'You have exceeded this budget!',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddBudgetScreen(),
            ),
          );

          if (result == true) setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
