import 'package:flutter/material.dart';
import '../../data/db/database_helper.dart';
import '../../data/models/transaction_model.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<List<TransactionModel>> _load(String type) {
    return DatabaseHelper.instance.getTransactions(type);
  }

  Widget _buildList(String type) {
    return FutureBuilder(
      future: _load(type),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data as List<TransactionModel>;

        if (data.isEmpty) {
          return const Center(child: Text('No transactions'));
        }

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (_, index) {
            final t = data[index];
            return ListTile(
              title: Text(t.title),
              subtitle: Text(t.category),
              trailing: Text(
                '₹${t.amount}',
                style: TextStyle(
                  color: t.type == 'income'
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              onLongPress: () async {
                await DatabaseHelper.instance.deleteTransaction(t.id!);
                setState(() {});
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'Expense'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList('income'),
          _buildList('expense'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final type =
          _tabController.index == 0 ? 'income' : 'expense';

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionScreen(type: type),
            ),
          );

          if (result == true) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
