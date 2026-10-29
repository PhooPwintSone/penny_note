# Penny Note

> Every penny has a story.

Penny Note is a calm, private expense, income, and savings journal for Android,
iOS, and the web.
It is **offline-first**: every entry stays in a local database on the device.
There is no sign-up, backend, analytics, or API. On the web, the app can be
installed to the Home Screen and reopened without a network connection after its
assets have been cached.

This repository contains a complete local-first money journal: the architecture,
theme system, Drift database, dashboard, expense and income add/edit/delete,
built-in Cash and Savings accounts with transfers, and customizable categories.
Amounts use Myanmar Kyat (MMK).

## What works today

- **Home dashboard** — greeting, total balance plus cash, savings, income, and
  expense totals, a savings shortcut, recent expenses, and a friendly empty
  state. No placeholder financial data.
- **Expenses** — add an expense (amount, category, note, date), edit it later,
  see it instantly, and delete it with confirmation. Expenses are paid from Cash
  and are rejected when Cash does not have enough money.
- **Income** — record income with its own categories, edit or delete entries,
  and see the updated balance on the dashboard. Income increases Cash only.
- **Savings** — transfer money between Cash and Savings, see the running savings
  balance, and review or delete the transfer history. Transfers are atomic,
  cannot overdraw the source account, and do not count as income or expense.
- **Accounts** — Cash (the default) and Savings are built in and created
  automatically, so there is nothing to configure before recording a
  transaction.
- **Expense categories** — create categories, rename them, change their icons,
  and delete unused ones. Categories referenced by expenses are protected so
  history stays intact; the last remaining category cannot be deleted.
- **Income categories** — a separate category list for income, with the same
  add, rename, re-icon, and protected-delete rules.
- **Myanmar Kyat** — every amount is stored as integer cents and shown as `K`
  (MMK), with thousands separators and decimals only when needed.
- **Theme** — light, dark, and system modes with a custom Material 3 palette.
- **Local persistence** — Drift + SQLite on native, Drift + WebAssembly/IndexedDB
  on the web, reactive queries, seeded accounts and categories, foreign keys,
  and schema migrations.
- **Web / PWA** — responsive phone, tablet, and desktop layouts, installable
  Home Screen metadata, and an offline app shell.
- **Statistics** — UI placeholder for the next iteration.

## Tech stack

| Concern | Choice |
| --- | --- |
| UI | Flutter, Material 3 |
| State & DI | Riverpod 3 (`Notifier` / `AsyncNotifier`) |
| Storage (native) | Drift + SQLite via `drift_flutter` |
| Storage (web) | Drift + `sqlite3.wasm` + `drift_worker.js` |
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
Data source → Drift DAO → SQLite (native) / IndexedDB (web)
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
│   ├── navigation/     app shell with Home / Expenses / Income / Statistics /
│   │                    Settings
│   ├── theme/          brand palette, ThemeData, theme mode provider
│   ├── utils/          money, date, and category-icon helpers
│   └── widgets/        shared cards, empty states, responsive content
├── features/
│   ├── accounts/       built-in Cash/Savings accounts and balance summary
│   ├── expenses/       domain / data / presentation (add, edit, delete)
│   ├── categories/     expense category CRUD
│   ├── income/         income entries and income-category CRUD
│   ├── savings/        Cash <-> Savings transfers and running balance
│   ├── home/           dashboard screen, ViewModel, balance card
│   ├── statistics/     placeholder screen
│   └── settings/       theme selection, category management, about
├── app.dart            MaterialApp, themes, root navigation
└── main.dart           ProviderScope entry point

