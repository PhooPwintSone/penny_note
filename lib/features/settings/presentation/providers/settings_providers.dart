import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/daos/settings_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/utils/money.dart';
import '../../data/datasources/settings_local_data_source.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/currency_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/update_currency.dart';
import '../../domain/usecases/watch_currency_settings.dart';
import '../../domain/usecases/watch_has_financial_records.dart';

/// Dependency-injection graph for app-wide settings.
final settingsDaoProvider = Provider<SettingsDao>((ref) {
  return ref.watch(appDatabaseProvider).settingsDao;
});

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((
  ref,
) {
  return SettingsLocalDataSource(ref.watch(settingsDaoProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider));
});

final watchCurrencySettingsUseCaseProvider = Provider<WatchCurrencySettings>((
  ref,
) {
  return WatchCurrencySettings(ref.watch(settingsRepositoryProvider));
});

final watchHasFinancialRecordsUseCaseProvider =
    Provider<WatchHasFinancialRecords>((ref) {
      return WatchHasFinancialRecords(ref.watch(settingsRepositoryProvider));
    });

final updateCurrencyUseCaseProvider = Provider<UpdateCurrency>((ref) {
  return UpdateCurrency(ref.watch(settingsRepositoryProvider));
});

/// Live persisted settings from SQLite.
final currencySettingsStreamProvider = StreamProvider<CurrencySettings>((ref) {
  return ref.watch(watchCurrencySettingsUseCaseProvider)();
});

/// The currency used by every screen. Defaults to MMK while settings load.
final currencyProvider = Provider<AppCurrency>((ref) {
  final settings = ref.watch(currencySettingsStreamProvider);
  return settings.value?.currency ?? AppCurrency.mmk;
});

/// Whether the journal has any records that lock the currency.
final hasFinancialRecordsStreamProvider = StreamProvider<bool>((ref) {
  return ref.watch(watchHasFinancialRecordsUseCaseProvider)();
});
