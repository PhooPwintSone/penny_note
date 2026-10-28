import 'package:intl/intl.dart';

/// Myanmar Kyat is the app's only currency.
const currencyCode = 'MMK';
const currencySymbol = 'K';

final NumberFormat _wholeCurrency = NumberFormat.currency(
  locale: 'en_US',
  symbol: '$currencySymbol ',
  decimalDigits: 0,
);

final NumberFormat _fractionCurrency = NumberFormat.currency(
  locale: 'en_US',
  symbol: '$currencySymbol ',
  decimalDigits: 2,
);

/// Formats an amount stored in cents, e.g. `123450` -> `K 1,234.50`.
///
/// Whole amounts omit ".00" because everyday MMK prices rarely use decimals.
String formatCents(int cents) {
  final formatter = cents % 100 == 0 ? _wholeCurrency : _fractionCurrency;
  return formatter.format(cents / 100);
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
