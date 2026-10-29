import '../../../accounts/domain/entities/account.dart';
import '../entities/transfer.dart';

/// Contract for the transfer ledger.
abstract interface class TransferRepository {
  /// Emits every transfer, newest first, and re-emits after any write.
  Stream<List<Transfer>> watchTransfers();

  Future<Transfer?> findById(int id);

  Future<void> addTransfer({
    required int amountCents,
    required Account from,
    required Account to,
    required String note,
    required DateTime date,
  });

  Future<void> updateTransfer({
    required int id,
    required int amountCents,
    required Account from,
    required Account to,
    required String note,
    required DateTime date,
  });

  Future<void> deleteTransfer(int id);
}
