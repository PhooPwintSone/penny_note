import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/savings_entries.dart';

part 'savings_dao.g.dart';

@DriftAccessor(tables: [SavingsEntries])
class SavingsDao extends DatabaseAccessor<AppDatabase> with _$SavingsDaoMixin {
  SavingsDao(super.db);

  Stream<List<SavingsEntryRow>> watchAll() {
    final query = select(savingsEntries)
      ..orderBy([
        (row) => OrderingTerm.desc(row.date),
        (row) => OrderingTerm.desc(row.id),
      ]);
    return query.watch();
  }

  Future<int> insertEntry(SavingsEntriesCompanion entry) {
    return into(savingsEntries).insert(entry);
  }

  Future<SavingsEntryRow?> entryById(int id) {
    return (select(
      savingsEntries,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<bool> deleteEntry(int id) async {
    final deleted = await (delete(
      savingsEntries,
    )..where((row) => row.id.equals(id))).go();
    return deleted > 0;
  }

  Future<int> totalCents() async {
    final rows = await select(savingsEntries).get();
    return rows.fold<int>(
      0,
      (total, entry) =>
          total + (entry.isWithdrawal ? -entry.amountCents : entry.amountCents),
    );
  }
}
