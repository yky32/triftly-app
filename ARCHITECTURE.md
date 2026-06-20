# Trip App — Flutter Architecture Plan

**Project:** trip-app (Flutter Mobile)  
**Author:** CTO, WY Limited  
**Date:** 2026-06-19  
**Status:** Approved for implementation — replaces PWA plan  
**Repo:** `github.com/yky32/trip-app`  
**Local:** `~/Documents/Development/Git/yky/trip-app`  
**Conventions:** Follows triftly-app / depozio-app patterns exactly

---

## 1. Executive Summary

Trip App is a Flutter mobile app for trip planning with 3 pillars: **Explore** (spots on map), **Plan** (day-by-day itinerary), **Spend** (expense tracking + split). It follows Wayne's triftly-app conventions: Flutter 3.6+, Dart, flutter_bloc, go_router, google_maps_flutter, Satoshi font, feature-first structure, light mode first.

**Key differentiators vs competitors:**
- Native mobile performance (ChicTrip = 460MB Electron)
- 100% accurate split calculations via `decimal` package (ChicTrip = buggy float math)
- Free + no ads (Splitwise = paywall + ads)
- Minimal clean UI (Wanderlog = heavy)
- Share link = viral growth, no download required to view
- Global from day 1, no car rental parent company conflict

**Direction change:** CEO Wayne approved switching from PWA (Next.js) to Flutter mobile app. This document completely replaces the old PWA ARCHITECTURE.md.

---

## 2. Tech Stack

| Layer | Choice | Rationale |
|-------|--------|-----------|
| **Framework** | Flutter 3.6+ / Dart | Wayne's convention (triftly, depozio) |
| **State Management** | **flutter_bloc** (Bloc, not Cubit) | Wayne's convention — see triftly RoutineBuilderBloc |
| **Routing** | **go_router** with `StatefulShellRoute.indexedStack` | Wayne's convention — see triftly AppRouter |
| **Navigation** | `AppPage` enum + `ScaffoldWithNavBar` + `NavBarMembersWidget` | Wayne's convention — floating bottom nav |
| **Database** | **Supabase** (PostgreSQL) | Free tier: 500MB, 50K MAU, built-in auth, realtime |
| **Supabase Client** | **supabase_flutter** SDK | Direct connection, NO BFF — mobile app connects directly |
| **Offline** | **Hive** (key-value) + **Drift** (SQLite) | Offline-first: Hive for settings/tokens, Drift for trip data cache |
| **Auth** | **Supabase Auth** (magic link + Google OAuth) | Built into Supabase, free. MVP: lazy auth (anonymous first) |
| **Maps** | **google_maps_flutter** | Wayne's convention — already in triftly pubspec.yaml |
| **Geocoding** | **geolocator** + Google Geocoding API | Wayne's convention — triftly uses GeocodingService |
| **Forms** | **flutter_form_builder** + **form_builder_validators** | Wayne's convention |
| **HTTP** | **dio** | Wayne's convention — see triftly ApiClient |
| **Secure Storage** | **flutter_secure_storage** | Wayne's convention — see triftly StorageService |
| **Money Math** | **decimal** package (`package:decimal`) | 100% accurate — NEVER use double/num for money |
| **Exchange Rates** | **Frankfurter API** (`api.frankfurter.app`) | Free, no API key, ECB data, 30+ currencies |
| **Share Tokens** | **nanoid** (`package:nanoid`) | 12-char URL-safe tokens, 260 bits entropy |
| **Fonts** | **Satoshi** family | Wayne's convention — see triftly pubspec.yaml |
| **Loading States** | **Skeletonizer** | Wayne's convention — already in triftly |
| **Environment** | `--dart-define=ENV=dev/prod/stag` + flutter_dotenv | Wayne's convention — see triftly Environment class |
| **l10n** | flutter_localizations + intl + ARB files | Wayne's convention — see triftly l10n.yaml |
| **Animations** | **lottie** | Wayne's convention — splash screen |
| **Icons** | Material Icons + cupertino_icons | Wayne's convention |
| **UI Style** | Light mode first, Material 3, minimal clean | Wayne's convention |
| **Bottom Sheets** | `showModalBottomSheet(useRootNavigator: true)` | Wayne's convention — see triftly showAppModalBottomSheet |
| **No SnackBar** | Silent completion + BLoC-driven UI | Wayne's convention |
| **Deployment** | TestFlight + Play Console | Native mobile distribution |
| **Monthly cost** | **$0** (Supabase free tier, Frankfurter free) | Free tier sufficient for MVP |

### Package List (pubspec.yaml dependencies)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2

  # State management (Wayne's convention)
  flutter_bloc: ^9.1.0
  equatable: ^2.0.7

  # Routing (Wayne's convention)
  go_router: ^14.8.1

  # Forms (Wayne's convention)
  flutter_form_builder: ^10.1.0
  form_builder_validators: ^11.1.2

  # Environment (Wayne's convention)
  flutter_dotenv: ^5.2.1

  # Network (Wayne's convention)
  dio: ^5.8.0
  logger: ^2.5.0

  # Storage (Wayne's convention)
  flutter_secure_storage: ^9.2.4
  shared_preferences: ^2.3.3

  # Supabase
  supabase_flutter: ^2.8.0

  # Offline-first
  hive: ^4.0.0
  hive_flutter: ^2.0.0        # Hive v4 with Isar core
  drift: ^2.24.0
  sqlite3_flutter_libs: ^0.5.0

  # Maps (Wayne's convention)
  google_maps_flutter: ^2.10.0
  geolocator: ^13.0.2

  # Money / calculations
  decimal: ^3.2.0
  nanoid: ^1.0.0

  # UI (Wayne's convention)
  cupertino_icons: ^1.0.8
  skeletonizer: ^2.1.3
  lottie: ^3.1.0
  url_launcher: ^6.2.5
  package_info_plus: ^8.1.2

  # Deep links / sharing
  app_links: ^6.3.0
  share_plus: ^10.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.14.4
  drift_dev: ^2.24.0
  build_runner: ^2.4.0
```

---

## 3. Architecture Decisions (ADRs)

### ADR-1: Flutter over PWA (Next.js)

| | Flutter | PWA (Next.js) |
|---|---|---|
| Native performance | ✅ Compiled ARM | ❌ WebView overhead |
| Maps | ✅ google_maps_flutter (native) | ❌ MapLibre JS in WebView |
| Offline | ✅ Hive + Drift (native SQLite) | ⚠️ Service Worker (limited) |
| Distribution | ✅ App Store + Play Store | ⚠️ PWA install prompt |
| Camera/GPS | ✅ Native plugins | ❌ Web APIs (limited) |
| Wayne's convention | ✅ triftly + depozio | ❌ Different stack |
| Share links | ✅ Deep links + universal links | ✅ URL-based |
| Cost | ✅ Same ($0) | ✅ Same ($0) |

**Decision:** Flutter. CEO Wayne explicitly changed direction. Native maps, offline-first, and app store distribution are critical for a travel app.

### ADR-2: Supabase Direct Connection (NO BFF)

| | Supabase Direct | BFF (custom API) |
|---|---|---|
| Complexity | ✅ Simple — SDK handles auth, RLS | ❌ Custom server needed |
| Cost | ✅ Free tier | ❌ Server hosting cost |
| Auth | ✅ Built-in, RLS policies | ❌ Must implement |
| Realtime | ✅ Built-in subscriptions | ❌ Must implement |
| Security | ✅ RLS + anon key + service key | ✅ Full server control |
| Offline sync | ⚠️ Manual (Hive/Drift cache) | ⚠️ Same |

**Decision:** Supabase direct. Mobile apps don't need a BFF — the Supabase Flutter SDK handles auth tokens, RLS policies protect data, and we avoid server hosting costs. Row Level Security (RLS) is the security boundary.

### ADR-3: Auth Strategy — Lazy Auth

**MVP (Phase 1):** "Lazy auth" — create trips without login. Trips are owned by an anonymous `ownerToken` stored in `flutter_secure_storage`. When user wants to save permanently, share, or use across devices, prompt for Supabase Auth (magic link or Google OAuth). Share links work without login (view-only via public share token).

**Phase 2:** Full auth required for collaborative editing. Supabase Auth supports Google OAuth + magic link + email.

### ADR-4: Share Links via Deep Links

Share links use a public `shareToken` (nanoid, 12 chars, URL-safe). The app registers universal links (iOS) / app links (Android) so that `https://trip.yky.dev/s/abc123XYZ456` opens the app directly. If the app isn't installed, a web fallback page shows a read-only view and prompts to download.

Pattern: `https://trip.yky.dev/s/{shareToken}`

### ADR-5: Hive + Drift for Offline

| | Hive | Drift (SQLite) |
|---|---|---|
| Best for | Key-value: settings, tokens, owner token | Relational: trips, days, spots, expenses |
| Query power | ❌ Key-only | ✅ Full SQL |
| Type safety | ⚠️ Manual adapters | ✅ Code generation |
| Size | Tiny | Moderate |

