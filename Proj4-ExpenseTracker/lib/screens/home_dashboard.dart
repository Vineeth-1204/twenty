import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/budget_card.dart';
import '../widgets/quick_payees_bar.dart';
import '../widgets/transaction_tile.dart';
import 'analytics_screen.dart';
import 'bill_splitter_screen.dart';
import 'sms_tracker_screen.dart';
import 'subscriptions_screen.dart';
import 'transactions_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _currentBottomNavIndex = 0;
  bool _isDarkTheme = false;
  bool _isLoading = true;

  List<TransactionItem> _transactions = [];
  BudgetModel _budget = BudgetModel.defaultBudget();

  @override
  void initState() {
    super.initState();
    _loadAppData();
  }

  Future<void> _loadAppData() async {
    final loadedTransactions = await StorageService.loadTransactions();
    final loadedBudget = await StorageService.loadBudget();
    final isDark = await StorageService.loadIsDarkTheme();

    setState(() {
      _transactions = loadedTransactions;
      _budget = loadedBudget;
      _isDarkTheme = isDark;
      _isLoading = false;
    });
  }

  Future<void> _toggleTheme() async {
    final newTheme = !_isDarkTheme;
    setState(() => _isDarkTheme = newTheme);
    await StorageService.saveIsDarkTheme(newTheme);
  }

  void _addTransaction(TransactionItem tx) {
    setState(() {
      _transactions.insert(0, tx);
    });
    StorageService.saveTransactions(_transactions);
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((t) => t.id == id);
    });
    StorageService.saveTransactions(_transactions);
  }

  void _openAddExpenseModal({
    String? initialMerchant,
    String? initialCategoryId,
    PaymentMode? initialPaymentMode,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _isDarkTheme ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => AddExpenseSheet(
        onAddTransaction: _addTransaction,
        initialMerchant: initialMerchant,
        initialCategoryId: initialCategoryId,
        initialPaymentMode: initialPaymentMode,
      ),
    );
  }

  void _showEditBudgetDialog() {
    final controller = TextEditingController(text: _budget.monthlyLimit.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Budget Limit'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Monthly Limit Amount',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newLimit = double.tryParse(controller.text.trim());
              if (newLimit != null && newLimit > 0) {
                final updatedBudget = BudgetModel(
                  monthlyLimit: newLimit,
                  categoryLimits: _budget.categoryLimits,
                );
                setState(() => _budget = updatedBudget);
                StorageService.saveBudget(updatedBudget);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save Limit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _transactions.where((t) => t.type == TransactionType.expense);
    final totalSpent = expenses.fold(0.0, (sum, t) => sum + t.amount);

    final totalCashSpent = expenses
        .where((t) => t.paymentMode == PaymentMode.cash)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalDigitalSpent = totalSpent - totalCashSpent;

    return Theme(
      data: _isDarkTheme
          ? ThemeData.dark().copyWith(
              primaryColor: AppColors.googleBlue,
              scaffoldBackgroundColor: AppColors.darkBg,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.darkSurface,
                elevation: 0,
              ),
            )
          : ThemeData.light().copyWith(
              primaryColor: AppColors.googleBlue,
              scaffoldBackgroundColor: AppColors.lightBg,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.lightSurface,
                elevation: 0,
              ),
            ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.googleBlue,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zenith Spend',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Google Pay Styled Mobile App',
                    style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SmsTrackerScreen(
                      onAutoParsedTransaction: _addTransaction,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome, color: AppColors.googleTeal),
              tooltip: 'Auto Bank SMS Parser',
            ),
            IconButton(
              onPressed: _toggleTheme,
              icon: Icon(_isDarkTheme ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              tooltip: 'Toggle Theme',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : IndexedStack(
                index: _currentBottomNavIndex,
                children: [
                  // Tab 0: Home Dashboard
                  RefreshIndicator(
                    onRefresh: _loadAppData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Monthly Budget Gauge Card
                          BudgetCard(
                            totalSpent: totalSpent,
                            totalCashSpent: totalCashSpent,
                            totalDigitalSpent: totalDigitalSpent,
                            budget: _budget,
                            onEditBudget: _showEditBudgetDialog,
                          ),

                          // 1-Tap Quick Payees Bar
                          QuickPayeesBar(
                            onSelectPayee: (payee) {
                              _openAddExpenseModal(
                                initialMerchant: payee.title,
                                initialCategoryId: payee.categoryId,
                                initialPaymentMode: payee.defaultMode,
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          // Quick Tools Cards Grid
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const BillSplitterScreen(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.googleTealLight,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.call_split_rounded,
                                              color: AppColors.googleTeal, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Split Bill',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.googleTeal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const SubscriptionsScreen(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.googlePurpleLight,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.subscriptions_rounded,
                                              color: AppColors.googlePurple, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Subs Manager',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.googlePurple,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Recent Transactions Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Activity',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _isDarkTheme
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => setState(() => _currentBottomNavIndex = 1),
                                  child: const Text('See All'),
                                ),
                              ],
                            ),
                          ),

                          // Recent Transactions List
                          if (_transactions.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(30),
                              child: Center(child: Text('No recent expenses. Tap + to add one!')),
                            )
                          else
                            ..._transactions.take(5).map((item) {
                              return TransactionTile(
                                transaction: item,
                                onDelete: () => _deleteTransaction(item.id),
                              );
                            }),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),

                  // Tab 1: History Feed Screen
                  TransactionsScreen(
                    transactions: _transactions,
                    onDeleteTransaction: _deleteTransaction,
                  ),

                  // Tab 2: Analytics Screen
                  AnalyticsScreen(transactions: _transactions),
                ],
              ),

        // Floating Action Button (+ Add Manual Expense / Cash)
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openAddExpenseModal(),
          backgroundColor: AppColors.googleBlue,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Expense / Cash',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // Google Pay Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentBottomNavIndex,
          onTap: (index) => setState(() => _currentBottomNavIndex = index),
          selectedItemColor: AppColors.googleBlue,
          unselectedItemColor: _isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_rounded),
              label: 'Insights',
            ),
          ],
        ),
      ),
    );
  }
}
