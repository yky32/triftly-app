# Spend: Global Page vs Trip Tab

Validation doc for the two-surface spending experience in Triftly.

## Two surfaces, one ledger

| Surface | Route | Scope | Question it answers |
|---------|-------|-------|-------------------|
| **Spend page** | `/spend` (bottom nav) | **You**, across all trips | How am I doing overall? What do I owe / am owed? |
| **Spend tab** | `/plan/:tripId?tab=spend` | **This trip only** | How is this trip going? Who owes whom on this trip? |

Both read from the same expense ledger (`Expense` per `tripId`). No duplicate data — different aggregation and navigation context.

```
                    ┌─────────────────────┐
                    │   Expense ledger    │
                    │  (per trip, local)  │
                    └──────────┬──────────┘
                               │
              ┌────────────────┴────────────────┐
              ▼                                 ▼
     ┌─────────────────┐               ┌─────────────────┐
     │   Spend page    │               │   Spend tab     │
     │  Global / Me    │◄── navigate ──│  Trip scope     │
     └─────────────────┘               └─────────────────┘
```

## Spend page (global)

**Primary user:** traveller managing money across multiple trips.

### Sections (MVP in this PR)

1. **Me summary** — total paid, my share, net owed / owing (demo: buddy named "Wayne")
2. **Who owes whom** — cross-trip net with buddies (aggregated settlements per trip, surfaced as cards)
3. **Recent transactions** — latest expenses across trips, grouped by trip
4. **Per-trip cards** — tap → open trip Spend tab

### Future ideas

- Filter by trip phase (Active · Upcoming · Done)
- Search transactions by title / category
- Monthly spending chart (personal, not trip-total)
- "Settle up" action → deep link to trip settlement sheet
- Multi-currency wallet view (HKD equivalent totals)
- Notifications: "Ken owes you ¥2,400 on Tokyo trip"
- Quick-add expense → pick trip first, then sheet

## Spend tab (trip)

**Primary user:** group on a single trip splitting costs.

### Sections (existing + integration)

1. Today spending strip (in-progress trips)
2. Trip total + category breakdown
3. Day-grouped transaction list (swipe delete, tap edit)
4. Settlement card → full settlement sheet
5. **New:** scope banner — "View all my spending" → Spend page

### Future ideas

- Read-only expense detail sheet before edit (PR B in prior plan)
- Buddies card (paid / owed / net per person)
- Filters, search, sort for long trip ledgers
- Export CSV / split summary for the group

## Shared building blocks

| Component | Used by |
|-----------|---------|
| `SpendLedgerService` | Both — load & aggregate expenses |
| `SpendTransactionTile` | Global recent list; trip tab can adopt later |
| `SpendSettlementPreview` | Global trip cards; trip tab settlement card |
| `SplitCalculator` | Settlement math (already shared) |

## Identity ("me")

Until auth + profile ships, demo uses the first buddy named **Wayne** in each trip. Production should map `userId → buddyId` per trip (or a stable `isMe` flag on `Buddy`).

## Navigation contract

| From | To | Action |
|------|-----|--------|
| Spend page → trip card | Trip Spend tab | `context.go('/plan/$tripId?tab=spend')` |
| Spend tab → global link | Spend page | `context.go('/spend')` |
| Plan today card → spend | Trip Spend tab | existing `onOpenSpendTab` |

## Phased delivery (after validation)

| Phase | Scope |
|-------|--------|
| **A (this PR)** | Vision doc, ledger service, Spend page MVP, nav integration |
| **B** | Expense detail bottom sheet (read → edit / delete) |
| **C** | Buddies breakdown card on trip tab |
| **D** | Filters / search on trip tab; global filters |
| **E** | Refactor trip `SpendTab` to shared widgets |

## Open questions

1. Should global "me" net sum across currencies or show per-currency buckets?
2. Show upcoming trips with $0 spending, or hide until first expense?
3. Is Explore-style empty state enough when user has no trips with expenses?
