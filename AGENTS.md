# AGENTS.md

`penny_note` is an offline-first Flutter expense and income tracker: Riverpod 3
for DI/state, Drift for local storage, Clean Architecture with MVVM
presentation. It targets Android, iOS, and the web. No backend, no Firebase, no
data API. See `README.md` for the product overview.

## Commands (run from this directory)

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after table/DAO changes
dart format .
flutter analyze
flutter test
flutter run
flutter run -d chrome
flutter build apk --debug
flutter build web --release --no-web-resources-cdn
```

- Single test file: `flutter test test/widget_test.dart`
- Single test: `flutter test --plain-name "save button stores a valid expense"`
- Serve the dev app to an iPhone on the same Wi-Fi:
  `flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080`, then open
  `http://<computer-LAN-IP>:8080` in Safari.
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
    navigation/                       AppShell (NavigationBar/NavigationRail)
    theme/                            palette, ThemeData, theme mode provider
    utils/                            money, dates, category icon mapping
    widgets/                          AppCard, EmptyState, ResponsiveContent,
                                      SectionHeader
  features/
    expenses/                         domain + data + presentation
                                      (add, edit, delete)
    categories/                       expense category CRUD
    income/                           income entries + income-category CRUD
    savings/                          deposit/withdrawal ledger
    home/                             dashboard screen, ViewModel, balance card
    statistics/                       placeholder screen
    settings/                         theme, category management, about
```

Dependency direction (never invert it):

```text
View -> ViewModel -> UseCase -> Repository interface
     -> Repository impl -> DataSource -> DAO -> local database
```

- `domain/` has no Flutter or Drift imports (entities, repository contracts,
  use cases). Validation belongs in use cases, not widgets.
- `data/` owns Drift models, datasources, repository implementations, and error
  translation (`DatabaseFailure`).
- `presentation/` owns providers, ViewModels, screens, widgets. UI never touches
  a DAO, database, or repository implementation directly.
- Riverpod is the composition root: providers in
  `features/expenses/presentation/providers/expense_providers.dart`,
  `features/categories/presentation/providers/category_providers.dart`,
  `features/income/presentation/providers/income_providers.dart`,
  `features/income/presentation/providers/income_category_providers.dart`, and
  `features/savings/presentation/providers/savings_providers.dart` build the
  DAO -> datasource -> repository -> use-case chain. ViewModels depend on use
  cases only. `core/database/database_provider.dart` owns the single database
  instance.

## Riverpod 3 notes

- Use `Notifier`/`AsyncNotifier` + `NotifierProvider`/`AsyncNotifierProvider`
  (not `StateNotifier`). Auto-dispose form state:
  `NotifierProvider.autoDispose<...>(...)`. The expense and income forms are
  auto-dispose *families* keyed by the optional entity being edited; do not
  initialize them by mutating the provider from `initState`.
- `HomeViewModel`, `ExpensesViewModel`, `IncomesViewModel`, and
  `SavingsViewModel` are `AsyncNotifier`s that await their stream provider's
  `.future`, so every Drift emission rebuilds the UI state. `HomeViewModel`
  watches expenses, income, and savings.
- Drift is the source of truth. After add/edit/delete, do **not** manually
  mutate lists; the watched stream re-emits. Delete calls rethrow `AppFailure`
  so the screen can show a snackbar.
- No Riverpod code generation (no `riverpod_generator`); keep providers explicit.

## Drift notes (important)

- `AppDatabase` lives in `lib/core/database/app_database.dart`, schema version 3.
  Tables: `Categories` (id, unique name, icon key, createdAt), `Expenses`
  (id, amountCents, categoryId FK, note, date, createdAt, updatedAt),
  `SavingsEntries` (id, amountCents, isWithdrawal, note, date, createdAt,
  updatedAt), `IncomeCategories` (id, unique name, icon key, createdAt), and
  `Incomes` (id, amountCents, categoryId FK, note, date, createdAt, updatedAt).
  Upgrading from version 2 creates the income tables and seeds their defaults;
  upgrading from version 1 also creates the savings table.
- Money is stored as `int` cents (`amountCents`), never a double. The app uses
  Myanmar Kyat (MMK): format with `formatCents` (`K 1,234` / `K 1,234.50`) and
  parse user input with `parseAmountToCents` (`core/utils/money.dart`).
  `formatCentsForInput` produces the editable value for the edit form.
- Seven default expense categories and six default income categories are seeded
  in `onCreate`. Both category screens can add, rename, re-icon, and delete
  unused categories. Deletion is blocked when entries reference the category or
  it is the last category.
- Expense and income categories are separate tables, so the same name can exist
  in both lists. Keep category icon keys in sync with
  `core/utils/category_icons.dart`. `categoryIconOptions` is the shared picker
  list.
- Foreign keys are enabled per connection in `beforeOpen` via
  `PRAGMA foreign_keys = ON`.
- Bump `schemaVersion` and add an `onUpgrade` migration whenever the schema
  changes. Do not edit generated `*.g.dart` files; regenerate them.
- **GOTCHA:** a DAO file must import the table files it references directly
  (e.g. `../tables/expenses.dart`). Importing only `app_database.dart` makes
  `drift_dev` generate an empty DAO mixin without table getters.
- Production opens through `driftDatabase(...)`: native uses SQLite in the app
  documents directory; web uses `DriftWebOptions` with `web/sqlite3.wasm` and
  `web/drift_worker.js`. Native support must remain unchanged.
- The web assets are version-matched: `sqlite3.wasm` comes from the `sqlite3`
  package release and `drift_worker.js` from the installed `drift` package.
  Update both when upgrading those packages.
- Tests inject `AppDatabase.forTesting(NativeDatabase.memory())`; no real DB file
  is touched. Widget tests override `expensesStreamProvider`,
  `incomesStreamProvider`, and `savingsStreamProvider` (and category streams
  where needed) so they never open SQLite.
- The joined expense/category query lives in `ExpenseDao.watchAll()` and the
  joined income/category query in `IncomeDao.watchAll()`; repositories map data
  models to domain entities. Do not leak `ExpenseRow`, `IncomeRow`,
  `TypedResult`, or companions outside `data/`.

## Web and PWA notes

- `AppDatabase` must pass `web: DriftWebOptions(...)`; native SQLite does not
  work automatically on the web.
- `web/flutter_bootstrap.js` deliberately calls `_flutter.loader.load()` without
  Flutter's deprecated built-in service worker. Do not re-enable it; it would
  replace the custom worker and remove offline support.
- `web/sw.js` caches the app shell (including CanvasKit, `sqlite3.wasm`, and
  `drift_worker.js`) and serves navigation network-first, other assets
  stale-while-revalidate. Bump `CACHE_VERSION` when shell assets change.
- Always build with `--no-web-resources-cdn` so CanvasKit is self-hosted and can
  be cached. The default build loads CanvasKit from gstatic and cannot work
  offline. Hosts must serve `.wasm` as `application/wasm`.
- The service worker and Home Screen installation require HTTPS (or localhost).
  A plain `http://<LAN-IP>` test URL works for UI/browser storage but not for
  the full PWA/offline experience.