web/
├── sqlite3.wasm        WebAssembly SQLite build
├── drift_worker.js     Drift web worker
├── sw.js               Custom offline cache
├── flutter_bootstrap.js
├── index.html
├── manifest.json
└── icons/
```

## Data flow example: adding or editing an expense

1. The form updates `AddExpenseViewModel` (a Riverpod `Notifier`) with the
   current values or the expense being edited.
2. Submit calls the `AddExpense` or `UpdateExpense` use case, which validates
   amount, category, note length, and that Cash can cover the projected balance.
3. The repository forwards it to `ExpenseLocalDataSource` and `ExpenseDao`.
4. Drift inserts or updates the row and re-emits the joined watch query.
5. `expensesStreamProvider` updates; Home and Expenses rebuild from the database.

Income follows the same path through `AddIncomeViewModel`, the income use cases,
`IncomeLocalDataSource`, and `IncomeDao`; the shared balance summary re-emits so
the dashboard updates immediately. Income edits and deletes are rejected if they
would make Cash negative.

Transfers use the same layers through `TransferDao`. Balance math lives in
`AccountDao.watchSummary()` and is exposed as `FinancialSummary`, so screens and
ViewModels never compute account balances themselves.

Money is stored as **integer cents** (`amountCents`). This avoids floating-point
rounding when totals are summed; formatting happens at the edge with
`formatCents`. MMK uses the `K` symbol and omits `.00` for whole kyat.

## Database

Schema version 4 contains:

- `accounts` — `id`, unique stable `code` (`cash` or `savings`), display `name`,
  `createdAt`
- `categories` — `id`, unique `name`, icon key, `createdAt`
- `expenses` — `id`, `amountCents`, `categoryId` (FK), `note`, `date`,
  `createdAt`, `updatedAt`
- `income_categories` — `id`, unique `name`, icon key, `createdAt`
- `incomes` — `id`, `amountCents`, `categoryId` (FK), `note`, `date`,
  `createdAt`, `updatedAt`
- `transfers` — `id`, `amountCents`, `fromAccountId` (FK), `toAccountId` (FK),
  `note`, `date`, `createdAt`, `updatedAt`; constraints require a positive
  amount and different source/destination accounts

Seven default expense categories (Food, Transport, Shopping, Bills, Health,
Coffee, Other) and six default income categories (Salary, Freelance, Business,
Gifts, Interest, Other) are seeded on first launch so both forms are usable
immediately. The two built-in accounts are seeded idempotently on first launch
and again in `beforeOpen`, using the unique `code` to prevent duplicates.

Upgrading to version 4 creates the accounts and transfers tables, copies every
legacy `savings_entries` row into `transfers` (deposits become Cash → Savings and
withdrawals become Savings → Cash), then drops the legacy table. Existing
amounts, notes, dates, expenses, income, and categories are preserved. Upgrading
from version 2 also creates the income tables and seeds the default income
categories; upgrading from version 1 does the same before the version 4 step.
Future schema changes belong in `onUpgrade`.

Balances are derived from the transaction tables, not stored:

```text
Cash    = income - expenses + transfers into Cash - transfers out of Cash
Savings = transfers into Savings - transfers out of Savings
Total   = Cash + Savings
```

Transfers are deliberately excluded from the income and expense totals, so
moving money between accounts never changes Total. `AccountDao.watchSummary()`
performs this calculation reactively and returns a `FinancialSummary`.

On native platforms the database opens through `drift_flutter` and lives in the
app documents directory. On the web, `AppDatabase` passes `DriftWebOptions`
pointing at `sqlite3.wasm` and `drift_worker.js`; Drift chooses OPFS or IndexedDB
depending on what the browser supports. The browser stores it per origin.

The checked-in web assets must match the package versions in
`pubspec.lock` (`sqlite3` 3.5.2 and Drift 2.35.3 at the time of writing):

- `sqlite3.wasm` comes from the `sqlite3.dart` GitHub release matching the
  `sqlite3` package.
- `drift_worker.js` comes from the installed `drift` package.

Update both when upgrading Drift or `sqlite3`.

## Getting started

Requires Flutter with Dart 3.12+ (verified with Flutter 3.44.1).

```sh
flutter pub get
flutter run          # choose Android, iOS, or desktop
```

### Run in a browser

```sh
flutter run -d chrome
```

### Open the development app on an iPhone

Start the dev server on your local network instead of only `localhost`:

```sh
flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080
```

Then, with the iPhone on the same Wi-Fi network, open
`http://<your-computer-LAN-IP>:8080` in Safari. Allow Flutter/Dart through the
Windows firewall if prompted.

