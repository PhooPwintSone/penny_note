import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/utils/money.dart';

void main() {
  group('formatCents', () {
    test('formats zero as a complete currency value', () {
      expect(formatCents(0), r'$0.00');
    });

    test('formats cents with thousands separators', () {
      expect(formatCents(123450), r'$1,234.50');
    });
  });

  group('parseAmountToCents', () {
    test('accepts whole amounts', () {
      expect(parseAmountToCents('12'), 1200);
    });

    test('accepts one or two decimal places', () {
      expect(parseAmountToCents('12.5'), 1250);
      expect(parseAmountToCents('12.50'), 1250);
    });

    test('ignores surrounding whitespace and thousands separators', () {
      expect(parseAmountToCents(' 1,234.50 '), 123450);
    });

    test('rejects zero, negatives and invalid input', () {
      expect(parseAmountToCents('0'), isNull);
      expect(parseAmountToCents('0.00'), isNull);
      expect(parseAmountToCents('-5'), isNull);
      expect(parseAmountToCents('12.345'), isNull);
      expect(parseAmountToCents('abc'), isNull);
      expect(parseAmountToCents(''), isNull);
    });
  });
}