**Decision:** Use both. Hive for simple key-value (owner token, preferences, exchange rate cache). Drift for structured trip data (offline CRUD with sync queue).

---

## 4. Data Model

### 4.1 Entity Relationship Diagram

```
User 1───∞ Trip 1───∞ Day 1───∞ Spot
                       │
                       └───∞ Expense 1───∞ ExpenseSplit
                                    │
                              Currency (lookup)
Trip 1───∞ ShareToken (for public sharing)
```

### 4.2 Supabase SQL Schema

```sql
-- ─── Users ───────────────────────────────────────────────
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE,
  display_name TEXT,
  avatar_url TEXT,
  supabase_uid TEXT UNIQUE,  -- Links to Supabase Auth
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── Trips ───────────────────────────────────────────────
CREATE TABLE trips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
  owner_token TEXT NOT NULL,          -- Anonymous owner token (pre-auth)
  name TEXT NOT NULL,
  destination TEXT,                    -- e.g. "Tokyo, Japan"
  start_date DATE,                     -- Trip start
  end_date DATE,                       -- Trip end
  cover_image TEXT,                     -- URL
  default_currency TEXT NOT NULL DEFAULT 'USD',
  buddy_names JSONB DEFAULT '[]',      -- ["Wayne", "Alice", "Bob"]
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX trips_owner_token_idx ON trips(owner_token);
CREATE INDEX trips_owner_id_idx ON trips(owner_id);

-- ─── Days ────────────────────────────────────────────────
CREATE TABLE days (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  day_number INT NOT NULL,             -- 1, 2, 3...
  date DATE,                           -- Actual calendar date (optional)
  title TEXT,                          -- "Day 1 - Arrival" or custom
  notes TEXT,
  "order" INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX days_trip_id_idx ON days(trip_id);

-- ─── Spots ───────────────────────────────────────────────
CREATE TABLE spots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  day_id UUID NOT NULL REFERENCES days(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  address TEXT,
  lat DECIMAL(10, 7),
  lng DECIMAL(10, 7),
  category TEXT,                       -- "food", "attraction", "hotel", "transport", "shopping", "other"
  notes TEXT,
  opening_hours TEXT,                  -- Free text: "09:00-22:00"
  duration INT,                        -- Minutes (estimated stay)
  cost DECIMAL(12, 2),
  currency TEXT DEFAULT 'USD',
  "order" INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX spots_day_id_idx ON spots(day_id);

-- ─── Expenses ────────────────────────────────────────────
CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  day_id UUID REFERENCES days(id) ON DELETE SET NULL,  -- Optional: can be trip-level
  title TEXT NOT NULL,                 -- "Lunch at Ichiran"
  amount DECIMAL(12, 2) NOT NULL,
  currency TEXT NOT NULL,              -- Original currency
  amount_in_default DECIMAL(12, 2),   -- Converted to trip default
  exchange_rate DECIMAL(18, 8),       -- Rate used
  paid_by TEXT NOT NULL,              -- Buddy name who paid
  category TEXT,                       -- "food", "transport", "hotel", "activity", "shopping", "other"
  date TIMESTAMPTZ DEFAULT now(),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX expenses_trip_id_idx ON expenses(trip_id);
CREATE INDEX expenses_day_id_idx ON expenses(day_id);

-- ─── Expense Splits ──────────────────────────────────────
CREATE TABLE expense_splits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_id UUID NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
  buddy_name TEXT NOT NULL,            -- "Wayne"
  split_type TEXT NOT NULL,            -- "equal" | "percent" | "amount" | "share"
  split_value DECIMAL(12, 4) NOT NULL,
  -- splitValue meaning depends on split_type:
  --   "equal"   → 1 (flag: this person is included in equal split)
  --   "percent" → 33.33 (percentage)
  --   "amount"  → 45.00 (fixed amount in original currency)
  --   "share"   → 2 (number of shares, e.g. 2:1 ratio)
  owes DECIMAL(12, 2) NOT NULL,       -- Calculated amount this buddy owes
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX expense_splits_expense_id_idx ON expense_splits(expense_id);

-- ─── Share Tokens ────────────────────────────────────────
CREATE TABLE share_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,          -- nanoid 12 chars
  label TEXT,                          -- "Link for Alice"
  permission TEXT NOT NULL DEFAULT 'view',  -- "view" (MVP) | "edit" (Phase 2)
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX share_tokens_token_idx ON share_tokens(token);
CREATE INDEX share_tokens_trip_id_idx ON share_tokens(trip_id);

-- ─── Exchange Rate Cache ─────────────────────────────────
CREATE TABLE exchange_rate_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  base TEXT NOT NULL,                  -- "USD"
  target TEXT NOT NULL,                -- "JPY"
  rate DECIMAL(18, 8) NOT NULL,
  date TEXT NOT NULL,                  -- "2026-06-19" (ECB date)
  fetched_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX exchange_rate_cache_base_target_idx ON exchange_rate_cache(base, target);

-- ─── Row Level Security ──────────────────────────────────
-- Trips: owner can CRUD, share token holders can read
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Owner can CRUD own trips" ON trips
  FOR ALL USING (
    owner_id = auth.uid() OR
    owner_token = current_setting('request.jwt.claims', true)::json->>'owner_token'
  );
CREATE POLICY "Share token holders can read" ON trips
  FOR SELECT USING (
    id IN (SELECT trip_id FROM share_tokens WHERE token = current_setting('request.jwt.claims', true)::json->>'share_token')
  );

-- Days, Spots, Expenses, ExpenseSplits: cascade from trip ownership
ALTER TABLE days ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Days via trip ownership" ON days
  FOR ALL USING (
    trip_id IN (SELECT id FROM trips WHERE owner_id = auth.uid() OR owner_token = current_setting('request.jwt.claims', true)::json->>'owner_token')
  );

-- Similar RLS policies for spots, expenses, expense_splits, share_tokens
-- (implement during Sprint Day 1)
```

### 4.3 Dart Model Classes

```dart
// lib/features/2_plan/models/trip.dart
class Trip {
  final String id;
  final String? ownerId;
  final String ownerToken;
  final String name;
  final String? destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? coverImage;
  final String defaultCurrency;
  final List<String> buddyNames;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Trip({
    required this.id,
    this.ownerId,
    required this.ownerToken,
    required this.name,
    this.destination,
    this.startDate,
    this.endDate,
    this.coverImage,
    this.defaultCurrency = 'USD',
    this.buddyNames = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromMap(Map<String, dynamic> map) => Trip(
    id: map['id'] as String,
    ownerId: map['owner_id'] as String?,
    ownerToken: map['owner_token'] as String,
    name: map['name'] as String,
    destination: map['destination'] as String?,
    startDate: map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
    endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
    coverImage: map['cover_image'] as String?,
    defaultCurrency: map['default_currency'] as String? ?? 'USD',
    buddyNames: List<String>.from(map['buddy_names'] as List? ?? []),
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'owner_id': ownerId,
    'owner_token': ownerToken,
    'name': name,
    'destination': destination,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'cover_image': coverImage,
    'default_currency': defaultCurrency,
    'buddy_names': buddyNames,
  };
}

// Similar models for Day, Spot, Expense, ExpenseSplit, ShareToken
// Follow the same fromMap/toMap pattern for Supabase serialization
```

---

## 5. Split Calculation Algorithm

### 5.1 Split Types

Each expense supports one of 4 split types across buddies:

| Split Type | Example | How `splitValue` works |
|------------|---------|----------------------|
| **Equal** | ¥3000 split 3 ways | Each buddy has `splitValue=1`, owes = amount / count_of_1s |
| **Percent** | ¥3000: Wayne 50%, Alice 50% | `splitValue=50.0`, owes = amount × percent / 100 |
| **Amount** | ¥3000: Wayne pays ¥1000, Alice pays ¥2000 | `splitValue=1000.00`, owes = that exact amount |
| **Share** | ¥3000: Wayne 2 shares, Alice 1 share | `splitValue=2`, owes = amount × shares / total_shares |

### 5.2 Algorithm (`lib/core/split/split_calculator.dart`)

