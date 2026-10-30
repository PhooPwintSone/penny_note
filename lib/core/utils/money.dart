import 'package:intl/intl.dart';

/// The currencies Penny Note supports.
///
/// Currency metadata and formatting live here so every screen shows the same
/// code, symbol, and decimal precision.
enum AppCurrency {
  mmk(code: 'MMK', name: 'Myanmar Kyat', symbol: 'Ks', decimalDigits: 0),
  usd(code: 'USD', name: 'US Dollar', symbol: r'$', decimalDigits: 2),
  cad(code: 'CAD', name: 'Canadian Dollar', symbol: r'C$', decimalDigits: 2),
  sgd(code: 'SGD', name: 'Singapore Dollar', symbol: r'S$', decimalDigits: 2),
  thb(code: 'THB', name: 'Thai Baht', symbol: '฿', decimalDigits: 2);

  const AppCurrency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimalDigits,
  });

  final String code;
  final String name;
  final String symbol;

  /// The usual number of decimal places for the currency.
  ///
  /// MMK normally has no minor unit. The formatter still shows two decimals
  /// when a stored amount has fractional kyat, so existing ledger values are
  /// never rounded away in the UI.
  final int decimalDigits;

  /// Returns the matching currency, falling back to the default MMK.
  static AppCurrency fromCode(String code) {
    return values.firstWhere(
      (currency) => currency.code == code,
      orElse: () => AppCurrency.mmk,
    );
  }
}

/// Default currency aliases kept for callers that need the initial values.
const currencyCode = 'MMK';
const currencySymbol = 'Ks';

final Map<String, NumberFormat> _formatters = {};

NumberFormat _formatterFor(AppCurrency currency, int decimalDigits) {
  final key = '${currency.code}:$decimalDigits';
  return _formatters.putIfAbsent(
    key,
    () => NumberFormat.currency(
      locale: 'en_US',
      symbol: '${currency.symbol} ',
      decimalDigits: decimalDigits,
    ),
  );
}

/// Formats an amount stored in cents, e.g. `123450` -> `Ks 1,234.50`.
///
/// MMK omits ".00" for whole amounts because everyday prices rarely use
/// decimals. Other supported currencies always use their two decimal places.
String formatCents(int cents, [AppCurrency currency = AppCurrency.mmk]) {
  final decimalDigits = currency == AppCurrency.mmk && cents % 100 != 0
      ? 2
      : currency.decimalDigits;
  return _formatterFor(currency, decimalDigits).format(cents / 100);
}

/// Formats cents for an editable amount field, without the currency symbol.
String formatCentsForInput(int cents) {
  final negative = cents < 0;
  final absolute = cents.abs();
  final fraction = (absolute % 100).toString().padLeft(2, '0');
  return '${negative ? '-' : ''}${absolute ~/ 100}.$fraction';
}

/// Parses a user-entered amount into cents.
///
/// Returns `null` for anything that is not a positive amount with at most two
/// decimal places, so the form can show a validation error.
/// Accepts both `12.5` and `12.50`, and ignores thousands separators.
int? parseAmountToCents(String input) {
  final normalized = input.trim().replaceAll(',', '');
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(normalized)) return null;

  final parts = normalized.split('.');
  final whole = int.tryParse(parts.first);
  final fractionText = parts.length == 2 ? parts[1].padRight(2, '0') : '00';
  final fraction = int.tryParse(fractionText);
  if (whole == null || fraction == null) return null;

  final cents = whole * 100 + fraction;
  return cents > 0 ? cents : null;
}
