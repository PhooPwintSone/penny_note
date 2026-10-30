import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/utils/money.dart';

void main() {
  group('AppCurrency', () {
    test('contains exactly the five supported currencies', () {
      expect(AppCurrency.values, hasLength(5));
      expect(AppCurrency.values.map((currency) => currency.code), [
        'MMK',
        'USD',
        'CAD',
        'SGD',
        'THB',
      ]);
      expect(AppCurrency.mmk.name, 'Myanmar Kyat');
      expect(AppCurrency.mmk.symbol, 'Ks');
      expect(AppCurrency.usd.symbol, r'$');
      expect(AppCurrency.cad.symbol, r'C$');
      expect(AppCurrency.sgd.symbol, r'S$');
      expect(AppCurrency.thb.symbol, '฿');
    });

    test('defaults unknown codes to MMK', () {
      expect(AppCurrency.fromCode('MMK'), AppCurrency.mmk);
      expect(AppCurrency.fromCode('EUR'), AppCurrency.mmk);
    });
  });

  group('formatCents', () {
    test('defaults to Myanmar Kyat', () {
      expect(formatCents(0), 'Ks 0');
    });

    test('formats Myanmar Kyat with thousands separators', () {
      expect(formatCents(123450, AppCurrency.mmk), 'Ks 1,234.50');
      expect(formatCents(123400, AppCurrency.mmk), 'Ks 1,234');
    });

    test('formats US Dollars with two decimal places', () {
      expect(formatCents(0, AppCurrency.usd), r'$ 0.00');
      expect(formatCents(123450, AppCurrency.usd), r'$ 1,234.50');
      expect(formatCents(123400, AppCurrency.usd), r'$ 1,234.00');
    });

    test('formats Canadian Dollars with two decimal places', () {
      expect(formatCents(123450, AppCurrency.cad), r'C$ 1,234.50');
    });

    test('formats Singapore Dollars with two decimal places', () {
      expect(formatCents(123450, AppCurrency.sgd), r'S$ 1,234.50');
    });

    test('formats Thai Baht with two decimal places', () {
      expect(formatCents(123450, AppCurrency.thb), '฿ 1,234.50');
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
