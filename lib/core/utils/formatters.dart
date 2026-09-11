import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: 'TZS ',
    decimalDigits: 0,
    locale: 'en_US',
  );

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');

  /// Formats double or int to Tanzanian Shillings string (e.g. TZS 50,000,000)
  static String formatCurrency(dynamic amount) {
    if (amount == null) return 'TZS 0';
    num numericAmount = 0;
    if (amount is num) {
      numericAmount = amount;
    } else if (amount is String) {
      numericAmount = num.tryParse(amount) ?? 0;
    }
    return _currencyFormatter.format(numericAmount);
  }

  /// Formats DateTime to standard display format (e.g. 10 Sep 2026)
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return _dateFormat.format(date);
  }

  /// Formats DateTime to full date time format
  static String formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return _dateTimeFormat.format(date);
  }

  /// Validates Tanzanian Phone Number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (cleanPhone.length < 9 || cleanPhone.length > 13) {
      return 'Enter a valid phone number (e.g. 0712345678 or +255712345678)';
    }
    return null;
  }

  /// Validates Email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
