import '../../../../core/utils/money.dart';
import '../entities/currency_settings.dart';

/// Contract for local app-wide preferences.
abstract interface class SettingsRepository {
  /// Emits the current settings and re-emits after a currency change.
  Stream<CurrencySettings> watchSettings();

  /// Emits whether any expense, income, or transfer exists.
  Stream<bool> watchHasFinancialRecords();

  /// Persists the selected currency.
  Future<void> updateCurrency(AppCurrency currency);
}
