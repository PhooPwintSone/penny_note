import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/calculate_statistics.dart';

/// Statistics reuse the existing expense and income streams, so this graph only
/// needs the pure calculator. No second database query is opened.
final calculateStatisticsProvider = Provider<CalculateStatistics>((ref) {
  return const CalculateStatistics();
});