```dart
import 'package:decimal/decimal.dart';

enum SplitType { equal, percent, amount, share }

class SplitInput {
  final String amount; // Original amount as string (avoid float)
  final String currency;
  final List<SplitEntry> splits;

  const SplitInput({required this.amount, required this.currency, required this.splits});
}

class SplitEntry {
  final String buddyName;
  final SplitType splitType;
  final String splitValue; // As string

  const SplitEntry({required this.buddyName, required this.splitType, required this.splitValue});
}

class SplitResultEntry {
  final String buddyName;
  final String owes; // Exact amount in original currency

  const SplitResultEntry({required this.buddyName, required this.owes});
}

class SplitResult {
  final List<SplitResultEntry> splits;
  final String totalAllocated;
  final String roundingDiff; // Pennies left over from rounding

  const SplitResult({required this.splits, required this.totalAllocated, required this.roundingDiff});
}

SplitResult calculateSplit(SplitInput input) {
  final amount = Decimal.parse(input.amount);
  final results = <_OwesEntry>[];

  // Group by split type
  final equalBuddies = input.splits.where((s) => s.splitType == SplitType.equal).toList();
  final percentBuddies = input.splits.where((s) => s.splitType == SplitType.percent).toList();
  final amountBuddies = input.splits.where((s) => s.splitType == SplitType.amount).toList();
  final shareBuddies = input.splits.where((s) => s.splitType == SplitType.share).toList();

  var allocated = Decimal.zero;

  // 1. Fixed amounts first (deterministic)
  for (final s in amountBuddies) {
    final owes = Decimal.parse(s.splitValue);
    results.add(_OwesEntry(buddyName: s.buddyName, owes: owes));
    allocated += owes;
  }

  // 2. Percent splits
  for (final s in percentBuddies) {
    final owes = (amount * Decimal.parse(s.splitValue) / Decimal.fromInt(100))
        .roundToDouble(scale: 2); // Round to 2 decimal places
    results.add(_OwesEntry(buddyName: s.buddyName, owes: owes));
    allocated += owes;
  }

  // 3. Share splits
  if (shareBuddies.isNotEmpty) {
    final totalShares = shareBuddies.fold<Decimal>(
      Decimal.zero,
      (sum, s) => sum + Decimal.parse(s.splitValue),
    );
    final remainingAfterFixed = amount - allocated;
    for (final s in shareBuddies) {
      final owes = (remainingAfterFixed * Decimal.parse(s.splitValue) / totalShares)
          .roundToDouble(scale: 2);
      results.add(_OwesEntry(buddyName: s.buddyName, owes: owes));
      allocated += owes;
    }
  }

  // 4. Equal splits (get whatever's left — absorbs rounding)
  if (equalBuddies.isNotEmpty) {
    final remaining = amount - allocated;
    final perPerson = (remaining / Decimal.fromInt(equalBuddies.length))
        .roundToDouble(scale: 2);
    var equalAllocated = Decimal.zero;
    for (var i = 0; i < equalBuddies.length; i++) {
      // Last person gets the remainder (avoids penny drift)
      final owes = i == equalBuddies.length - 1
          ? remaining - equalAllocated
          : perPerson;
      results.add(_OwesEntry(buddyName: equalBuddies[i].buddyName, owes: owes));
      equalAllocated += owes;
    }
    allocated += equalAllocated;
  }

  final roundingDiff = amount - allocated;

  return SplitResult(
    splits: results.map((r) => SplitResultEntry(buddyName: r.buddyName, owes: r.owes.toStringAsFixed(2))).toList(),
    totalAllocated: allocated.toStringAsFixed(2),
    roundingDiff: roundingDiff.toStringAsFixed(2),
  );
}

// ─── Settlement Algorithm (who owes whom) ────────────────
class Settlement {
  final String from;
  final String to;
  final String amount;

  const Settlement({required this.from, required this.to, required this.amount});
}

List<Settlement> calculateSettlements(List<BalanceEntry> balances) {
  final creditors = <_Balance>[];
  final debtors = <_Balance>[];

  for (final b in balances) {
    final bal = Decimal.parse(b.balance);
    if (bal > Decimal.zero) {
      creditors.add(_Balance(name: b.buddyName, amount: bal));
    } else if (bal < Decimal.zero) {
      debtors.add(_Balance(name: b.buddyName, amount: -bal));
    }
  }

  // Sort: largest amounts first (minimizes number of transactions)
  creditors.sort((a, b) => b.amount.compareTo(a.amount));
  debtors.sort((a, b) => b.amount.compareTo(a.amount));

  final settlements = <Settlement>[];
  var i = 0, j = 0;

  while (i < debtors.length && j < creditors.length) {
    final payment = debtors[i].amount < creditors[j].amount
        ? debtors[i].amount
        : creditors[j].amount;
    settlements.add(Settlement(
      from: debtors[i].name,
      to: creditors[j].name,
      amount: payment.roundToDouble(scale: 2).toStringAsFixed(2),
    ));
    debtors[i].amount -= payment;
    creditors[j].amount -= payment;
    if (debtors[i].amount == Decimal.zero) i++;
    if (creditors[j].amount == Decimal.zero) j++;
  }

  return settlements;
}

class BalanceEntry {
  final String buddyName;
  final String balance; // positive = owed money, negative = owes

  const BalanceEntry({required this.buddyName, required this.balance});
}

// Helper extension for Decimal rounding
extension DecimalRounding on Decimal {
  Decimal roundToDouble({int scale = 2}) {
    // Round half up to the specified scale
    final multiplier = Decimal.fromInt(10).pow(scale);
    final scaled = (this * multiplier).round();
    return Decimal.fromInt(scaled) / multiplier;
  }
}

class _OwesEntry {
  final String buddyName;
  Decimal owes;
  _OwesEntry({required this.buddyName, required this.owes});
}

class _Balance {
  final String name;
  Decimal amount;
  _Balance({required this.name, required this.amount});
}
```

**Key principle:** Use `package:decimal` everywhere for money. Never use Dart `double` or `num` for financial calculations. This is why ChicTrip's split is buggy — they use floating point.

### 5.3 Required Test Cases (20+)

```dart
// test/split_calculator_test.dart
// P0 — Must pass before any UI work on Spend tab

1.  Equal split: 3000 / 3 people = 1000 each
2.  Equal split with rounding: 1000 / 3 people (333.33, 333.33, 333.34)
3.  Equal split: 1 / 3 people (0.33, 0.33, 0.34)
4.  Equal split: 1 person pays all
5.  Percent split: 3000, 50%/50% = 1500/1500
6.  Percent split: 3000, 33.33%/33.33%/33.34%
7.  Amount split: 3000, Wayne=1000, Alice=2000
8.  Share split: 3000, Wayne=2 shares, Alice=1 share = 2000/1000
9.  Mixed: amount + equal (Wayne=1000 fixed, rest split equally among 2)
10. Mixed: percent + equal (Wayne=50%, rest split equally among 2)
11. Mixed: amount + percent + equal
12. Single buddy: pays entire amount
13. Zero amount expense
14. Large amount: 999999.99 / 7 people
15. Settlement: 3 people, simple (A owes B $50, C owes B $30)
16. Settlement: 4 people, circular debts minimized
17. Settlement: no debts (everyone even)
18. Settlement: one person owes everyone
19. Multi-currency: JPY 15000 split equally (no decimal places in JPY)
20. Edge: amount splits that exceed total (validation error)
21. Edge: percent splits that exceed 100% (validation error)
```

---

## 6. Multi-Currency Strategy

### 6.1 Flow

1. User enters expense in local currency (e.g., ¥1500 JPY)
2. App calls Frankfurter API (client-side, cached in Hive + Supabase)
3. Store both: original amount + currency AND converted amount in trip's default currency
4. All split calculations happen in the default currency
5. Display shows both: "¥1,500 (≈ $10.12 USD)"

### 6.2 Frankfurter Service (`lib/core/services/exchange_rate_service.dart`)

```dart
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:decimal/decimal.dart';

class ExchangeRateService {
  static const _frankfurterApi = 'https://api.frankfurter.app';
  static const _cacheBox = 'exchange_rates';
  static const _cacheTtlHours = 24;

  final Dio _dio;

  ExchangeRateService(this._dio);

  Future<Decimal?> getRate({
    required String from,
    required String to,
    String? date, // null = latest
  }) async {
    if (from == to) return Decimal.one;

    // 1. Check Hive cache
    final cacheKey = '${from}_${to}_${date ?? 'latest'}';
    final box = Hive.box(_cacheBox);
    final cached = box.get(cacheKey) as Map?;
    if (cached != null) {
      final fetchedAt = DateTime.parse(cached['fetched_at'] as String);
      final isHistorical = date != null;
      if (isHistorical || fetchedAt.add(Duration(hours: _cacheTtlHours)).isAfter(DateTime.now())) {
        return Decimal.parse(cached['rate'] as String);
      }
    }

    // 2. Call Frankfurter API
    final endpoint = date ?? 'latest';
    final response = await _dio.get(
      '$_frankfurterApi/$endpoint',
      queryParameters: {'from': from, 'to': to},
    );

    if (response.statusCode == 200 && response.data['rates'] != null) {
      final rate = (response.data['rates'][to] as num).toString();
      final apiDate = response.data['date'] as String;

      // 3. Cache in Hive
      await box.put(cacheKey, {
        'rate': rate,
        'date': apiDate,
        'fetched_at': DateTime.now().toIso8601String(),
      });

      // 4. Also store in Supabase exchange_rate_cache table
      // (for cross-device consistency)

      return Decimal.parse(rate);
    }

    return null;
  }

  Future<Map<String, Decimal>> getMultipleRates({
    required String from,
    required List<String> targets,
  }) async {
    final endpoint = 'latest';
    final response = await _dio.get(
      '$_frankfurterApi/$endpoint',
      queryParameters: {'from': from, 'to': targets.join(',')},
    );

    if (response.statusCode == 200 && response.data['rates'] != null) {
      return (response.data['rates'] as Map).map(
        (k, v) => MapEntry(k as String, Decimal.parse(v.toString())),
      );
    }
    return {};
  }
}
```

