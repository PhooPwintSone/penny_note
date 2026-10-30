import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/money.dart';
import '../repositories/settings_repository.dart';

/// Changes the app-wide currency only while the journal is empty.
///
/// Existing amounts are never converted or rewritten. If any transaction
/// exists, the user must go through a proper conversion process first.
class UpdateCurrency {
  const UpdateCurrency(this._repository);

  final SettingsRepository _repository;

  Future<void> call(AppCurrency currency) async {
    final hasRecords = await _repository.watchHasFinancialRecords().first;
    if (hasRecords) {
      throw const ValidationFailure(
        'Currency cannot be changed while your journal contains transactions. '
        'Changing it would require converting existing amounts first.',
      );
    }

    await _repository.updateCurrency(currency);
  }
}
