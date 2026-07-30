import '../models/transaction.dart';

class SmsParseResult {
  final bool isFinancial;
  final String? merchant;
  final double? amount;
  final TransactionType type;
  final PaymentMode paymentMode;
  final String? accountTail;
  final String categoryId;
  final String rawSms;

  SmsParseResult({
    required this.isFinancial,
    this.merchant,
    this.amount,
    this.type = TransactionType.expense,
    this.paymentMode = PaymentMode.gpayUpi,
    this.accountTail,
    this.categoryId = 'misc',
    required this.rawSms,
  });
}

class SmsParserService {
  static SmsParseResult parseSms(String smsText) {
    if (smsText.trim().isEmpty) {
      return SmsParseResult(isFinancial: false, rawSms: smsText);
    }

    final lowerText = smsText.toLowerCase();

    // Check financial keywords
    final hasFinancialKeyword = lowerText.contains('spent') ||
        lowerText.contains('debited') ||
        lowerText.contains('paid') ||
        lowerText.contains('transferred') ||
        lowerText.contains('credited') ||
        lowerText.contains('received') ||
        lowerText.contains('upi') ||
        lowerText.contains('gpay') ||
        lowerText.contains('a/c');

    if (!hasFinancialKeyword) {
      return SmsParseResult(isFinancial: false, rawSms: smsText);
    }

    // Determine Expense vs Income
    final isIncome = lowerText.contains('credited') ||
        lowerText.contains('received') ||
        lowerText.contains('deposited');
    final type = isIncome ? TransactionType.income : TransactionType.expense;

    // Extract Amount (e.g. Rs 250.00, INR 1,499, ₹500, Rs. 850)
    double? amount;
    final amountRegex = RegExp(
      r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );
    final match = amountRegex.firstMatch(smsText);
    if (match != null) {
      final rawAmountStr = match.group(1)!.replaceAll(',', '');
      amount = double.tryParse(rawAmountStr);
    }

    // Extract Merchant / Payee Name
    String merchant = 'Unknown Merchant';
    final toPayeeRegex = RegExp(
      r'(?:to|at|info:)\s+([A-Za-z0-9\s&.\-]+?)(?=\s+(?:on|ref|vpa|via|bal|avl|a/c|dated|for|\.|$))',
      caseSensitive: false,
    );
    final merchantMatch = toPayeeRegex.firstMatch(smsText);
    if (merchantMatch != null) {
      final rawMerchant = merchantMatch.group(1)!.trim();
      if (rawMerchant.length > 2 && rawMerchant.length < 30) {
        merchant = _cleanMerchantName(rawMerchant);
      }
    }

    // Extract Account Tail (e.g., A/C XX4821 or ending 1234)
    String? accountTail;
    final acRegex = RegExp(
      r'(?:a/c|acct|card|ending)\s*([Xx]*\d{3,4})',
      caseSensitive: false,
    );
    final acMatch = acRegex.firstMatch(smsText);
    if (acMatch != null) {
      accountTail = acMatch.group(1);
    }

    // Determine Payment Mode
    PaymentMode paymentMode = PaymentMode.gpayUpi;
    if (lowerText.contains('cash')) {
      paymentMode = PaymentMode.cash;
    } else if (lowerText.contains('credit card')) {
      paymentMode = PaymentMode.creditCard;
    } else if (lowerText.contains('debit card') || lowerText.contains('card')) {
      paymentMode = PaymentMode.debitCard;
    } else if (lowerText.contains('netbanking') || lowerText.contains('neft') || lowerText.contains('rtgs')) {
      paymentMode = PaymentMode.netBanking;
    } else if (lowerText.contains('upi') || lowerText.contains('gpay') || lowerText.contains('phonepe') || lowerText.contains('paytm')) {
      paymentMode = PaymentMode.gpayUpi;
    }

    // Determine Category
    final categoryId = _autoCategorize(merchant, lowerText);

    return SmsParseResult(
      isFinancial: amount != null && amount > 0,
      merchant: merchant,
      amount: amount,
      type: type,
      paymentMode: paymentMode,
      accountTail: accountTail,
      categoryId: categoryId,
      rawSms: smsText,
    );
  }

  static String _cleanMerchantName(String text) {
    return text
        .replaceAll(RegExp(r'\b(Pvt|Ltd|Inc|Corp|UPI|VPA|Ref|Trx)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .trim();
  }

  static String _autoCategorize(String merchant, String lowerText) {
    final combined = '$merchant $lowerText'.toLowerCase();

    if (combined.contains('starbucks') ||
        combined.contains('swiggy') ||
        combined.contains('zomato') ||
        combined.contains('mcdonald') ||
        combined.contains('restaurant') ||
        combined.contains('cafe') ||
        combined.contains('food')) {
      return 'food';
    }
    if (combined.contains('blinkit') ||
        combined.contains('zepto') ||
        combined.contains('grocery') ||
        combined.contains('supermarket') ||
        combined.contains('mart')) {
      return 'groceries';
    }
    if (combined.contains('uber') ||
        combined.contains('ola') ||
        combined.contains('rapido') ||
        combined.contains('fuel') ||
        combined.contains('petrol') ||
        combined.contains('metro') ||
        combined.contains('cab')) {
      return 'transport';
    }
    if (combined.contains('amazon') ||
        combined.contains('flipkart') ||
        combined.contains('myntra') ||
        combined.contains('zara') ||
        combined.contains('mall') ||
        combined.contains('store')) {
      return 'shopping';
    }
    if (combined.contains('electricity') ||
        combined.contains('water') ||
        combined.contains('bill') ||
        combined.contains('airtel') ||
        combined.contains('jio') ||
        combined.contains('recharge')) {
      return 'bills';
    }
    if (combined.contains('netflix') ||
        combined.contains('spotify') ||
        combined.contains('prime') ||
        combined.contains('bookmyshow') ||
        combined.contains('cinema')) {
      return 'subscriptions';
    }
    if (combined.contains('cash') || combined.contains('atm') || combined.contains('withdrawn')) {
      return 'cash';
    }

    return 'misc';
  }

  // Pre-built sample SMS templates for simulation testing
  static const List<String> sampleSmsList = [
    "Paid Rs. 250.00 via UPI on Google Pay to STARBUCKS COFFEE on 30-Jul-26. Ref: 421098231.",
    "Spent Rs. 1,499.00 at AMAZON INDIA using HDFC Credit Card XX4821 on 30-Jul-26. Avail Bal: Rs 42,500.",
    "A/C XX9012 Debited for Rs. 850.00 to SWIGGY FOOD via PhonePe. Avail Bal: Rs 15,200.",
    "Rs. 320.00 paid to UBER RIDES using Paytm UPI on 29-Jul-26.",
    "Alert: Cash withdrawn Rs 2,000.00 from ATM XX3412 on 28-Jul-26. Avail Bal: Rs 12,500.",
    "Rs 499.00 debited for NETFLIX DIGITAL SUBSCRIPTION on 27-Jul-26.",
    "Salary Credited! Rs. 65,000.00 received from ACME CORP in A/C XX9012 on 25-Jul-26.",
  ];
}