### 6.3 Supported Currencies

Frankfurter supports 30+ currencies from ECB data. For MVP, we expose all of them. The trip's `defaultCurrency` determines the base for all conversions.

---

## 7. State Management (flutter_bloc Pattern)

### 7.1 BLoC Architecture

Following triftly's exact pattern: **Bloc** (not Cubit), **part** directives for event/state files, **stateless screens**, **BlocConsumer** with `listenWhen`/`buildWhen`.

```
Feature Structure (per triftly convention):
lib/features/2_plan/
├── bloc/
│   ├── plan_bloc.dart          # Bloc class with `part` directives
│   ├── plan_event.dart         # `part of 'plan_bloc.dart'`
│   └── plan_state.dart         # `part of 'plan_bloc.dart'`
├── data/
│   └── plan_repository.dart    # Supabase data access
├── models/
│   ├── trip.dart
│   ├── day.dart
│   └── spot.dart
└── presentation/
    ├── pages/
    │   └── plan_page.dart      # StatelessWidget
    └── widgets/
        ├── day_carousel.dart
        ├── spot_card.dart
        └── bottom_sheets/
            ├── add_spot_bottom_sheet.dart
            └── edit_day_bottom_sheet.dart
```

### 7.2 BLoC Pattern Example (Plan Feature)

```dart
// lib/features/2_plan/bloc/plan_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trip_app/features/2_plan/data/plan_repository.dart';
import 'package:trip_app/features/2_plan/models/trip.dart';
import 'package:trip_app/features/2_plan/models/day.dart';
import 'package:trip_app/features/2_plan/models/spot.dart';

part 'plan_event.dart';
part 'plan_state.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  PlanBloc({required PlanRepository repository})
      : _repository = repository,
        super(const PlanState()) {
    on<TripLoaded>(_onTripLoaded);
    on<DaySelected>(_onDaySelected);
    on<SpotAdded>(_onSpotAdded);
    on<SpotUpdated>(_onSpotUpdated);
    on<SpotRemoved>(_onSpotRemoved);
    on<SpotReordered>(_onSpotReordered);
    on<DayAdded>(_onDayAdded);
    on<DayUpdated>(_onDayUpdated);
    on<DayRemoved>(_onDayRemoved);
    on<SpotMovedToDay>(_onSpotMovedToDay);
  }

  final PlanRepository _repository;

  Future<void> _onTripLoaded(TripLoaded event, Emitter<PlanState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final trip = await _repository.fetchTrip(event.tripId);
      final days = await _repository.fetchDays(event.tripId);
      final spotsByDay = <String, List<Spot>>{};
      for (final day in days) {
        spotsByDay[day.id] = await _repository.fetchSpots(day.id);
      }
      emit(state.copyWith(
        trip: trip,
        days: days,
        spotsByDay: spotsByDay,
        selectedDayIndex: 0,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onDaySelected(DaySelected event, Emitter<PlanState> emit) {
    emit(state.copyWith(selectedDayIndex: event.index));
  }

  // ... other event handlers follow triftly's RoutineBuilderBloc pattern
}

// lib/features/2_plan/bloc/plan_event.dart
part of 'plan_bloc.dart';

abstract class PlanEvent {}

class TripLoaded extends PlanEvent {
  final String tripId;
  TripLoaded(this.tripId);
}

class DaySelected extends PlanEvent {
  final int index;
  DaySelected(this.index);
}

class SpotAdded extends PlanEvent {
  final String dayId;
  final Spot spot;
  SpotAdded({required this.dayId, required this.spot});
}

class SpotUpdated extends PlanEvent {
  final String dayId;
  final int spotIndex;
  final Spot spot;
  SpotUpdated({required this.dayId, required this.spotIndex, required this.spot});
}

class SpotRemoved extends PlanEvent {
  final String dayId;
  final int spotIndex;
  SpotRemoved({required this.dayId, required this.spotIndex});
}

class SpotReordered extends PlanEvent {
  final String dayId;
  final List<Spot> reorderedSpots;
  SpotReordered({required this.dayId, required this.reorderedSpots});
}

class DayAdded extends PlanEvent {
  final Day day;
  DayAdded(this.day);
}

class DayUpdated extends PlanEvent {
  final Day day;
  DayUpdated(this.day);
}

class DayRemoved extends PlanEvent {
  final String dayId;
  DayRemoved(this.dayId);
}

class SpotMovedToDay extends PlanEvent {
  final String fromDayId;
  final int spotIndex;
  final String toDayId;
  SpotMovedToDay({required this.fromDayId, required this.spotIndex, required this.toDayId});
}

// lib/features/2_plan/bloc/plan_state.dart
part of 'plan_bloc.dart';

class PlanState {
  const PlanState({
    this.trip,
    this.days = const [],
    this.spotsByDay = const {},
    this.selectedDayIndex = 0,
    this.isLoading = false,
    this.error,
  });

  final Trip? trip;
  final List<Day> days;
  final Map<String, List<Spot>> spotsByDay; // dayId → spots
  final int selectedDayIndex;
  final bool isLoading;
  final String? error;

  Day? get selectedDay =>
      days.isNotEmpty && selectedDayIndex < days.length
          ? days[selectedDayIndex]
          : null;

  List<Spot> spotsForDay(String dayId) => spotsByDay[dayId] ?? const [];

  PlanState copyWith({
    Trip? trip,
    List<Day>? days,
    Map<String, List<Spot>>? spotsByDay,
    int? selectedDayIndex,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PlanState(
      trip: trip ?? this.trip,
      days: days ?? this.days,
      spotsByDay: spotsByDay ?? this.spotsByDay,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
```

### 7.3 BLoC Provider Pattern (per triftly)

Pages are **StatelessWidget** that provide the BLoC and delegate to a private `_View` widget:

```dart
// lib/features/2_plan/presentation/pages/plan_page.dart
class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlanBloc(repository: context.read<PlanRepository>()),
      child: const _PlanView(),
    );
  }
}

class _PlanView extends StatelessWidget {
  const _PlanView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<PlanBloc, PlanState>(
          listenWhen: (prev, curr) => prev.error != curr.error,
          listener: (context, state) {
            // Handle side effects (navigation, sheet opening) — NO SnackBar
          },
          buildWhen: (prev, curr) =>
              prev.trip != curr.trip ||
              prev.days != curr.days ||
              prev.selectedDayIndex != curr.selectedDayIndex ||
              prev.isLoading != curr.isLoading,
          builder: (context, state) {
            if (state.isLoading) {
              return const _LoadingSkeleton(); // Skeletonizer
            }
            // ... build UI from state
          },
        ),
      ),
    );
  }
}
```

### 7.4 Global BLoC Providers (main.dart)

```dart
// lib/main.dart — following triftly's MyApp pattern
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.authRepository,
    required this.planRepository,
    required this.spendRepository,
    required this.exchangeRateService,
  });

  final AuthRepository authRepository;
  final PlanRepository planRepository;
  final SpendRepository spendRepository;
  final ExchangeRateService exchangeRateService;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: planRepository),
        RepositoryProvider.value(value: spendRepository),
        RepositoryProvider.value(value: exchangeRateService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository)),
          BlocProvider<ThemeBloc>(create: (_) => ThemeBloc(themePreference)),
        ],
        child: BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Trip',
              theme: CustomTheme.lightThemeData(),
              darkTheme: CustomTheme.darkThemeData(),
              themeMode: themeMode,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: AppRouter.router,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                FormBuilderLocalizations.delegate,
              ],
            );
          },
        ),
      ),
    );
  }
}
```

---

## 8. Routing (go_router)

### 8.1 AppPage Enum (per triftly convention)

```dart
// lib/router/app_page.dart
import 'package:flutter/material.dart';

/// App pages and routes. navBarMemberIndex 99 = not in bottom nav (standalone).
enum AppPage {
  explore('Explore', '/explore', Icons.explore, 0),
  plan('Plan', '/plan', Icons.calendar_today, 1),
  spend('Spend', '/spend', Icons.account_balance_wallet, 2),
  profile('Profile', '/profile', Icons.person, 3),
  // Standalone pages (not in bottom nav)
  login('Login', '/login', Icons.login, 99),
  settings('Settings', '/settings', Icons.settings, 99),
  tripDetail('Trip Detail', '/trip/:tripId', Icons.trip_origin, 99),
  shareView('Share', '/s/:token', Icons.share, 99);

  const AppPage(this.name, this.path, this.icon, this.navBarMemberIndex);

  final String name;
  final String path;
  final IconData icon;
  final int navBarMemberIndex;
}
```

### 8.2 AppRouter (per triftly convention)

