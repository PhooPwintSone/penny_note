import '../../../../core/database/app_database.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/currency_settings.dart';

/// Data-layer representation of the app settings row.
class CurrencySettingsModel {
  const CurrencySettingsModel({required this.currency});

  factory CurrencySettingsModel.fromRow(AppSettingsRow row) {
    return CurrencySettingsModel(
      currency: AppCurrency.fromCode(row.currencyCode),
    );
  }

  final AppCurrency currency;

  CurrencySettings toEntity() => CurrencySettings(currency: currency);
}
