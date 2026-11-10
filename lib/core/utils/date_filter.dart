/// Preset date ranges available to the journal filters.
enum DateFilterPreset { today, last7Days, last30Days, custom }

/// A selected journal date range.
///
/// Ranges are inclusive and compared by calendar day, so transaction times do
/// not affect the result. [initial] keeps the recent default used by both
/// journal screens.
class DateFilterSelection {
  const DateFilterSelection(this.preset, {this.customStart, this.customEnd});

  const DateFilterSelection.today() : this(DateFilterPreset.today);

  const DateFilterSelection.last7Days() : this(DateFilterPreset.last7Days);

  const DateFilterSelection.last30Days() : this(DateFilterPreset.last30Days);

  const DateFilterSelection.custom({
    required DateTime start,
    required DateTime end,
  }) : this(DateFilterPreset.custom, customStart: start, customEnd: end);

  static const initial = DateFilterSelection.last30Days();

  final DateFilterPreset preset;
  final DateTime? customStart;
  final DateTime? customEnd;

  String get label => switch (preset) {
    DateFilterPreset.today => 'Today',
    DateFilterPreset.last7Days => 'Last 7 days',
    DateFilterPreset.last30Days => 'Last 30 days',
    DateFilterPreset.custom => 'Custom',
  };

  DateTime start(DateTime now) {
    final today = _dateOnly(now);
    switch (preset) {
      case DateFilterPreset.today:
        return today;
      case DateFilterPreset.last7Days:
        return _daysBefore(today, 6);
      case DateFilterPreset.last30Days:
        return _daysBefore(today, 29);
      case DateFilterPreset.custom:
        return _dateOnly(customStart ?? today);
    }
  }

  DateTime end(DateTime now) {
    final today = _dateOnly(now);
    switch (preset) {
      case DateFilterPreset.today:
      case DateFilterPreset.last7Days:
      case DateFilterPreset.last30Days:
        return today;
      case DateFilterPreset.custom:
        return _dateOnly(customEnd ?? today);
    }
  }

  bool matches(DateTime date, DateTime now) {
    final day = _dateOnly(date);
    return !day.isBefore(start(now)) && !day.isAfter(end(now));
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _daysBefore(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day - days);