```dart
// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_app/router/app_page.dart';
import 'package:trip_app/widgets/nav_bar/scaffold_with_nav_bar.dart';
import 'package:trip_app/features/1_explore/presentation/pages/explore_page.dart';
import 'package:trip_app/features/2_plan/presentation/pages/plan_page.dart';
import 'package:trip_app/features/3_spend/presentation/pages/spend_page.dart';
import 'package:trip_app/features/4_profile/presentation/pages/profile_page.dart';
import 'package:trip_app/features/_standalone/login/presentation/pages/login_page.dart';
import 'package:trip_app/features/_standalone/settings/presentation/pages/settings_page.dart';
import 'package:trip_app/features/_standalone/share_view/presentation/pages/share_view_page.dart';
import 'package:trip_app/widgets/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static final Map<AppPage, Widget Function(Object? extra)> _appPages = {
    AppPage.explore: (_) => const ExplorePage(),
    AppPage.plan: (_) => const PlanPage(),
    AppPage.spend: (_) => const SpendPage(),
    AppPage.profile: (_) => const ProfilePage(),
  };

  static final Map<AppPage, Widget Function()> _standaloneAppPages = {
    AppPage.login: () => const LoginPage(),
    AppPage.settings: () => const SettingsPage(),
  };

  static List<StatefulShellBranch> get _navigationBranches {
    final navPages = AppConfig.enabledNavPages;
    return navPages
        .map(
          (page) => StatefulShellBranch(
            routes: [
              GoRoute(
                name: page.name,
                path: page.path,
                builder: (_, state) => _appPages[page]!(state.extra),
              ),
            ],
          ),
        )
        .toList();
  }

  static List<GoRoute> get _standaloneRoutes {
    return AppPage.values
        .where((p) => p.navBarMemberIndex == 99 && AppConfig.isPageEnabled(p))
        .map(
          (page) => GoRoute(
            name: page.name,
            path: page.path,
            builder: (_, __) => _standaloneAppPages[page]!(),
          ),
        )
        .toList();
  }

  static final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/' || path.isEmpty) return '/splash';
      return null;
    },
    routes: [
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      // Share link deep route
      GoRoute(
        name: 'share',
        path: '/s/:token',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return ShareViewPage(shareToken: token);
        },
      ),
      ..._standaloneRoutes,
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: _navigationBranches,
      ),
    ],
  );
}
```

### 8.3 Bottom Navigation Tabs

| Tab | AppPage | Icon | Description |
|-----|---------|------|-------------|
| 1 | `explore` | `Icons.explore` | Map + discover spots/routes |
| 2 | `plan` | `Icons.calendar_today` | Day-by-day itinerary |
| 3 | `spend` | `Icons.account_balance_wallet` | Expenses + split + settle |
| 4 | `profile` | `Icons.person` | Profile/Settings |

### 8.4 Deep Link Configuration

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>tripapp</string>
    </array>
  </dict>
</array>
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:trip.yky.dev</string>
</array>
```

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="https" android:host="trip.yky.dev" android:pathPrefix="/s/"/>
</intent-filter>
```

---

## 9. Project Structure

```
trip-app/
├── .github/
│   └── workflows/
│       └── ci.yml                    # Build + test + lint
├── .env.example                      # Environment variable template
├── env/
│   ├── .env.dev                      # Dev Supabase URL + anon key
│   ├── .env.stag                     # Staging
│   └── .env.prod                     # Production
├── .gitignore
├── README.md
├── ARCHITECTURE.md                   # This document
├── pubspec.yaml
├── analysis_options.yaml
├── l10n.yaml
├── build.yaml                        # Drift code generation
├── supabase/
│   ├── config.toml                   # Supabase local dev config
│   └── migrations/                   # SQL migrations
├── assets/
│   ├── fonts/
│   │   ├── Satoshi-Regular.otf
│   │   ├── Satoshi-Medium.otf
│   │   ├── Satoshi-Bold.otf
│   │   ├── Satoshi-Light.otf
│   │   └── Satoshi-Black.otf
│   ├── lottie/
│   │   └── splash-logo.json
│   └── icon/
│       └── app-icons/
├── ios/
│   ├── Runner/
│   │   ├── Info.plist               # Deep links, Google Maps key
│   │   └── GoogleMapsKeyProvider.*   # Native Google Maps key
│   └── fastlane/
├── android/
│   ├── app/
│   │   └── src/main/
│   │       ├── AndroidManifest.xml   # Deep links
│   │       └── AndroidManifest.xml   # Google Maps key
│   └── fastlane/
├── lib/
│   ├── main.dart                     # App entry, providers, Environment.load()
│   ├── router/
│   │   ├── app_router.dart           # GoRouter with StatefulShellRoute
│   │   └── app_page.dart             # AppPage enum
│   ├── widgets/
│   │   ├── splash_screen.dart
│   │   ├── nav_bar/
│   │   │   ├── scaffold_with_nav_bar.dart
│   │   │   ├── nav_bar_members_widget.dart
│   │   │   └── floating_nav_bar.dart
│   │   └── bottom_sheets/
│   │       └── app_bottom_sheet.dart  # showAppModalBottomSheet
│   ├── core/
│   │   ├── environment.dart          # --dart-define=ENV=dev/prod/stag
│   │   ├── theme/
│   │   │   ├── theme.dart            # CustomTheme with Satoshi
│   │   │   ├── app_colors.dart
│   │   │   ├── theme_bloc.dart
│   │   │   ├── theme_event.dart
│   │   │   ├── theme_preference.dart
│   │   │   └── theme_extension.dart
│   │   ├── network/
│   │   │   ├── api_client.dart       # Dio client (Frankfurter, etc.)
│   │   │   ├── api_interceptor.dart
│   │   │   └── logger.dart
│   │   ├── storage/
│   │   │   ├── secure_storage.dart   # flutter_secure_storage wrapper
│   │   │   └── hive_setup.dart       # Hive box initialization
│   │   ├── services/
│   │   │   ├── supabase_client.dart  # Supabase.instance singleton
│   │   │   ├── exchange_rate_service.dart
│   │   │   ├── geocoding_service.dart
│   │   │   └── owner_token_service.dart
│   │   ├── split/
│   │   │   ├── split_calculator.dart  # Decimal-based split algorithm
│   │   │   └── settlement_calculator.dart
│   │   ├── localization/
│   │   │   ├── app_localizations.dart
│   │   │   └── app_localizations_en.dart
│   │   ├── l10n/
│   │   │   └── app_en.arb
│   │   ├── constants/
│   │   │   ├── app_config.dart        # Enabled pages, feature flags
│   │   │   └── layout_constants.dart
│   │   ├── extensions/
│   │   │   └── localizations.dart
│   │   ├── helpers/
│   │   │   └── date_helpers.dart
│   │   └── dto/
│   │       └── common_response.dart
│   ├── features/
│   │   ├── 1_explore/
│   │   │   ├── bloc/
│   │   │   │   ├── explore_bloc.dart
│   │   │   │   ├── explore_event.dart
│   │   │   │   └── explore_state.dart
│   │   │   ├── data/
│   │   │   │   └── explore_repository.dart
│   │   │   ├── models/
│   │   │   │   └── map_location.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   └── explore_page.dart
│   │   │       └── widgets/
│   │   │           ├── spot_marker.dart
│   │   │           └── bottom_sheets/
│   │   │               └── location_detail_bottom_sheet.dart
│   │   ├── 2_plan/
│   │   │   ├── bloc/
│   │   │   │   ├── plan_bloc.dart
│   │   │   │   ├── plan_event.dart
│   │   │   │   └── plan_state.dart
│   │   │   ├── data/
│   │   │   │   └── plan_repository.dart
│   │   │   ├── models/
│   │   │   │   ├── trip.dart
│   │   │   │   ├── day.dart
│   │   │   │   └── spot.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   └── plan_page.dart
│   │   │       └── widgets/
│   │   │           ├── day_carousel.dart
│   │   │           ├── spot_card.dart
│   │   │           └── bottom_sheets/
│   │   │               ├── add_spot_bottom_sheet.dart
│   │   │               ├── edit_day_bottom_sheet.dart
│   │   │               └── trip_details_bottom_sheet.dart
│   │   ├── 3_spend/
│   │   │   ├── bloc/
│   │   │   │   ├── spend_bloc.dart
│   │   │   │   ├── spend_event.dart
│   │   │   │   └── spend_state.dart
│   │   │   ├── data/
│   │   │   │   └── spend_repository.dart
│   │   │   ├── models/
│   │   │   │   ├── expense.dart
│   │   │   │   └── expense_split.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   └── spend_page.dart
│   │   │       └── widgets/
│   │   │           ├── expense_list.dart
│   │   │           ├── settlement_summary.dart
│   │   │           ├── currency_badge.dart
│   │   │           ├── total_bar.dart
│   │   │           └── bottom_sheets/
│   │   │               ├── add_expense_bottom_sheet.dart
│   │   │               ├── split_config_bottom_sheet.dart
│   │   │               └── buddy_selector_bottom_sheet.dart
│   │   ├── 4_profile/
│   │   │   ├── bloc/
│   │   │   │   ├── profile_bloc.dart
│   │   │   │   ├── profile_event.dart
│   │   │   │   └── profile_state.dart
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           └── profile_page.dart
│   │   └── _standalone/
│   │       ├── login/
│   │       │   ├── bloc/
│   │       │   │   ├── login_bloc.dart
│   │       │   │   ├── login_event.dart
│   │       │   │   └── login_state.dart
│   │       │   └── presentation/
│   │       │       └── pages/
│   │       │           └── login_page.dart
│   │       ├── settings/
│   │       │   └── presentation/
│   │       │       └── pages/
│   │       │           └── settings_page.dart
│   │       └── share_view/
│   │           ├── bloc/
│   │           │   ├── share_view_bloc.dart
│   │           │   ├── share_view_event.dart
│   │           │   └── share_view_state.dart
│   │           └── presentation/
│   │               └── pages/
│   │                   └── share_view_page.dart
│   └── database/                     # Drift (offline cache)
│       ├── app_database.dart         # Drift database definition
│       ├── app_database.g.dart       # Generated
│       ├── tables/
│       │   ├── trips_table.dart
│       │   ├── days_table.dart
│       │   ├── spots_table.dart
│       │   ├── expenses_table.dart
│       │   └── expense_splits_table.dart
│       └── daos/
│           ├── trips_dao.dart
│           ├── days_dao.dart
│           └── expenses_dao.dart
├── test/
│   ├── split_calculator_test.dart    # CRITICAL: 20+ test cases
│   ├── settlement_calculator_test.dart
│   ├── exchange_rate_service_test.dart
│   └── bloc/
│       ├── plan_bloc_test.dart
│       └── spend_bloc_test.dart
└── integration_test/
    └── app_test.dart
```

