import '../entities/savings_entry.dart';
import '../repositories/savings_repository.dart';

/// Returns a live list of savings entries, newest first.
class WatchSavings {
  const WatchSavings(this._repository);

  final SavingsRepository _repository;

  Stream<List<SavingsEntry>> call() => _repository.watchSavings();
}
