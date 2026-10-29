import '../entities/transfer.dart';
import '../repositories/transfer_repository.dart';

/// Returns a live list of transfers, newest first.
class WatchTransfers {
  const WatchTransfers(this._repository);

  final TransferRepository _repository;

  Stream<List<Transfer>> call() => _repository.watchTransfers();
}