---

## 10. Offline Strategy (Hive + Drift)

### 10.1 Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   BLoC      │────▶│  Repository   │────▶│  Supabase   │
│  (UI state) │     │  (sync logic) │     │  (cloud DB) │
└─────────────┘     └──────┬───────┘     └─────────────┘
                           │
                    ┌──────▼───────┐
                    │    Drift     │
                    │  (SQLite)    │
                    │  (offline    │
                    │   cache)     │
                    └──────────────┘
```

### 10.2 Repository Pattern

Each repository follows the same pattern:
1. **Read:** Check Drift cache first → return immediately → fetch from Supabase in background → update cache → emit new state
2. **Write:** Write to Drift immediately (optimistic) → push to Supabase → handle conflict → update Drift on success
3. **Sync queue:** Failed writes go into a sync queue table in Drift → retried when connectivity returns

```dart
// lib/features/2_plan/data/plan_repository.dart
class PlanRepository {
  final SupabaseClient _supabase;
  final AppDatabase _db; // Drift

  Future<Trip> fetchTrip(String tripId) async {
    // 1. Try Drift cache
    final cached = await _db.tripsDao.getTrip(tripId);
    if (cached != null) return cached;

    // 2. Fetch from Supabase
    final response = await _supabase.from('trips').select().eq('id', tripId).single();
    final trip = Trip.fromMap(response);

    // 3. Cache in Drift
    await _db.tripsDao.upsertTrip(trip);

    return trip;
  }

  Future<void> createTrip(Trip trip) async {
    // 1. Write to Drift immediately
    await _db.tripsDao.upsertTrip(trip);

    // 2. Push to Supabase
    try {
      await _supabase.from('trips').insert(trip.toMap());
    } catch (e) {
      // 3. Queue for sync if offline
      await _db.syncQueueDao.enqueue('trips', 'insert', trip.id, trip.toMap());
    }
  }
}
```

### 10.3 Hive Usage

Hive stores simple key-value data that doesn't need relational queries:

| Key | Type | Purpose |
|-----|------|---------|
| `owner_token` | String | Anonymous owner token |
| `exchange_rate_{from}_{to}` | Map | Cached exchange rates |
| `theme_preference` | String | 'light' / 'dark' / 'system' |
| `active_trip_id` | String | Last opened trip |
| `onboarding_complete` | bool | First launch flag |

### 10.4 Connectivity Detection

```dart
// Use connectivity_plus package (add to pubspec.yaml)
// dependencies:
//   connectivity_plus: ^6.1.0

// In repositories, check connectivity before Supabase calls
// If offline: read from Drift only, queue writes
// If online: sync queue first, then normal operation
```

---

## 11. Auth Strategy (Supabase Auth, Lazy Auth)

### 11.1 Flow

```
App Launch
  │
  ├── Check flutter_secure_storage for owner_token
  │   ├── Exists → Use it (anonymous mode)
  │   └── Missing → Generate nanoid(24), store in flutter_secure_storage
  │
  ├── Check Supabase Auth session
  │   ├── Logged in → Use userId for all queries
  │   └── Not logged in → Use owner_token for all queries
  │
  └── User wants to save/share/permanently
      └── Prompt for auth (magic link or Google OAuth)
          └── On success: migrate owner_token trips to userId
```

### 11.2 AuthBloc

```dart
// lib/features/_standalone/login/bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheck);
    on<AuthMagicLinkRequested>(_onMagicLink);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthSignOut>(_onSignOut);
    on<AuthMigrationCompleted>(_onMigrationCompleted);
  }

  final AuthRepository _authRepository;

  Future<void> _onAuthCheck(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final session = _authRepository.currentSession;
    if (session != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, userId: session.user.id));
    } else {
      final ownerToken = await _authRepository.getOwnerToken();
      emit(state.copyWith(status: AuthStatus.anonymous, ownerToken: ownerToken));
    }
  }

  Future<void> _onMagicLink(AuthMagicLinkRequested event, Emitter<AuthState> emit) async {
    await _authRepository.signInWithMagicLink(event.email);
    emit(state.copyWith(status: AuthStatus.magicLinkSent));
  }

  Future<void> _onGoogleSignIn(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    final session = await _authRepository.signInWithGoogle();
    if (session != null) {
      // Migrate anonymous trips to this user
      await _authRepository.migrateOwnerTokenTrips(session.user.id);
      emit(state.copyWith(status: AuthStatus.authenticated, userId: session.user.id));
    }
  }
}
```

### 11.3 AuthRepository

```dart
// lib/core/services/auth_repository.dart
class AuthRepository {
  final SupabaseClient _supabase;
  final FlutterSecureStorage _secureStorage;
  static const _ownerTokenKey = 'owner_token';

  Future<String> getOwnerToken() async {
    var token = await _secureStorage.read(key: _ownerTokenKey);
    if (token == null) {
      token = nanoid(24);
      await _secureStorage.write(key: _ownerTokenKey, value: token);
    }
    return token;
  }

  Session? get currentSession => _supabase.auth.currentSession;

  Future<void> signInWithMagicLink(String email) async {
    await _supabase.auth.signInWithOtp(email: email);
  }

  Future<Session?> signInWithGoogle() async {
    return _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.trip.app://login-callback',
    );
  }

  Future<void> migrateOwnerTokenTrips(String userId) async {
    final ownerToken = await getOwnerToken();
    await _supabase
        .from('trips')
        .update({'owner_id': userId})
        .eq('owner_token', ownerToken)
        .is_('owner_id', null);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
```

---

## 12. Map Integration (google_maps_flutter)

### 12.1 Setup

Follow triftly's exact pattern — `GoogleMap` widget in a `StatefulWidget` body, `GoogleMapController` for camera control, `MapViewBloc` for state.

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>GMSServicesKey</key>
<string>${GOOGLE_MAPS_API_KEY}</string>
```

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="${GOOGLE_MAPS_API_KEY}"/>
```

### 12.2 ExplorePage Pattern

```dart
// lib/features/1_explore/presentation/pages/explore_page.dart
// Follows triftly's MapViewPage pattern exactly:
// - BlocProvider<MapViewBloc> at page level
// - _ExploreContent (StatelessWidget) with BlocConsumer
// - _MapBody (StatefulWidget) for GoogleMapController
// - Stack: GoogleMap + search bar + search results
// - Spot markers from trip data
// - Tap marker → showAppModalBottomSheet with spot details
// - Tap map → reverse geocode → show confirm card
```

### 12.3 Geocoding

Use triftly's `GeocodingService` pattern — call Google Geocoding API via Dio:

```dart
class GeocodingService {
  static Future<List<GeocodeResult>> forwardGeocode(String query) async {
    // Call Google Geocoding API
    // Parse results into MapLocation objects
  }

  static Future<GeocodeResult?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    // Call Google Reverse Geocoding API
  }
}
```

---

## 13. Share Link Mechanism

### 13.1 Create Share Link

```dart
// In SpendBloc or a dedicated ShareBloc
Future<String> createShareLink(String tripId, {String? label}) async {
  final token = nanoid(12); // 12 chars, URL-safe, 260 bits entropy
  await supabase.from('share_tokens').insert({
    'trip_id': tripId,
    'token': token,
    'label': label,
    'permission': 'view',
  });
  return 'https://trip.yky.dev/s/$token';
}
```

### 13.2 Share Link Flow

1. User taps "Share" → BLoC creates share token in Supabase
2. App uses `share_plus` to share the link via OS share sheet
3. Recipient opens link → OS opens app via deep link (or web fallback)
4. `ShareViewPage` loads trip data using the share token (no auth required)
5. Read-only view: shows itinerary + expenses, no edit buttons

### 13.3 ShareViewPage

```dart
// lib/features/_standalone/share_view/presentation/pages/share_view_page.dart
class ShareViewPage extends StatelessWidget {
  const ShareViewPage({super.key, required this.shareToken});

