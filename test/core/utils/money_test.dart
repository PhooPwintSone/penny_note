import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/utils/money.dart';

void main() {
  group('formatCents', () {
    test('formats zero in Myanmar Kyat', () {
      expect(formatCents(0), 'K 0');
    });

    test('formats cents with thousands separators and decimals', () {
      expect(formatCents(123450), 'K 1,234.50');
    });

    test('omits unnecessary decimals for whole kyat', () {
      expect(formatCents(123400), 'K 1,234');
    });
  });

  group('formatCentsForInput', () {
    test('formats cents without a currency symbol', () {
      expect(formatCentsForInput(123450), '1234.50');
      expect(formatCentsForInput(1200), '12.00');
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
