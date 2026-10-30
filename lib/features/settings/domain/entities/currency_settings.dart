import '../../../../core/utils/money.dart';

/// The app-wide currency preference.
class CurrencySettings {
  const CurrencySettings({required this.currency});

  static const defaults = CurrencySettings(currency: AppCurrency.mmk);

  final AppCurrency currency;
}
