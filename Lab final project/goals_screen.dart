import 'package:flutter/material.dart';
import '../../data/db/database_helper.dart';
import '../../data/models/goal_model.dart';
import 'add_goal_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  Future<List<GoalModel>> _loadGoals() {
    return DatabaseHelper.instance.getGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: FutureBuilder(
        future: _loadGoals(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final goals = snapshot.data as List<GoalModel>;

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.flag, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No goals yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Tap + to create your first goal'),
                ],
              ),
            );
          }


          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (_, index) {
              final goal = goals[index];
              final progress =
                  goal.savedAmount / goal.targetAmount;

              return Container(
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
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.clamp(0, 1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs ${goal.savedAmount} / Rs ${goal.targetAmount}',
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final controller =
                        TextEditingController();
                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title:
                            const Text('Add Savings'),
                            content: TextField(
                              controller: controller,
                              keyboardType:
                              TextInputType.number,
                              decoration:
                              const InputDecoration(
                                labelText: 'Amount',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context),
                                child:
                                const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final add = double.parse(
                                      controller.text);
                                  await DatabaseHelper.instance
                                      .updateGoalAmount(
                                    goal.id!,
                                    goal.savedAmount + add,
                                  );
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Add Savings'),
                    )
                  ],
                ),
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
              builder: (_) => const AddGoalScreen(),
            ),
          );
          if (result == true) setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