- Do not claim iPhone Safari was tested unless it actually was. Browser
  automation on Windows can verify layout and flows, not WebKit behavior.

## Theme and UI

- Brand palette and the `PennyColors` ThemeExtension are in
  `core/theme/app_colors.dart`; `core/theme/app_theme.dart` builds Material 3
  light/dark themes. Do not hard-code colors in widgets. Use
  `Theme.of(context).colorScheme` and `context.pennyColors` (income/expense).
- Spacing/radii come from `AppSpacing`; shared surfaces from `AppCard`,
  `EmptyState`, and `SectionHeader`.
- Wrap page content in `ResponsiveContent` so cards and forms stay readable on
  tablets and desktop. `AppShell` uses a bottom `NavigationBar` when the shortest
  side is under 600 logical pixels and a `NavigationRail` above that.
- `themeModeProvider` supports system/light/dark via Settings. It is in-memory
  for this foundation; persistence is a planned follow-up.
- Navigation is built-in `Navigator` + `AppShell` (`IndexedStack` keeps tab state).
  Add a routing package only when deep linking/URL routing is actually needed.
- Android label, iOS display name, web metadata, PWA icons, and Windows title are
  set to "Penny Note"; keep new platform metadata consistent.

## Current scope

Implemented: dashboard with income/expense balance, expense add/edit/delete,
income add/edit/delete with its own categories, Myanmar Kyat formatting, savings
deposits/withdrawals with a running total, expense and income category
add/edit/delete under Settings, theme switching, and a statistics placeholder.
Not implemented yet: savings goals, budgets, statistics/charts, theme
persistence, search, and export. Extend a feature by adding domain -> data ->
providers -> ViewModel -> screen in that order, and only create folders/files
that are actually used.
