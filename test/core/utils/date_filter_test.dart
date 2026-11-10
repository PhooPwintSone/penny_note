import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/utils/date_filter.dart';

void main() {
  final now = DateTime(2026, 11, 8, 15, 30);

  group('DateFilterSelection', () {
    test('defaults to the last 30 days', () {
      expect(DateFilterSelection.initial.preset, DateFilterPreset.last30Days);
    });

    test('today matches only the current calendar day', () {
      const filter = DateFilterSelection.today();

      expect(filter.matches(DateTime(2026, 11, 8), now), isTrue);
      expect(filter.matches(DateTime(2026, 11, 8, 23, 59), now), isTrue);
      expect(filter.matches(DateTime(2026, 11, 7), now), isFalse);
      expect(filter.matches(DateTime(2026, 11, 9), now), isFalse);
    });

    test('last 7 days includes today and the previous six days', () {
      const filter = DateFilterSelection.last7Days();

      expect(filter.start(now), DateTime(2026, 11, 2));
      expect(filter.end(now), DateTime(2026, 11, 8));
      expect(filter.matches(DateTime(2026, 11, 2), now), isTrue);
      expect(filter.matches(DateTime(2026, 11, 8), now), isTrue);
      expect(filter.matches(DateTime(2026, 11, 1), now), isFalse);
    });

    test('last 30 days includes today and the previous twenty-nine days', () {
      const filter = DateFilterSelection.last30Days();

      expect(filter.start(now), DateTime(2026, 10, 10));
      expect(filter.end(now), DateTime(2026, 11, 8));
      expect(filter.matches(DateTime(2026, 10, 10), now), isTrue);
      expect(filter.matches(DateTime(2026, 10, 9), now), isFalse);
    });

    test('custom range is inclusive', () {
      final filter = DateFilterSelection.custom(
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 10, 5),
      );

      expect(filter.start(now), DateTime(2026, 10, 1));
      expect(filter.end(now), DateTime(2026, 10, 5));
      expect(filter.matches(DateTime(2026, 10, 1), now), isTrue);
      expect(filter.matches(DateTime(2026, 10, 5), now), isTrue);
      expect(filter.matches(DateTime(2026, 9, 30), now), isFalse);
      expect(filter.matches(DateTime(2026, 10, 6), now), isFalse);
    });
  });
}
