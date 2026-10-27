# AGENTS.md

`penny_note` is an offline-first Flutter expense tracker: Riverpod 3 for DI/state,
Drift (SQLite) for local storage, Clean Architecture with MVVM presentation. No
backend, no Firebase, no network calls. See `README.md` for the product overview.

## Commands (run from this directory)

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after table/DAO changes
dart format .
flutter analyze
flutter test
flutter run
flutter build apk --debug
```

- Single test file: `flutter test test/widget_test.dart`
- Single test: `flutter test --plain-name "save button stores a valid expense"`
- The git root is the parent `flutter_class/`, which has **no pubspec**. Run
  Flutter commands inside `penny_note/`. The parent working tree contains many
  unrelated sibling-app edits; stage/commit only `penny_note/` paths.

## Architecture map

```text
lib/
  app.dart, main.dart                 MaterialApp + ProviderScope
  core/
    constants/                        app name, tagline, DB name
    database/                         Drift DB, tables, DAOs, DB provider
    errors/                           AppFailure hierarchy shown in UI
    navigation/                       AppShell (NavigationBar + IndexedStack)
    theme/                            palette, ThemeData, theme mode provider
    utils/                            money, dates, category icon mapping
    widgets/                          AppCard, EmptyState, SectionHeader
  features/
    expenses/                         domain + data + presentation (full)
    categories/                       read-only domain + data + providers
    home/                             dashboard screen, ViewModel, balance card
    statistics/                       placeholder screen
    settings/                         theme selection + about
```

Dependency direction (never invert it):

```text
View -> ViewModel -> UseCase -> Repository interface
     -> Repository impl -> DataSource -> DAO -> SQLite
```

- `domain/` has no Flutter or Drift imports (entities, repository contracts,
  use cases). Validation belongs in use cases, not widgets.
- `data/` owns Drift models, datasources, repository implementations, and error
  translation (`DatabaseFailure`).
- `presentation/` owns providers, ViewModels, screens, widgets. UI never touches
  a DAO, database, or repository implementation directly.
- Riverpod is the composition root: providers in
  `features/expenses/presentation/providers/expense_providers.dart` and
  `features/categories/presentation/providers/category_providers.dart` build the
  DAO -> datasource -> repository -> use-case chain. ViewModels depend on use
  cases only. `core/database/database_provider.dart` owns the single database
  instance.

## Riverpod 3 notes

- Use `Notifier`/`AsyncNotifier` + `NotifierProvider`/`AsyncNotifierProvider`
  (not `StateNotifier`). Auto-dispose form state:
  `NotifierProvider.autoDispose<...>(...)`.
- `HomeViewModel` and `ExpensesViewModel` are `AsyncNotifier`s that await
  `ref.watch(expensesStreamProvider.future)`, so every Drift emission rebuilds
  the UI state.
- Drift is the source of truth. After add/delete, do **not** manually mutate the
  list; the watched stream re-emits. Delete calls rethrow `AppFailure` so the
  screen can show a snackbar.
- No Riverpod code generation (no `riverpod_generator`); keep providers explicit.

## Drift notes (important)

- `AppDatabase` lives in `lib/core/database/app_database.dart`, schema version 1.
  Tables: `Categories` (id, unique name, icon key, createdAt) and `Expenses`
  (id, amountCents, categoryId FK, note, date, createdAt, updatedAt).
- Money is stored as `int` cents (`amountCents`), never a double. Format with
  `formatCents` and parse user input with `parseAmountToCents` (`core/utils/money.dart`).
- Seven default categories are seeded in `onCreate` so the expense form works
  before a category-management UI exists. Keep the icon keys in sync with
  `core/utils/category_icons.dart`.
- Foreign keys are enabled per connection in `beforeOpen` via
  `PRAGMA foreign_keys = ON`.
- Bump `schemaVersion` and add an `onUpgrade` migration whenever the schema
  changes. Do not edit generated `*.g.dart` files; regenerate them.
- **GOTCHA:** a DAO file must import the table files it references directly
  (e.g. `../tables/expenses.dart`). Importing only `app_database.dart` makes
  `drift_dev` generate an empty DAO mixin without table getters.
- Production DB opens through `driftDatabase(name: AppConstants.databaseName)`
  and lives in the app documents directory. Tests inject
  `AppDatabase.forTesting(NativeDatabase.memory())`; no real DB file is touched.
  Widget tests override `expensesStreamProvider` (and categories where needed)
  so they never open SQLite.
- The joined expense/category query lives in `ExpenseDao.watchAll()`; the
  repository maps data models to domain entities. Do not leak `ExpenseRow`,
  `TypedResult`, or companions outside `data/`.

## Theme and UI

- Brand palette and the `PennyColors` ThemeExtension are in
  `core/theme/app_colors.dart`; `core/theme/app_theme.dart` builds Material 3
  light/dark themes. Do not hard-code colors in widgets. Use
  `Theme.of(context).colorScheme` and `context.pennyColors` (income/expense).
- Spacing/radii come from `AppSpacing`; shared surfaces from `AppCard`,
  `EmptyState`, and `SectionHeader`.
- `themeModeProvider` supports system/light/dark via Settings. It is in-memory
  for this foundation; persistence is a planned follow-up.
- Navigation is built-in `Navigator` + `AppShell` (`IndexedStack` keeps tab state).
  Add a routing package only when deep linking/URL routing is actually needed.
- Android label, iOS display name, web metadata, and Windows title are set to
  "Penny Note"; keep new platform metadata consistent.

## Current scope

Foundation only: dashboard, expenses list/add/delete, theme switching, and a
statistics placeholder. Not implemented yet: income, budgets, category
management, statistics/charts, theme persistence. Extend a feature by adding
domain -> data -> providers -> ViewModel -> screen in that order, and only create
folders/files that are actually used.