  final String shareToken;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShareViewBloc(repository: context.read<PlanRepository>())
        ..add(ShareViewLoaded(shareToken)),
      child: const _ShareViewContent(),
    );
  }
}

// ShareViewBloc fetches trip via:
// supabase.from('share_tokens').select('trip_id').eq('token', shareToken).single()
// Then fetches trip data (read-only)
```

---

## 14. MVP Feature Set (Prioritized)

### P0 — Must Have (Week 1)

| # | Feature | Details |
|---|---------|---------|
| 1 | Create trip | Name, destination, dates, default currency, buddy names |
| 2 | Add/edit/delete days | Day 1, Day 2... with custom titles |
| 3 | Add/edit/delete spots | Name, address, notes, opening hours, category, lat/lng |
| 4 | Organize spots by day | Reorder within day, move between days |
| 5 | Day-by-day itinerary view | Carousel/tab through days, see spots in order |
| 6 | Map view (Explore) | All spots on google_maps_flutter, tap for detail |
| 7 | Add/edit/delete expenses | Title, amount, currency, paid-by, category |
| 8 | Equal split | Split equally among selected buddies |
| 9 | Settlement summary | Who owes whom, minimized transactions |
| 10 | Share link (view-only) | Generate nanoid token, public read-only access |

### P1 — Should Have (Week 2)

| # | Feature | Details |
|---|---------|---------|
| 11 | Multi-currency conversion | Frankfurter API, show converted amounts |
| 12 | Advanced splits | Percent, fixed amount, share-based splits |
| 13 | Trip list / dashboard | See all trips, quick actions |
| 14 | Geocoding on spot add | Type address → auto-fill lat/lng |
| 15 | Spot categories with icons | Food 🍜, Attraction 🏯, Hotel 🏨, Transport 🚃, Shopping 🛍️ |
| 16 | Expense categories with icons | Same categories |
| 17 | Daily expense total | Running total per day + trip total |

### P2 — Nice to Have (Post-MVP)

| # | Feature | Details |
|---|---------|---------|
| 18 | Supabase Auth (magic link) | Claim anonymous trips, persist across devices |
| 19 | Google OAuth login | Quick sign-in |
| 20 | Trip cover image | Upload or pick from gallery |
| 21 | Export trip as PDF | Itinerary + expenses summary |
| 22 | Expense receipt photo | Upload receipt image (Supabase Storage) |
| 23 | Full offline CRUD | Drift sync queue, conflict resolution |
| 24 | Dark mode | Toggle light/dark (theme already defined) |
| 25 | i18n | Chinese, Japanese UI translations |

---

## 15. 2-Week Sprint Plan

### Week 1: Core CRUD + Plan + Explore

| Day | Tasks | Deliverable |
|-----|-------|-------------|
| **Day 1** | Scaffold Flutter project, install deps, set up Supabase (schema + RLS), Environment class, Hive init, Drift setup, theme (copy from triftly), AppPage enum, AppRouter, ScaffoldWithNavBar, NavBarMembersWidget, splash screen | App shell with 4 bottom nav tabs, navigates between empty pages |
| **Day 2** | Trip model + Day model + Spot model, PlanRepository (Supabase CRUD), PlanBloc (TripLoaded, DaySelected, DayAdded, DayUpdated, DayRemoved), TripDetailsBottomSheet (create trip form), Day carousel UI | Can create a trip, see days, add/remove days |
| **Day 3** | Spot model, SpotAdded/SpotUpdated/SpotRemoved events, AddSpotBottomSheet (flutter_form_builder), SpotCard widget, SpotReordered (drag-to-reorder), Day carousel with spot lists | Full Plan tab: CRUD days + spots, reorder spots |
| **Day 4** | ExplorePage with google_maps_flutter, ExploreBloc (spot markers from current trip), spot markers on map, tap marker → LocationDetailBottomSheet, search bar with geocoding | Explore tab: map with all trip spots, search, tap for detail |
| **Day 5** | Expense model + ExpenseSplit model, SpendRepository, SpendBloc (ExpenseAdded, ExpenseRemoved, SplitCalculated), AddExpenseBottomSheet, equal split calculation, SettlementSummary widget, 20+ split tests | Spend tab: add expenses, equal split, settlement summary |

### Week 2: Multi-Currency + Advanced Splits + Share + Polish

| Day | Tasks | Deliverable |
|-----|-------|-------------|
| **Day 6** | ExchangeRateService (Frankfurter + Hive cache), CurrencyBadge widget, amount conversion on expense add, display "¥1,500 (≈ $10.12 USD)", multi-currency in split calculation | Multi-currency expenses working |
| **Day 7** | Advanced splits (percent, amount, share), SplitConfigBottomSheet, BuddySelectorBottomSheet, split type selector UI, all 20+ tests passing | All 4 split types working |
| **Day 8** | Share link: create share token in Supabase, share_plus integration, deep link setup (iOS universal links + Android app links), ShareViewPage (read-only), ShareViewBloc | Share links open app or web fallback |
| **Day 9** | Trip list (TripsPage on Plan tab when no trip selected), trip switching, daily expense totals, category icons (Material Icons), UI polish (Skeletonizer loading states, empty states), Drift offline cache for trips | Complete trip list, polished UI |
| **Day 10** | Fastlane setup for iOS + Android, TestFlight upload, Play Console internal track, final QA pass, environment switching verification, README update | App on TestFlight + Play Console internal track |

### What's achievable in 2 weeks:
- ✅ All P0 features (10 items)
- ✅ Most P1 features (items 11-17)
- ⏳ P2 deferred to post-MVP
- ⏳ Auth (Supabase magic link) deferred to Week 3

---

## 16. Critical Implementation Notes

1. **Money = `Decimal` always.** Never use `double` or `num` for any financial value. This is the #1 reason ChicTrip's split is buggy. Store as strings in Supabase (DECIMAL columns), parse to `Decimal` in Dart, return as strings. Use `package:decimal` (`Decimal.parse()`, not `double.parse()`).

2. **Split calculation must be tested exhaustively.** Write 20+ test cases (listed in §5.3) covering: equal splits with rounding, mixed split types, single person, edge cases (¥1 split 3 ways). These tests are P0 — they must pass before any Spend UI work.

3. **Owner token before auth.** The anonymous owner token pattern is critical for zero-friction onboarding. Generate on first launch, store in `flutter_secure_storage`. When user authenticates later, migrate their trips to their `userId`.

4. **google_maps_flutter needs proper API key setup.** Add `GOOGLE_MAPS_API_KEY` to env files. iOS needs `GMSServicesKey` in Info.plist. Android needs `com.google.android.geo.API_KEY` in AndroidManifest.xml. Use native `GoogleMapsKeyProvider` pattern from triftly for secure key delivery.

5. **Share tokens are not guessable.** Use `nanoid(12)` — 21.7 bits of entropy per char, 12 chars = 260 bits total. Brute force is infeasible.

6. **Frankfurter rate caching.** Cache rates in Hive with 24h TTL. Never call Frankfurter on every expense add — batch lookup. Historical rates (specific date) are cached permanently.

7. **Mobile-first UI.** All layouts must work on 375px width first. Bottom navigation, bottom sheets (via `showAppModalBottomSheet`), swipe gestures. Follow triftly's UI patterns exactly.

8. **Follow triftly/depozio conventions exactly.** This is not optional:
   - `flutter_bloc` (Bloc, not Cubit)
   - `part` directives for event/state files
   - Stateless screen pages (StatelessWidget)
   - `BlocConsumer` with `listenWhen`/`buildWhen`
   - `go_router` with `StatefulShellRoute.indexedStack`
   - `AppPage` enum with `navBarMemberIndex`
   - `ScaffoldWithNavBar` + `NavBarMembersWidget`
   - `showAppModalBottomSheet(useRootNavigator: true)`
   - No SnackBar — silent completion + BLoC-driven UI
   - `Skeletonizer` for loading states
   - Satoshi font family
   - `flutter_form_builder` + `form_builder_validators`
   - `flutter_secure_storage` for tokens
   - `dio` for API calls
   - `--dart-define=ENV=dev/prod/stag` + flutter_dotenv
   - Feature-first structure: `lib/features/1_xxx`, `2_xxx`, etc.
   - `_standalone/` for non-nav pages (login, settings)

9. **Supabase RLS is the security boundary.** Since there's no BFF, Row Level Security policies must be correct. Every table must have RLS enabled. Test with both authenticated and anonymous contexts.

10. **Drift code generation.** Run `dart run build_runner build` after modifying Drift table definitions. Generated files (`*.g.dart`) should be committed to git.

---

## 17. Environment Variables

```bash
# env/.env.dev
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
GOOGLE_MAPS_API_KEY=AIza...
APP_DEEP_LINK_SCHEME=tripapp
APP_DEEP_LINK_HOST=trip.yky.dev

# env/.env.stag
# (same keys, staging values)

