import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/daos/transfer_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../data/datasources/transfer_local_data_source.dart';
import '../../data/repositories/transfer_repository_impl.dart';
import '../../domain/entities/transfer.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../domain/usecases/add_transfer.dart';
import '../../domain/usecases/delete_transfer.dart';
import '../../domain/usecases/update_transfer.dart';
import '../../domain/usecases/watch_transfers.dart';

/// Dependency-injection graph for the savings transfer ledger.
final transferDaoProvider = Provider<TransferDao>((ref) {
  return ref.watch(appDatabaseProvider).transferDao;
});

final transferLocalDataSourceProvider = Provider<TransferLocalDataSource>((
  ref,
) {
  return TransferLocalDataSource(ref.watch(transferDaoProvider));
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepositoryImpl(ref.watch(transferLocalDataSourceProvider));
});

final watchTransfersUseCaseProvider = Provider<WatchTransfers>((ref) {
  return WatchTransfers(ref.watch(transferRepositoryProvider));
});

final addTransferUseCaseProvider = Provider<AddTransfer>((ref) {
  return AddTransfer(
    ref.watch(transferRepositoryProvider),
    ref.watch(accountRepositoryProvider),
  );
});

final updateTransferUseCaseProvider = Provider<UpdateTransfer>((ref) {
  return UpdateTransfer(
    ref.watch(transferRepositoryProvider),
    ref.watch(accountRepositoryProvider),
  );
});

final deleteTransferUseCaseProvider = Provider<DeleteTransfer>((ref) {
  return DeleteTransfer(
    ref.watch(transferRepositoryProvider),
    ref.watch(accountRepositoryProvider),
  );
});

final transfersStreamProvider = StreamProvider<List<Transfer>>((ref) {
  return ref.watch(watchTransfersUseCaseProvider)();
});
