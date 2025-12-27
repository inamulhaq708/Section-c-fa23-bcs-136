import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/db/database_helper.dart';
import '../../data/models/goal_model.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _targetDate;

  void _saveGoal() async {
    if (_titleController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _targetDate == null) return;

    final goal = GoalModel(
      title: _titleController.text,
      targetAmount: double.parse(_amountController.text),
      savedAmount: 0,
      targetDate: DateFormat('yyyy-MM-dd').format(_targetDate!),
    );

    await DatabaseHelper.instance.insertGoal(goal);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Goal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Goal Title'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration:
              const InputDecoration(labelText: 'Target Amount'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _targetDate = picked);
              },
              child: const Text('Select Target Date'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveGoal,
              child: const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }
}
