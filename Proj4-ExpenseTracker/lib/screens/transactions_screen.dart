import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/transaction.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  final List<TransactionItem> transactions;
  final Function(String id) onDeleteTransaction;

  const TransactionsScreen({
    super.key,
    required this.transactions,
    required this.onDeleteTransaction,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  PaymentMode? _selectedModeFilter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    var filtered = widget.transactions.where((t) {
      final matchesSearch = t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.notes != null && t.notes!.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesMode = _selectedModeFilter == null || t.paymentMode == _selectedModeFilter;
      return matchesSearch && matchesMode;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search merchant, payee, or notes...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        selected: _selectedModeFilter == null,
                        label: const Text('All Payments'),
                        onSelected: (_) => setState(() => _selectedModeFilter = null),
                      ),
                      const SizedBox(width: 6),
                      ...PaymentMode.values.map((mode) {
                        final isSelected = _selectedModeFilter == mode;
                        final isCash = mode == PaymentMode.cash;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            selected: isSelected,
                            avatar: Icon(
                              TransactionItem.paymentModeIcon(mode),
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : (isCash ? AppColors.cashColor : AppColors.googleBlue),
                            ),
                            label: Text(TransactionItem.paymentModeLabel(mode)),
                            selectedColor: isCash ? AppColors.cashColor : AppColors.googleBlue,
                            onSelected: (_) => setState(() {
                              _selectedModeFilter = isSelected ? null : mode;
                            }),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transactions Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} Entries found',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  'Swipe left to delete',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          // List View
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No matching transactions found'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return TransactionTile(
                        transaction: item,
                        onDelete: () => widget.onDeleteTransaction(item.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
