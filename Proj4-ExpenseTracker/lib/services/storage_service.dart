import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/budget.dart';

class StorageService {
  static const String _transactionsKey = 'zenith_transactions_v1';
  static const String _budgetKey = 'zenith_budget_v1';
  static const String _themeKey = 'zenith_is_dark_theme_v1';

  // Load Transactions
  static Future<List<TransactionItem>> loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_transactionsKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        final initial = _getInitialSampleData();
        await saveTransactions(initial);
        return initial;
      }
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) => TransactionItem.fromJson(item)).toList();
    } catch (e) {
      return _getInitialSampleData();
    }
  }

  // Save Transactions
  static Future<void> saveTransactions(List<TransactionItem> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
          transactions.map((t) => t.toJson()).toList();
      await prefs.setString(_transactionsKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  // Load Budget
  static Future<BudgetModel> loadBudget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_budgetKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        return BudgetModel.defaultBudget();
      }
      return BudgetModel.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      return BudgetModel.defaultBudget();
    }
  }

  // Save Budget
  static Future<void> saveBudget(BudgetModel budget) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_budgetKey, jsonEncode(budget.toJson()));
    } catch (_) {}
  }

  // Load Theme
  static Future<bool> loadIsDarkTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_themeKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  // Save Theme
  static Future<void> saveIsDarkTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);
    } catch (_) {}
  }

  static List<TransactionItem> _getInitialSampleData() {
    final now = DateTime.now();
    return [
      TransactionItem(
        id: 't1',
        title: 'Starbucks Coffee',
        amount: 250.0,
        date: now.subtract(const Duration(hours: 2)),
        categoryId: 'food',
        type: TransactionType.expense,
        paymentMode: PaymentMode.gpayUpi,
        notes: 'Morning Cappuccino via GPay',
        isAutoParsed: true,
        accountTail: 'XX4821',
      ),
      TransactionItem(
        id: 't2',
        title: 'Auto Taxi Fare',
        amount: 180.0,
        date: now.subtract(const Duration(hours: 6)),
        categoryId: 'transport',
        type: TransactionType.expense,
        paymentMode: PaymentMode.cash,
        notes: 'Paid cash to driver',
      ),
      TransactionItem(
        id: 't3',
        title: 'Blinkit Grocery Order',
        amount: 940.0,
        date: now.subtract(const Duration(days: 1)),
        categoryId: 'groceries',
        type: TransactionType.expense,
        paymentMode: PaymentMode.gpayUpi,
        accountTail: 'XX9012',
        isAutoParsed: true,
      ),
      TransactionItem(
        id: 't4',
        title: 'Swiggy Dinner',
        amount: 620.0,
        date: now.subtract(const Duration(days: 1, hours: 4)),
        categoryId: 'food',
        type: TransactionType.expense,
        paymentMode: PaymentMode.creditCard,
        notes: 'Group dinner',
        accountTail: 'XX1104',
      ),
      TransactionItem(
        id: 't5',
        title: 'Local Fruit Vendor',
        amount: 120.0,
        date: now.subtract(const Duration(days: 2)),
        categoryId: 'cash',
        type: TransactionType.expense,
        paymentMode: PaymentMode.cash,
        notes: 'Fresh apples & bananas',
      ),
      TransactionItem(
        id: 't6',
        title: 'Electricity Bill',
        amount: 1850.0,
        date: now.subtract(const Duration(days: 4)),
        categoryId: 'bills',
        type: TransactionType.expense,
        paymentMode: PaymentMode.netBanking,
        accountTail: 'XX9012',
      ),
      TransactionItem(
        id: 't7',
        title: 'Monthly Salary Credited',
        amount: 65000.0,
        date: now.subtract(const Duration(days: 5)),
        categoryId: 'salary',
        type: TransactionType.income,
        paymentMode: PaymentMode.netBanking,
        accountTail: 'XX9012',
        isAutoParsed: true,
      ),
    ];
  }
}
