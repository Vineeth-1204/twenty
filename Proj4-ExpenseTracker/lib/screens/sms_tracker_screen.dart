import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/transaction.dart';
import '../services/sms_parser_service.dart';

class SmsTrackerScreen extends StatefulWidget {
  final Function(TransactionItem transaction) onAutoParsedTransaction;

  const SmsTrackerScreen({super.key, required this.onAutoParsedTransaction});

  @override
  State<SmsTrackerScreen> createState() => _SmsTrackerScreenState();
}

class _SmsTrackerScreenState extends State<SmsTrackerScreen> {
  final _smsInputController = TextEditingController();
  SmsParseResult? _lastResult;

  @override
  void dispose() {
    _smsInputController.dispose();
    super.dispose();
  }

  void _parseText(String text) {
    setState(() {
      _lastResult = SmsParserService.parseSms(text);
    });
  }

  void _addParsedTransaction() {
    if (_lastResult == null || !_lastResult!.isFinancial || _lastResult!.amount == null) return;

    final newTransaction = TransactionItem(
      id: 'sms_${DateTime.now().millisecondsSinceEpoch}',
      title: _lastResult!.merchant ?? 'Bank SMS Transaction',
      amount: _lastResult!.amount!,
      date: DateTime.now(),
      categoryId: _lastResult!.categoryId,
      type: _lastResult!.type,
      paymentMode: _lastResult!.paymentMode,
      accountTail: _lastResult!.accountTail,
      isAutoParsed: true,
      rawSms: _lastResult!.rawSms,
    );

    widget.onAutoParsedTransaction(newTransaction);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Logged ₹${_lastResult!.amount!.toStringAsFixed(0)} at ${_lastResult!.merchant}!',
        ),
        backgroundColor: AppColors.googleTeal,
      ),
    );

    setState(() {
      _smsInputController.clear();
      _lastResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.googleTeal, size: 20),
            SizedBox(width: 8),
            Text('Auto Bank SMS Parser'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // How Auto-tracking works banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.googleTealLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.googleTeal.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.mark_email_read_rounded, color: AppColors.googleTeal, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Automatic Expense Detection',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.googleTeal,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'On Android devices, incoming SMS notifications from HDFC, SBI, ICICI, GPay, and PhonePe are parsed automatically to log transactions instantly without manual entry.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.lightTextPrimary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Simulator / Tester Card
            Text(
              'Test SMS Engine Simulator',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _smsInputController,
                    maxLines: 3,
                    onChanged: _parseText,
                    decoration: InputDecoration(
                      hintText: 'Paste incoming bank SMS string here...\n(e.g., "Paid Rs 250 via GPay to Starbucks")',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Sample Buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text(
                          'Try sample: ',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        ...SmsParserService.sampleSmsList.take(3).map((sample) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text(
                                sample.length > 22 ? '${sample.substring(0, 22)}...' : sample,
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                _smsInputController.text = sample;
                                _parseText(sample);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Parsed Output Preview Card
            if (_lastResult != null) ...[
              Text(
                'Live Extracted Result',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _lastResult!.isFinancial
                      ? (_lastResult!.type == TransactionType.expense
                          ? AppColors.googleRedLight
                          : AppColors.googleTealLight)
                      : (isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: _lastResult!.isFinancial
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _lastResult!.merchant ?? 'Extracted Merchant',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                currency.format(_lastResult!.amount ?? 0),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _lastResult!.type == TransactionType.expense
                                      ? AppColors.googleRed
                                      : AppColors.googleTeal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Chip(
                                label: Text(TransactionItem.paymentModeLabel(_lastResult!.paymentMode)),
                                avatar: Icon(TransactionItem.paymentModeIcon(_lastResult!.paymentMode), size: 14),
                              ),
                              Chip(
                                label: Text(_lastResult!.categoryId.toUpperCase()),
                                avatar: const Icon(Icons.category_rounded, size: 14),
                              ),
                              if (_lastResult!.accountTail != null)
                                Chip(
                                  label: Text('A/C ${_lastResult!.accountTail}'),
                                  avatar: const Icon(Icons.credit_card_rounded, size: 14),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _addParsedTransaction,
                              icon: const Icon(Icons.add_task_rounded),
                              label: const Text('Log This Auto-Parsed Expense'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.googleTeal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.lightTextSecondary),
                          SizedBox(width: 8),
                          Text('No financial expense/amount detected in this text.'),
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
