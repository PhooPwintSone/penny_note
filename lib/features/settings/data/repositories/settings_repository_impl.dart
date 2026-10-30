import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/currency_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Stream<CurrencySettings> watchSettings() {
    return _localDataSource.watchSettings().map((model) => model.toEntity());
  }

  @override
  Stream<bool> watchHasFinancialRecords() {
    return _localDataSource.watchHasFinancialRecords();
  }

  @override
  Future<void> updateCurrency(AppCurrency currency) async {
    try {
      await _localDataSource.updateCurrency(currency);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not save your currency setting.');
    }
  }
}
