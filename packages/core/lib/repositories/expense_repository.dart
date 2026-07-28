import '../models/expense.dart';

abstract class ExpenseRepository {
  Future<void> submitExpense(Expense expense);
  Future<List<Expense>> getExpenses(String mrId);
  Future<List<Expense>> getPendingExpenses();
  Future<void> updateExpenseStatus(String expenseId, ExpenseStatus status, {String? approvedBy});
}