# env/.env.prod
# (same keys, production values)
```

**Run with environment:**
```bash
flutter run --dart-define=ENV=dev
flutter run --dart-define=ENV=prod
flutter build ios --dart-define=ENV=prod
flutter build apk --dart-define=ENV=prod
```

---

## 18. Infrastructure Cost

| Service | Tier | Cost | Purpose |
|---------|------|------|---------|
| **Supabase** | Free | $0 | PostgreSQL, Auth, 500MB, 50K MAU |
| **Frankfurter API** | Public | $0 | Exchange rates (no key needed) |
| **Google Maps** | Free tier | $0 | 28K loads/mo free (mobile SDK) |
| **Apple Developer** | Annual | $99/yr | TestFlight + App Store |
| **Google Play** | One-time | $25 | Play Console |
| **GitHub** | Free | $0 | Repo, CI |

**Total monthly cost: $0** (excluding one-time developer account fees)

---

## 19. Future Phase Architecture Support

### Phase 2: Collaboration

The schema already supports this:
- `users` table exists, linked to `trips.owner_id`
- `share_tokens.permission` can be extended to `"edit"`
- Supabase Realtime subscriptions can be added to repositories for live updates
- Add a `trip_members` join table for multi-owner trips
- Add `vote` / `comment` tables for social features

### Phase 3: AI

- Add AI route optimization: take spots + lat/lng → return optimized order (TSP solver)
- Add AI recommendations: take destination + preferences → return spot suggestions
- Both call an LLM API (Wayne's BytePlus Ark models) via Dio
- All AI features are client-side API calls (no custom server needed)

---

## 20. Getting Started (Engineer Handoff)

### 20.1 Scaffold Project

```bash
# 1. Create Flutter project
cd ~/Documents/Development/Git/yky/
flutter create trip-app --org io.trip --project-name trip_app
cd trip-app

# 2. Create directory structure
mkdir -p lib/router
mkdir -p lib/widgets/nav_bar
mkdir -p lib/widgets/bottom_sheets
mkdir -p lib/core/theme
mkdir -p lib/core/network
mkdir -p lib/core/storage
mkdir -p lib/core/services
mkdir -p lib/core/split
mkdir -p lib/core/localization
mkdir -p lib/core/l10n
mkdir -p lib/core/constants
mkdir -p lib/core/extensions
mkdir -p lib/core/helpers
mkdir -p lib/core/dto
mkdir -p lib/features/1_explore/bloc
mkdir -p lib/features/1_explore/data
mkdir -p lib/features/1_explore/models
mkdir -p lib/features/1_explore/presentation/pages
mkdir -p lib/features/1_explore/presentation/widgets/bottom_sheets
mkdir -p lib/features/2_plan/bloc
mkdir -p lib/features/2_plan/data
mkdir -p lib/features/2_plan/models
mkdir -p lib/features/2_plan/presentation/pages
mkdir -p lib/features/2_plan/presentation/widgets/bottom_sheets
mkdir -p lib/features/3_spend/bloc
mkdir -p lib/features/3_spend/data
mkdir -p lib/features/3_spend/models
mkdir -p lib/features/3_spend/presentation/pages
mkdir -p lib/features/3_spend/presentation/widgets/bottom_sheets
mkdir -p lib/features/4_profile/bloc
mkdir -p lib/features/4_profile/presentation/pages
mkdir -p lib/features/_standalone/login/bloc
mkdir -p lib/features/_standalone/login/presentation/pages
mkdir -p lib/features/_standalone/settings/presentation/pages
mkdir -p lib/features/_standalone/share_view/bloc
mkdir -p lib/features/_standalone/share_view/presentation/pages
mkdir -p lib/database/tables
mkdir -p lib/database/daos
mkdir -p env
mkdir -p assets/fonts
mkdir -p assets/lottie
mkdir -p assets/icon/app-icons
mkdir -p supabase/migrations
mkdir -p test/bloc
```

### 20.2 Install Dependencies

```bash
# Core deps (Wayne's conventions)
flutter pub add flutter_bloc equatable
flutter pub add go_router
flutter pub add flutter_form_builder form_builder_validators
flutter pub add flutter_dotenv
flutter pub add dio logger
flutter pub add flutter_secure_storage shared_preferences
flutter pub add cupertino_icons skeletonizer lottie url_launcher package_info_plus

# Supabase
flutter pub add supabase_flutter

# Offline
flutter pub add hive hive_flutter
flutter pub add drift sqlite3_flutter_libs

# Maps (Wayne's convention)
flutter pub add google_maps_flutter geolocator

# Money / calculations
flutter pub add decimal
flutter pub add nanoid

# Deep links / sharing
flutter pub add app_links
flutter pub add share_plus

# Connectivity
flutter pub add connectivity_plus

# l10n
flutter pub add flutter_localizations --sdk=flutter
flutter pub add intl

# Dev deps
flutter pub add --dev flutter_lints
flutter pub add --dev flutter_launcher_icons
flutter pub add --dev drift_dev build_runner
flutter pub add --dev bloc_test
flutter pub add --dev mocktail
```

### 20.3 Copy from Triftly

```bash
# Copy conventions from triftly-app (adjust paths as needed)
TRIFTLY=~/Documents/git/personal/triftly-app

# Theme
cp $TRIFTLY/lib/core/theme/theme.dart lib/core/theme/
cp $TRIFTLY/lib/core/theme/app_colors.dart lib/core/theme/
cp $TRIFTLY/lib/core/theme/theme_bloc.dart lib/core/theme/
cp $TRIFTLY/lib/core/theme/theme_event.dart lib/core/theme/
cp $TRIFTLY/lib/core/theme/theme_preference.dart lib/core/theme/
cp $TRIFTLY/lib/core/theme/theme_extension.dart lib/core/theme/

# Environment
cp $TRIFTLY/lib/core/environment.dart lib/core/

# Navigation widgets
cp $TRIFTLY/lib/widgets/nav_bar/scaffold_with_nav_bar.dart lib/widgets/nav_bar/
cp $TRIFTLY/lib/widgets/nav_bar/nav_bar_members_widget.dart lib/widgets/nav_bar/
cp $TRIFTLY/lib/widgets/bottom_sheets/app_bottom_sheet.dart lib/widgets/bottom_sheets/

# Core
cp $TRIFTLY/lib/core/network/api_client.dart lib/core/network/
cp $TRIFTLY/lib/core/network/api_interceptor.dart lib/core/network/
cp $TRIFTLY/lib/core/network/logger.dart lib/core/network/
cp $TRIFTLY/lib/core/network/storage.dart lib/core/storage/secure_storage.dart
cp $TRIFTLY/lib/core/constants/app_config.dart lib/core/constants/
cp $TRIFTLY/lib/core/constants/layout_constants.dart lib/core/constants/
cp $TRIFTLY/lib/core/extensions/localizations.dart lib/core/extensions/
cp $TRIFTLY/lib/core/helpers/date_helpers.dart lib/core/helpers/

# Fonts
cp -r $TRIFTLY/assets/fonts/ assets/fonts/

# Splash
cp $TRIFTLY/lib/widgets/splash_screen.dart lib/widgets/
cp -r $TRIFTLY/assets/lottie/ assets/lottie/

# l10n
cp $TRIFTLY/l10n.yaml .
cp -r $TRIFTLY/lib/core/l10n/ lib/core/l10n/
cp -r $TRIFTLY/lib/core/localization/ lib/core/localization/
```

### 20.4 Set Up Supabase

```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Initialize (creates supabase/ directory)
supabase init

# Start local Supabase (for development)
supabase start
# Copy the DB URL, anon key, and service key from output

# Create initial migration
# Copy SQL schema from §4.2 into supabase/migrations/00001_initial_schema.sql
supabase db push

# Or link to remote project
supabase link --project-ref your-project-ref
supabase db push
```

### 20.5 Configure Google Maps

```bash
# 1. Get API key from Google Cloud Console
#    Enable: Maps SDK for iOS, Maps SDK for Android, Geocoding API

# 2. Add to env files
echo "GOOGLE_MAPS_API_KEY=AIza..." >> env/.env.dev

# 3. iOS: Add GMSServicesKey to Info.plist
# 4. Android: Add com.google.android.geo.API_KEY to AndroidManifest.xml
# 5. Copy triftly's GoogleMapsKeyProvider pattern for secure key delivery
```

### 20.6 Build & Run

```bash
# Development
flutter run --dart-define=ENV=dev

# Run tests (CRITICAL: split calculator tests must pass first)
flutter test test/split_calculator_test.dart

# Build for release
flutter build ios --dart-define=ENV=prod
flutter build apk --dart-define=ENV=prod
```

### 20.7 Deploy

```bash
# iOS — Fastlane (copy from triftly)
cd ios
bundle install
bundle exec fastlane beta  # Upload to TestFlight

# Android — Fastlane
cd android
bundle install
bundle exec fastlane internal  # Upload to Play Console internal track
```

---

*This document is the single source of truth for the Trip App Flutter architecture. The Engineer agent should implement exactly this plan. Any deviations require CTO approval.*
