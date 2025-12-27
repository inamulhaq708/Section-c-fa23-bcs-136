import '../models/goal_model.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  // ================= DATABASE INIT =================

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finova.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        type TEXT,
        category TEXT,
        date TEXT,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT,
        limit_amount REAL,
        month TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        target_amount REAL,
        saved_amount REAL,
        target_date TEXT
      )
    ''');
  }

  // ================= TRANSACTIONS =================

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions(String type) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );

    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= TOTALS =================

  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type='income'",
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalExpense() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type='expense'",
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // ================= MONTHLY TOTALS =================

  Future<double> getMonthlyIncome(int year, int month) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions
      WHERE type='income'
      AND strftime('%Y', date)=?
      AND strftime('%m', date)=?
    ''', [year.toString(), month.toString().padLeft(2, '0')]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getMonthlyExpense(int year, int month) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions
      WHERE type='expense'
      AND strftime('%Y', date)=?
      AND strftime('%m', date)=?
    ''', [year.toString(), month.toString().padLeft(2, '0')]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // ================= CATEGORY EXPENSE =================

  Future<Map<String, double>> getCategoryExpense(
      int year, int month) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total FROM transactions
      WHERE type='expense'
      AND strftime('%Y', date)=?
      AND strftime('%m', date)=?
      GROUP BY category
    ''', [year.toString(), month.toString().padLeft(2, '0')]);

    final Map<String, double> data = {};
    for (var row in result) {
      data[row['category'] as String] =
          (row['total'] as num).toDouble();
    }
    return data;
  }

  // ================= BUDGETS =================

  Future<int> insertBudget(BudgetModel budget) async {
    final db = await database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<List<BudgetModel>> getBudgets(String month) async {
    final db = await database;
    final result = await db.query(
      'budgets',
      where: 'month = ?',
      whereArgs: [month],
    );

    return result.map((e) => BudgetModel.fromMap(e)).toList();
  }

  /// 🔔 IMPORTANT: This is what connects transactions → budgets
  Future<double> getSpentForCategory(
      String category, String month) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions
      WHERE type='expense'
      AND category=?
      AND date LIKE ?
    ''', [category, '$month%']);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // ================= GOALS =================

  Future<int> insertGoal(GoalModel goal) async {
    final db = await database;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<GoalModel>> getGoals() async {
    final db = await database;
    final result = await db.query('goals');
    return result.map((e) => GoalModel.fromMap(e)).toList();
  }

  Future<int> updateGoalAmount(int id, double newAmount) async {
    final db = await database;
    return await db.update(
      'goals',
      {'saved_amount': newAmount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
