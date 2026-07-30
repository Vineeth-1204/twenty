import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class AddExpenseSheet extends StatefulWidget {
  final Function(TransactionItem transaction) onAddTransaction;
  final String? initialMerchant;
  final String? initialCategoryId;
  final PaymentMode? initialPaymentMode;

  const AddExpenseSheet({
    super.key,
    required this.onAddTransaction,
    this.initialMerchant,
    this.initialCategoryId,
    this.initialPaymentMode,
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  PaymentMode _selectedPaymentMode = PaymentMode.gpayUpi;
  String _selectedCategoryId = 'food';

  @override
  void initState() {
    super.initState();
    if (widget.initialMerchant != null) {
      _titleController.text = widget.initialMerchant!;
    }
    if (widget.initialCategoryId != null) {
      _selectedCategoryId = widget.initialCategoryId!;
    }
    if (widget.initialPaymentMode != null) {
      _selectedPaymentMode = widget.initialPaymentMode!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitData() {
    final amountText = _amountController.text.trim();
    final titleText = _titleController.text.trim();

    if (amountText.isEmpty || titleText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid amount and payee/title'),
          backgroundColor: AppColors.googleRed,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a positive amount'),
          backgroundColor: AppColors.googleRed,
        ),
      );
      return;
    }

    final newTransaction = TransactionItem(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: titleText,
      amount: amount,
      date: DateTime.now(),
      categoryId: _selectedCategoryId,
      type: _selectedType,
      paymentMode: _selectedPaymentMode,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    widget.onAddTransaction(newTransaction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Transaction',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),

                // Expense / Income Segmented Switch
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _selectedType = TransactionType.expense),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedType == TransactionType.expense
                                ? AppColors.googleRed
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            'Expense',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedType == TransactionType.expense
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _selectedType = TransactionType.income),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedType == TransactionType.income
                                ? AppColors.googleTeal
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            'Income',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedType == TransactionType.income
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Amount Input (Large Google Pay Style)
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                hintText: '0.00',
                hintStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 12),

            // Payee / Title Input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Payee / Merchant / Description',
                hintText: 'e.g. Starbucks, Local Grocery, Rent',
                prefixIcon: const Icon(Icons.storefront_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),

            // Payment Mode Selector (Highlighting Cash & GPay)
            Text(
              'Payment Mode',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: PaymentMode.values.map((mode) {
                  final isSelected = _selectedPaymentMode == mode;
                  final isCash = mode == PaymentMode.cash;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Row(
                        children: [
                          Icon(
                            TransactionItem.paymentModeIcon(mode),
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : (isCash ? AppColors.cashColor : AppColors.googleBlue),
                          ),
                          const SizedBox(width: 6),
                          Text(TransactionItem.paymentModeLabel(mode)),
                        ],
                      ),
                      selectedColor: isCash ? AppColors.cashColor : AppColors.googleBlue,
                      onSelected: (_) => setState(() => _selectedPaymentMode = mode),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Category Picker Chips
            Text(
              'Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: CategoryItem.defaultCategories.map((cat) {
                  final isSelected = _selectedCategoryId == cat.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      avatar: Icon(cat.icon, size: 16, color: isSelected ? Colors.white : cat.color),
                      label: Text(cat.name),
                      selectedColor: cat.color,
                      onSelected: (_) => setState(() => _selectedCategoryId = cat.id),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Notes / Optional tag
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'e.g. Dinner with team',
                prefixIcon: const Icon(Icons.notes_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button (GPay Styled Rounded Pill)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.googleBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded),
                    SizedBox(width: 8),
                    Text(
                      'Save Transaction',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
