import 'package:intl/intl.dart';

final NumberFormat _currency = NumberFormat.currency(
  locale: 'en_US',
  symbol: r'$',
  decimalDigits: 2,
);

/// Formats an amount stored in cents, e.g. `123450` -> `$1,234.50`.
String formatCents(int cents) => _currency.format(cents / 100);

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
