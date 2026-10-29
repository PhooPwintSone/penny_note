import '../../../../core/errors/app_failure.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../repositories/income_repository.dart';

/// Removes an income entry only when doing so cannot make Cash negative.
class DeleteIncome {
  const DeleteIncome(this._repository, this._accounts);

  final IncomeRepository _repository;
  final AccountRepository _accounts;

  Future<void> call(int id) async {
    if (id <= 0) {
      throw const ValidationFailure('That income entry could not be found.');
    }

    final existingAmountCents = await _repository.amountCentsById(id);
    if (existingAmountCents == null) {
      throw const ValidationFailure('That income entry no longer exists.');
    }

    final summary = await _accounts.currentSummary();
    if (summary.cashBalanceCents - existingAmountCents < 0) {
      throw const ValidationFailure(
        'This income is covering your spending. Delete or adjust those '
        'expenses first.',
      );
    }

    return _repository.deleteIncome(id);
  }
}
