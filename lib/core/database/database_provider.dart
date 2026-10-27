import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Single database instance for the app.
///
/// Drift opens the SQLite connection lazily, so this provider is cheap until
/// the first query runs. The database is closed when the provider is disposed.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
