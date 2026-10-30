import '../../../../core/database/daos/settings_dao.dart';
import '../../../../core/utils/money.dart';
import '../models/currency_settings_model.dart';

/// Talks to Drift through [SettingsDao].
class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._dao);

  final SettingsDao _dao;

  Stream<CurrencySettingsModel> watchSettings() {
    return _dao.watchSettings().map(CurrencySettingsModel.fromRow);
  }

  Stream<bool> watchHasFinancialRecords() {
    return _dao.watchHasFinancialRecords();
  }

  Future<void> updateCurrency(AppCurrency currency) {
    return _dao.updateCurrency(currency.code);
  }
}
