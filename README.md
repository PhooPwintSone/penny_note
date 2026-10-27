# Penny Note

> Every penny has a story.

Penny Note is a calm, private expense journal for Android and iOS. It is
**offline-first**: every entry stays in a local SQLite database on the device.
There is no account, backend, analytics, or network dependency.

This repository contains the foundation of the app: the architecture, theme
system, local database, dashboard, and the first complete feature — expenses.

## What works today

- **Home dashboard** — greeting, balance card, income/expense summary, recent
  expenses, and a friendly empty state. No placeholder financial data.
- **Expenses** — add an expense (amount, category, note, date), see it instantly,
  and delete it with confirmation.
- **Theme** — light, dark, and system modes with a custom Material 3 palette.
- **Local persistence** — Drift + SQLite, reactive queries, seeded categories,
  foreign keys, and a migration entry point.
- **Statistics** — UI placeholder for the next iteration.

## Tech stack

| Concern | Choice |
| --- | --- |
| UI | Flutter, Material 3 |
| State & DI | Riverpod 3 (`Notifier` / `AsyncNotifier`) |
| Storage | Drift (SQLite) with `drift_flutter` |
| Architecture | Feature-first Clean Architecture + MVVM |
| Formatting | `intl` for currency and dates |

No routing package, state-management framework, or extra dependency was added
unless the built-in option was not enough.

## Architecture

```text
View (screen / widget)
        ↓
ViewModel (presentation state + actions)
        ↓
Use case (domain validation and rules)
        ↓
Repository interface (domain contract)
        ↓
Repository implementation (data layer)
        ↓
Data source → Drift DAO → SQLite
```

- `domain/` is pure Dart: entities, repository contracts, and use cases.
- `data/` maps Drift rows to data models and then to domain entities, and turns
  storage errors into `AppFailure`s.
- `presentation/` holds Riverpod providers, ViewModels, screens, and widgets.
  UI never talks to Drift or a DAO directly.
- Riverpod providers are the composition root that wires the whole chain.

## Project layout

```text
lib/
├── core/
│   ├── constants/      app name, tagline, database name
│   ├── database/       Drift database, tables, DAOs, database provider
│   ├── errors/         user-safe failure types
│   ├── navigation/     app shell with Home / Expenses / Statistics / Settings
│   ├── theme/          brand palette, ThemeData, theme mode provider
│   ├── utils/          money, date, and category-icon helpers
│   └── widgets/        shared cards, empty states, section headers
├── features/
│   ├── expenses/       domain / data / presentation (complete CRUD foundation)
│   ├── categories/     minimal read-only support for the expense form
│   ├── home/           dashboard screen, ViewModel, balance card
│   ├── statistics/     placeholder screen
│   └── settings/       theme selection and about
├── app.dart            MaterialApp, themes, root navigation
└── main.dart           ProviderScope entry point
```

## Data flow example: adding an expense

1. The form updates `AddExpenseViewModel` (a Riverpod `Notifier`).
2. Submit calls the `AddExpense` use case, which validates amount, category, and
   note length.
3. The repository forwards it to `ExpenseLocalDataSource` and `ExpenseDao`.
4. Drift inserts the row and re-emits the joined watch query.
5. `expensesStreamProvider` updates; Home and Expenses rebuild from SQLite.

Money is stored as **integer cents** (`amountCents`). This avoids floating-point
rounding when totals are summed; formatting happens at the edge with
`formatCents`.

## Database

Schema version 1 contains:

- `categories` — `id`, unique `name`, icon key, `createdAt`
- `expenses` — `id`, `amountCents`, `categoryId` (FK), `note`, `date`,
  `createdAt`, `updatedAt`

Seven default categories (Food, Transport, Shopping, Bills, Health, Coffee,
Other) are seeded on first launch so the expense form is usable immediately.
`onUpgrade` is in place for future migrations.

## Getting started

Requires Flutter with Dart 3.12+ (verified with Flutter 3.44.1).

```sh
flutter pub get
flutter run          # choose Android, iOS, or desktop
```

Useful checks:

```sh
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

After changing Drift tables or DAOs, regenerate the database code:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Tests

The suite covers:

- money parsing and formatting
- add-expense domain validation
- Drift seeding, joins, inserts, deletes, and reactive queries (in-memory DB)
- dashboard empty/loaded states on a phone-sized screen
- expense list layout and the delete affordance
- the add-expense Save button
- app smoke test and light/dark theme switching

Widget tests override the expense stream so they never open a real database file.

## Roadmap

- Persist the selected theme
- Income tracking and a real monthly balance
- Category management (add/edit/archive, custom icons)
- Budgets and spending limits
- Statistics: monthly totals, category breakdowns, trends
- Search and filtering
- Export/backup and optional encrypted storage

## Privacy

Penny Note has no network layer. Your journal is stored only on your device.
