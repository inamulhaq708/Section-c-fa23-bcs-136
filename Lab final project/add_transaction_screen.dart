import 'package:flutter/material.dart';
import '../../../data/db/database_helper.dart';
import '../../../data/models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final String type; // income or expense

  const AddTransactionScreen({super.key, required this.type});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // Categories ONLY for expenses
  final List<String> _categories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Entertainment',
    'Other',
  ];

  String _selectedCategory = 'Food';

  void _saveTransaction() async {
    if (_titleController.text.isEmpty ||
        _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final transaction = TransactionModel(
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      type: widget.type,
      category: widget.type == 'expense'
          ? _selectedCategory
          : 'Income',
      date: DateTime.now().toIso8601String(),
      note: _noteController.text.trim(),
    );

    await DatabaseHelper.instance.insertTransaction(transaction);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.type.capitalize()}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ===== TITLE =====
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),

                // ===== AMOUNT =====
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                ),
                const SizedBox(height: 16),

                // ===== CATEGORY (ONLY FOR EXPENSE) =====
                if (widget.type == 'expense')
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories
                        .map(
                          (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),

                if (widget.type == 'expense')
                  const SizedBox(height: 16),

                // ===== NOTE =====
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),

                const SizedBox(height: 32),

                // ===== SAVE BUTTON =====
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Save Transaction',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() =>
      "${this[0].toUpperCase()}${substring(1)}";
}