This HTTP development URL is fine for trying the UI and for local persistence in
Safari. Service workers and Add to Home Screen require a secure context: use
`localhost` on the computer, an HTTPS tunnel, or a deployed HTTPS site. To test
the full PWA/offline behavior on an iPhone, deploy the release build or tunnel
it over HTTPS.

### Build and deploy the web app

Always build with local CanvasKit assets; the default Flutter build loads
CanvasKit from a CDN, which would break offline use:

```sh
flutter build web --release --no-web-resources-cdn
```

The output is `build/web`. Upload that folder to any static host, for example
Netlify, Vercel, Cloudflare Pages, or GitHub Pages. For GitHub Pages with a
project path, add `--base-href /<repository-name>/`.

The host must serve `.wasm` as `application/wasm` and allow the app's
`.js`, `.json`, `.otf`, `.frag`, and `.png` files to load. Most static hosts do
this automatically. Serve the folder over HTTPS (or `localhost`) so the service
worker and PWA installation are enabled. On iPhone, open the site in Safari, tap
Share, then **Add to Home Screen**.

`web/flutter_bootstrap.js` intentionally does not register Flutter's deprecated
built-in service worker. `web/sw.js` is the app's offline cache. If you change
the web app shell or add required assets, update the precache list and bump
`CACHE_VERSION` in `web/sw.js`.

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

## Offline and browser storage limits

- The first visit needs a network connection to download the app. After the
  service worker has cached the shell, a refresh or Home Screen launch works
  offline.
- Data is stored in the browser's local storage for that origin. It is not synced
  between devices or browsers. Clearing website data, using private browsing, or
  resetting the browser removes it.
- Safari may evict website data after a period without interaction. Installing
  the app to the Home Screen and using it regularly helps, but browsers do not
  provide a permanent-storage guarantee. There is no cloud backup yet.
- Storage is origin-specific: `http://192.168.x.x:8080` and a deployed HTTPS
  domain have separate databases.
- No network request is made for normal money operations. Only the initial app
  download (and browser update checks) use the network.

## Tests

The suite covers:

- money parsing and MMK formatting
- add/update expense and income domain validation
- Drift seeding, joins, inserts, updates, deletes, and reactive queries
- schema version 4 migration from version 2, including legacy savings rows and
  preserved expenses and categories
- the two built-in accounts, Cash/Savings balance formulas, and transfer
  directions
- income increasing Cash, expenses decreasing Cash, and transfers leaving the
  total unchanged
- rejection of overspending, over-transferring, zero/negative amounts, and
  invalid income edits or deletions without changing stored rows
- editing and deleting expenses, income, and transfers while keeping every
  balance correct
- file-backed persistence across closing and reopening the database
- expense and income category add/rename/delete rules, including used and
  last-category protection
- dashboard empty/loaded states and total/cash/savings/income/expense totals
- expense and income list layout, edit actions, and delete affordances
- the add/edit expense and income forms
- app smoke test and light/dark theme switching
- bottom navigation on phones and a navigation rail on larger screens

Widget tests override the expense, income, savings, and account-summary streams
so they never open a real database file. Database and use-case tests use
`NativeDatabase.memory()`; the persistence test uses a temporary SQLite file.

The web build was exercised in Chrome with an iPhone-sized viewport. A full
browser refresh was also verified in Chrome: after adding income, an expense,
and a Cash → Savings transfer, the dashboard still showed the same Total, Cash,
Savings, Income, and Expense values after reload. Actual iPhone Safari was not
available in this environment, so verify Home Screen installation on your
device.

## Roadmap

- Persist the selected theme
- Savings goals and progress
- Budgets and spending limits
- Statistics: monthly totals, category breakdowns, trends
- Search and filtering
- Export/backup and optional encrypted storage

## Privacy

Penny Note has no API or network layer for its data. Your journal is stored only
on your device/browser profile. No analytics or third-party tracking is included.
