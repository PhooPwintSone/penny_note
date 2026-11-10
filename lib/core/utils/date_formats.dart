import 'package:intl/intl.dart';

final DateFormat _shortDate = DateFormat('MMM d, yyyy');
final DateFormat _longDate = DateFormat('EEEE, MMMM d');
final DateFormat _monthYear = DateFormat('MMMM yyyy');
final DateFormat _shortMonth = DateFormat('MMM');

/// A friendly greeting for the dashboard header.
String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// The full date shown under the greeting, e.g. `Tuesday, October 27`.
String formatHeaderDate(DateTime now) => _longDate.format(now);

/// The month and year used by statistics, e.g. `November 2026`.
String formatMonthYear(DateTime date) => _monthYear.format(date);

/// A compact month label for trend charts, e.g. `Nov`.
String formatShortMonth(DateTime date) => _shortMonth.format(date);

/// `Today`, `Yesterday`, or `Oct 27, 2026`.
String formatExpenseDate(DateTime date, {DateTime? now}) {
  final today = _dateOnly(now ?? DateTime.now());
  final day = _dateOnly(date);
  final difference = today.difference(day).inDays;

  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';
  return _shortDate.format(day);
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
