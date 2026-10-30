import '../repositories/settings_repository.dart';

/// Returns whether the journal contains any financial records.
class WatchHasFinancialRecords {
  const WatchHasFinancialRecords(this._repository);

  final SettingsRepository _repository;

  Stream<bool> call() => _repository.watchHasFinancialRecords();
}
