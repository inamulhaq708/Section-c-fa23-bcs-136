import 'package:flutter/material.dart';
import '../../data/db/database_helper.dart';
import '../../data/models/budget_model.dart';
import 'package:intl/intl.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _amountController = TextEditingController();
  String _category = 'Food';

  void _saveBudget() async {
    if (_amountController.text.isEmpty) return;

    final month = DateFormat('yyyy-MM').format(DateTime.now());

    final budget = BudgetModel(
      category: _category,
      limitAmount: double.parse(_amountController.text),
      month: month,
    );

    await DatabaseHelper.instance.insertBudget(budget);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Budget')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField(
              value: _category,
              items: const [
                DropdownMenuItem(value: 'Food', child: Text('Food')),
                DropdownMenuItem(value: 'Travel', child: Text('Travel')),
                DropdownMenuItem(value: 'Shopping', child: Text('Shopping')),
                DropdownMenuItem(value: 'Bills', child: Text('Bills')),
              ],
              onChanged: (value) {
                setState(() => _category = value!);
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration:
              const InputDecoration(labelText: 'Monthly Limit'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveBudget,
              child: const Text('Save Budget'),
            ),
          ],
        ),
      ),
    );
  }
}
