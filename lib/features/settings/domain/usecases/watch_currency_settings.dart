import '../entities/currency_settings.dart';
import '../repositories/settings_repository.dart';

/// Returns the live app-wide currency setting.
class WatchCurrencySettings {
  const WatchCurrencySettings(this._repository);

  final SettingsRepository _repository;

  Stream<CurrencySettings> call() => _repository.watchSettings();
}
