import '../models/expense.dart';
import '../utils/database_helper.dart';

class ExpenseController {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insertExpense(Expense expense) async {
    final db = await _databaseHelper.database;

    return db.insert(
      'expenses',
      expense.toMap(),
    );
  }

  Future<List<Expense>> getExpenses() async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'expenses',
      orderBy: 'id DESC',
    );

    return result.map((map) => Expense.fromMap(map)).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await _databaseHelper.database;

    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await _databaseHelper.database;

    return db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}