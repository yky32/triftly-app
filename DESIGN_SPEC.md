# Trip App — UI/UX Design Spec

**Project:** Trip App (Flutter Mobile)
**Author:** CTO, WY Limited
**Date:** 2026-06-19
**Status:** CEO Approved — Complete Redesign
**Design Philosophy:** Modern. Clean. Minimal.

---

## 0. Design Philosophy

> "Every element earns its place. No decorative noise. White space is a feature."

**Three words:** Modern. Clean. Minimal.

**Reference apps:**
- Things 3 — task clarity, whitespace mastery
- Linear — modern SaaS aesthetic, subtle depth
- Arc Browser — delightful interactions, clean cards
- Apple Weather — data beauty, minimal chrome
- Splitwise — expense clarity (but we're cleaner)

**Anti-references (do NOT copy):**
- ChicTrip — bloated, too many sections, pushy upsell
- Wanderlog — information overload, dense UI

**Post-launch branding:** Icon system, neobank-grade polish, and full visual identity pass are **deferred until after launch**. See [`docs/POST_LAUNCH_BRANDING.md`](docs/POST_LAUNCH_BRANDING.md). Until then, keep **Material Icons + Satoshi**; do not mix icon families in one-off PRs.

---

## 1. Design System

### 1.1 Color Palette

```
Primary:        #007AFF (Blue — trust, travel, sky)
Primary Light:  #4DA3FF
Primary Dark:   #0055CC

Surface:        #FFFFFF
Surface Dim:    #F8F9FA
Surface Card:   #FFFFFF

Text Primary:   #1A1A1A
Text Secondary: #6B7280
Text Tertiary:  #9CA3AF

Border:         #E5E7EB
Border Light:   #F3F4F6

Success:        #10B981
Warning:        #F59E0B
Error:          #EF4444

Category Colors:
  Food:         #FF6B6B
  Attraction:   #4ECDC4
  Hotel:        #45B7D1
  Transport:    #96CEB4
  Shopping:     #FFEAA7
  Other:        #DDA0DD
```

### 1.2 Typography

```
Font Family: Satoshi

Display:   Satoshi-Bold    28px  — Trip name, hero titles
H1:        Satoshi-Bold    22px  — Section titles
H2:        Satoshi-Bold    18px  — Card titles
H3:        Satoshi-Medium  16px  — Subtitles
Body:      Satoshi-Regular 14px  — Primary text
Caption:   Satoshi-Regular 12px  — Secondary text, timestamps
Overline:  Satoshi-Medium  11px  — Category labels, UPPERCASE

Line height: 1.5x font size
Letter spacing: -0.02em for headings, 0 for body
```

### 1.3 Spacing

```
4px   — Tight (icon-to-text)
8px   — Compact (list item internal)
12px  — Standard (card padding)
16px  — Comfortable (section padding)
24px  — Spacious (between sections)
32px  — Generous (page margins)
48px  — Hero spacing
```

### 1.4 Corner Radius

```
4px   — Small chips, tags
8px   — Buttons, inputs
12px  — Cards
16px  — Bottom sheets, modals
20px  — Large cards (featured)
Full  — Avatar, category dots
```

### 1.5 Shadows

```
Subtle:    0 1px 2px rgba(0,0,0,0.04)
Card:      0 2px 8px rgba(0,0,0,0.06)
Elevated:  0 4px 16px rgba(0,0,0,0.08)
Sheet:     0 -4px 24px rgba(0,0,0,0.10)
```

### 1.6 Animations

```
Standard:  200ms ease-out
Snappy:    150ms ease-out
Gentle:    300ms ease-in-out
Sheet:     350ms cubic-bezier(0.32, 0.72, 0, 1)
```

---

## 2. Navigation

### 2.1 Bottom Navigation Bar

Floating pill-style bottom nav. 4 tabs.

```
┌─────────────────────────────────────┐
│                                     │
│           [Page Content]            │
│                                     │
│                                     │
│    ┌───────────────────────────┐    │
│    │  🧭      📋      💰      👤 │    │
│    │ Explore  Plan   Spend  Me  │    │
│    └───────────────────────────┘    │
└─────────────────────────────────────┘
```

- Background: white with subtle shadow
- Active tab: Primary color + filled icon
- Inactive: Text Tertiary + outlined icon
- Height: 56px + safe area
- Floating: 16px horizontal margin, 12px bottom offset, 16px corner radius

### 2.2 Navigation Flow

```
App Launch
  ↓
Trip List (Home) ←─── default landing
  ├── Create Trip (bottom sheet)
  ├── Tap Trip → Trip Detail (3 tabs: Plan / Spend / Map)
  │     ├── Plan Tab
  │     │     ├── Add Spot (bottom sheet)
  │     │     ├── Edit Spot (bottom sheet)
  │     │     ├── Reorder Spots (drag)
  │     │     └── Day Detail
  │     ├── Spend Tab
  │     │     ├── Add Expense (bottom sheet)
  │     │     ├── Edit Expense (bottom sheet)
  │     │     └── Settlement Summary
  │     └── Map Tab
  │           └── Spot Detail (bottom sheet)
  ├── Explore Tab
  │     ├── Search Destination
  │     ├── Pro Route Detail
  │     └── Clone Route
  ├── Profile Tab
  │     ├── Settings
  │     └── About
  └── Share Link (deep link → Trip View, no login)
```

---

## 3. Page Inventory

### 3.1 Global Pages (bottom nav)

| # | Page | Tab | Purpose |
|---|------|-----|---------|
| G1 | Trip List | — | Home. All trips. Create new. |
| G2 | Explore | 🧭 | Discover pro routes, search destinations |
| G3 | Profile | 👤 | Settings, preferences, about |

### 3.2 Trip Detail Pages (inside a trip)

| # | Page | Tab | Purpose |
|---|------|-----|---------|
| T1 | Plan | 📋 | Day-by-day itinerary, spots |
| T2 | Spend | 💰 | Expenses, split, settlement |
| T3 | Map | 🗺️ | All spots on map |

### 3.3 Bottom Sheets

| # | Sheet | Trigger | Purpose |
|---|-------|---------|---------|
| S1 | Create Trip | FAB on Trip List | New trip form |
| S2 | Add Spot | FAB on Plan tab | Add spot to day |
| S3 | Edit Spot | Tap spot card | Edit spot details |
| S4 | Add Expense | FAB on Spend tab | Record expense |
| S5 | Edit Expense | Tap expense item | Edit expense |
| S6 | Settlement | Tap settlement card | Who owes whom |
| S7 | Share Trip | Share button | Generate share link |
| S8 | Spot on Map | Tap map marker | Quick spot detail |

### 3.4 Standalone Pages

| # | Page | Route | Purpose |
|---|------|-------|---------|
| P1 | Trip Share View | /s/[token] | Public read-only trip view |
| P2 | Pro Route Detail | /explore/[routeId] | Full pro route with clone button |

---

## 4. Page-by-Page Design

---

### G1. Trip List (Home)

**Purpose:** See all your trips. Create new ones. Quick access.

```
┌─────────────────────────────────────┐
│  Trip App                    🔔 👤  │  ← Minimal header
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🔍 Search trips...          │    │  ← Search bar (subtle)
│  └─────────────────────────────┘    │
│                                     │
│  Upcoming                           │  ← Section label (overline)
│  ┌─────────────────────────────┐    │
│  │ 🗼 Tokyo 2026              │    │  ← Trip card
│  │ Jun 28 - Jul 2 · 4 buddies  │    │
│  │ ●●●● ○                      │    │  ← Buddy avatars
│  │                  →          │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ 🏔️ Seoul Weekend            │    │
│  │ Jul 12 - Jul 14 · 3 buddies │    │
│  │ ●●● ○                       │    │
│  │                  →          │    │
│  └─────────────────────────────┘    │
│                                     │
│  Past                               │
│  ┌─────────────────────────────┐    │
│  │ 🌴 Bangkok 2025            │    │  ← Dimmed, smaller
│  │ Jan 5 - Jan 9               │    │
│  └─────────────────────────────┘    │
│                                     │
│                        [＋]         │  ← FAB: Create Trip
│    ┌───────────────────────────┐    │
│    │  🧭      📋      💰      👤 │    │
│    └───────────────────────────┘    │
└─────────────────────────────────────┘
```

**Design notes:**
- Trip cards: white, 12px radius, subtle shadow, 16px padding
- Upcoming trips: full color, buddy avatars as colored dots
- Past trips: 60% opacity, no buddy dots
- FAB: Primary color, 56px circle, bottom-right above nav bar
- Empty state: illustration + "Plan your first trip" + CTA button

---

### S1. Create Trip (Bottom Sheet)

**Trigger:** Tap FAB on Trip List

```
┌─────────────────────────────────────┐
│▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁│  ← Drag handle
│                                     │
│  New Trip                     [✕]   │
│                                     │
│  Trip Name                          │
│  ┌─────────────────────────────┐    │
│  │ e.g. Tokyo 2026             │    │
│  └─────────────────────────────┘    │
│                                     │
│  Destination                        │
│  ┌─────────────────────────────┐    │
│  │ 🔍 Where to?                │    │
│  └─────────────────────────────┘    │
│                                     │
│  Dates                              │
│  ┌──────────┐  ┌──────────┐        │
│  │ Jun 28   │  │ Jul 2    │        │
│  └──────────┘  └──────────┘        │
│                                     │
│  Default Currency                   │
│  ┌─────────────────────────────┐    │
│  │ JPY ¥                    ▼  │    │
│  └─────────────────────────────┘    │
│                                     │
│  Buddies                            │
│  ┌─────────────────────────────┐    │
│  │ + Add name                  │    │  ← Chip input
│  │ [Wayne ×] [Alice ×] [Bob ×]│    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │        Create Trip          │    │  ← Primary button, full width
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

**Design notes:**
- Sheet height: ~85% screen
- Rounded top corners: 16px
- Smooth spring animation
- Buddy names as removable chips (colored dots + name)
- Currency picker: dropdown with search
- Dates: tap opens native date picker

---

### T1. Plan Tab (Inside Trip)

**Purpose:** Day-by-day itinerary. Add, reorder, view spots.

```
┌─────────────────────────────────────┐
│  ← Tokyo 2026              ↗️ Share │  ← Header with back + share
│                                     │
│  ┌─────┬─────┬─────┬─────┬────┐    │
│  │Day 1│Day 2│Day 3│Day 4│ +  │    │  ← Horizontal day tabs
│  └─────┴─────┴─────┴─────┴────┘    │  ← Scrollable, active = Primary
│                                     │
│  Day 1 — Arrival                    │  ← Day title (editable)
│  Friday, Jun 28                     │  ← Date subtitle
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🍜 Ichiran Ramen           │    │  ← Spot card
│  │ 09:00-22:00 · 1h · ¥1,290  │    │  ← Hours, duration, cost
│  │ 📍 Shibuya                  │    │  ← Area
│  │                    ⋮        │    │  ← More (edit/delete/move)
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🏯 Meiji Shrine             │    │
│  │ Sunrise-16:30 · 2h · Free   │    │
│  │ 📍 Harajuku                 │    │
│  │                    ⋮        │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🍣 Sushi Zanmai            │    │
│  │ 11:00-22:30 · 1.5h · ¥4,800│    │
│  │ 📍 Ginza                   │    │
│  │                    ⋮        │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─    │  ← Dashed line = add area
│  + Add a spot                       │
│                                     │
│                        [＋]         │  ← FAB: Add Spot
│    ┌───────────────────────────┐    │
│    │  🧭      📋*     💰      👤 │    │  ← Plan tab active
│    └───────────────────────────┘    │
└─────────────────────────────────────┘
```

**Design notes:**
- Day tabs: horizontal scroll, active = Primary bg + white text
- Spot cards: white, left border = category color (4px)
- Drag handle on long press for reordering
- Category icon: emoji or outlined icon, 20px
- "Add a spot" dashed area: tap or FAB both work
- Empty day: "No spots yet" + illustration + Add button

---

### S2. Add Spot (Bottom Sheet)

**Trigger:** FAB or "Add a spot" on Plan tab

```
┌─────────────────────────────────────┐
│▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁│
│                                     │
│  Add Spot                     [✕]   │
│                                     │
│  Spot Name                          │
│  ┌─────────────────────────────┐    │
│  │ e.g. Ichiran Ramen          │    │
│  └─────────────────────────────┘    │
│                                     │
│  📍 Address                         │
│  ┌─────────────────────────────┐    │
│  │ 🔍 Search or enter address  │    │  ← Geocoding search
│  └─────────────────────────────┘    │
│                                     │
│  Category                           │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐   │
│  │🍜│ │🏯│ │🏨│ │🚃│ │🛍️│ │⋯ │   │  ← Horizontal chips
│  └──┘ └──┘ └──┘ └──┘ └──┘ └──┘   │  ← Active = filled + Primary
│                                     │
│  Opening Hours                      │
│  ┌─────────────────────────────┐    │
│  │ 09:00 - 22:00               │    │
│  └─────────────────────────────┘    │
│                                     │
│  Estimated Duration                 │
│  ┌─────────────────────────────┐    │
│  │ 1 hour                    ▼  │    │  ← Dropdown: 30m, 1h, 1.5h, 2h...
│  └─────────────────────────────┘    │
│                                     │
│  Notes (optional)                   │
│  ┌─────────────────────────────┐    │
│  │ Any tips or reminders...    │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │         Add Spot            │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

**Design notes:**
- Address search: live geocoding results dropdown
- Category chips: scrollable row, single select
- Duration: dropdown, not free text
- Notes: optional, 2-line max
- Map preview after address selected (small static map)

---

### T2. Spend Tab (Inside Trip)

**Purpose:** Track expenses, view splits, settle up.

```
┌─────────────────────────────────────┐
│  ← Tokyo 2026              ↗️ Share │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Total Spending             │    │  ← Summary card
│  │  ¥48,200                    │    │  ← Big number, Satoshi Bold
│  │  ≈ HK$2,580                 │    │  ← Converted (smaller, gray)
│  │                              │    │
│  │  🍜 Food ¥18,400  ████████ │    │  ← Category breakdown bar
│  │  🏨 Hotel ¥15,000  ██████  │    │
│  │  🚃 Transport ¥8,200 ███   │    │
│  │  🎫 Activity ¥4,800  ██    │    │
│  │  🛍️ Shopping ¥1,800  █     │    │
│  └─────────────────────────────┘    │
│                                     │
│  Day 1 — Jun 28                     │  ← Day header
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🍜 Ichiran Ramen           │    │  ← Expense item
│  │ Wayne paid · ¥3,870        │    │
│  │ Split: Wayne, Alice, Bob   │    │  ← Who's splitting
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🚃 Narita Express          │    │
│  │ Alice paid · ¥3,250        │    │
│  │ Split: All 4               │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🏨 Hotel check-in          │    │
│  │ Wayne paid · ¥15,000       │    │
│  │ Split: Wayne, Alice        │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 💰 Settlement               │    │  ← Settlement card (always visible)
│  │ Alice owes Wayne  ¥2,290   │    │
│  │ Bob owes Wayne    ¥1,290   │    │
│  │                    →       │    │
│  └─────────────────────────────┘    │
│                                     │
│                        [＋]         │  ← FAB: Add Expense
│    ┌───────────────────────────┐    │
│    │  🧭      📋      💰*     👤 │    │
│    └───────────────────────────┘    │
└─────────────────────────────────────┘
```

**Design notes:**
- Summary card: Primary bg gradient, white text, 16px radius
- Category bars: proportional width, category colors
- Expense items: left border = category color (4px)
- Settlement card: always at bottom of list, sticky
- Big numbers: Satoshi Bold 28px
- Converted amount: Caption size, Text Secondary

---

### S4. Add Expense (Bottom Sheet)

**Trigger:** FAB on Spend tab

```
┌─────────────────────────────────────┐
│▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁│
│                                     │
│  Add Expense                  [✕]   │
│                                     │
│  What did you spend on?             │
│  ┌─────────────────────────────┐    │
│  │ e.g. Lunch at Ichiran       │    │
│  └─────────────────────────────┘    │
│                                     │
│  Amount                             │
│  ┌──────────────┐ ┌──────────┐     │
│  │ ¥ 3,870      │ │ JPY    ▼│     │  ← Amount + currency
│  └──────────────┘ └──────────┘     │
│                                     │
│  Paid by                            │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐              │
│  │W │ │A │ │B │ │D │              │  ← Buddy avatars, single select
│  └──┘ └──┘ └──┘ └──┘              │  ← Active = Primary ring
│                                     │
│  Split between                      │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐              │
│  │W✓│ │A✓│ │B✓│ │D │              │  ← Multi-select with checkmarks
│  └──┘ └──┘ └──┘ └──┘              │
│                                     │
│  Split type                         │
│  ┌────────┐┌────────┐┌────────┐    │
│  │ Equal  ││Percent ││ Custom │    │  ← Segmented control
│  └────────┘└────────┘└────────┘    │
│                                     │
│  Category                           │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐   │
│  │🍜│ │🚃│ │🏨│ │🎫│ │🛍️│ │⋯ │   │
│  └──┘ └──┘ └──┘ └──┘ └──┘ └──┘   │
│                                     │
│  ┌─────────────────────────────┐    │
│  │       Add Expense           │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

**Design notes:**
- Amount: large input, Satoshi Bold, right-aligned
- Currency: dropdown, auto-defaults to trip currency
- Paid by: avatar circles with initials, single select
- Split between: same avatars, multi-select with checkmark overlay
- Split type: segmented control, default = Equal
- Equal split: auto-calculated per-person amount shown below
- Quick add: after saving, sheet stays open with cleared amount (batch entry)

---

### S6. Settlement Summary (Bottom Sheet)

**Trigger:** Tap settlement card on Spend tab

```
┌─────────────────────────────────────┐
│▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁│
│                                     │
│  Settlement                         │
│                                     │
│  Total: ¥48,200 (≈ HK$2,580)       │
│  Per person: ¥12,050               │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Wayne  paid ¥33,870       │    │  ← Green = gets money back
│  │  +¥9,120                   │    │
│  ├─────────────────────────────┤    │
│  │  Alice  paid ¥3,250        │    │  ← Red = owes money
│  │  -¥2,290                   │    │
│  ├─────────────────────────────┤    │
│  │  Bob    paid ¥0            │    │
│  │  -¥3,870                   │    │
│  ├─────────────────────────────┤    │
│  │  Dave   paid ¥11,080       │    │
│  │  -¥2,960                   │    │
│  └─────────────────────────────┘    │
│                                     │
│  Minimized Transactions             │  ← Settlement minimization
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Alice → Wayne   ¥2,290    │    │  ← Arrow = owes direction
│  │  Bob   → Wayne   ¥3,870    │    │
│  │  Dave  → Wayne   ¥2,960    │    │
│  └─────────────────────────────┘    │
│                                     │
│  Only 3 transactions needed!        │  ← Clean settlement
│                                     │
└─────────────────────────────────────┘
```

**Design notes:**
- Green = positive balance, Red = negative
- Minimized transactions: fewest possible payments
- Each transaction: from → to, amount, clear arrow
- Summary at top: total + per person average

---

### T3. Map Tab (Inside Trip)

**Purpose:** See all spots on map. Visual overview.

```
┌─────────────────────────────────────┐
│  ← Tokyo 2026              ↗️ Share │
│                                     │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │        🏯                   │    │  ← Map markers = category color
│  │              🍜             │    │
│  │                             │    │
│  │    🍣                       │    │
│  │          🏨                 │    │
│  │                             │    │
│  │  ─ ─ ─ Route line ─ ─ ─ ─ │    │  ← Dotted route between spots
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │  ← Bottom card (draggable)
│  │  Day 1  Day 2  Day 3        │    │  ← Day filter chips
│  │                              │    │
│  │  1. Ichiran Ramen    09:00  │    │  ← Ordered list
│  │  2. Meiji Shrine     11:00  │    │
│  │  3. Sushi Zanmai    13:00  │    │
│  └─────────────────────────────┘    │
│                                     │
│    ┌───────────────────────────┐    │
│    │  🧭      📋      💰      👤 │    │
│    └───────────────────────────┘    │
└─────────────────────────────────────┘
```

**Design notes:**
- Map: full width, rounded corners
- Markers: category-colored pins with number
- Route: dotted polyline connecting spots in order
- Bottom card: draggable sheet, shows spot list for selected day
- Day filter chips: scrollable, filter map markers
- Tap marker → S8 Spot on Map bottom sheet

---

### G2. Explore Tab

**Purpose:** Discover pro routes. Search destinations. Clone trips.

```
┌─────────────────────────────────────┐
│  Explore                            │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🔍 Where are you going?     │    │  ← Search bar
│  └─────────────────────────────┘    │
│                                     │
│  Popular Destinations               │  ← Section label
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │ 🗼   │ │ 🏔️   │ │ 🌴   │       │  ← Horizontal scroll cards
│  │Tokyo │ │Seoul │ │Bali  │       │
│  └──────┘ └──────┘ └──────┘       │
│                                     │
│  Trending Routes                    │
│  ┌─────────────────────────────┐    │
│  │  🗼 Tokyo 5-Day Explorer    │    │  ← Pro route card
│  │  by @tokyo_explorer          │    │
│  │  3.2K clones · ⭐ 4.8       │    │
│  │  ¥48,000/person             │    │
│  │                    [Clone]  │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │  🍣 Foodie Tokyo 4-Day     │    │
│  │  by @foodie_jp               │    │
│  │  1.8K clones · ⭐ 4.6       │    │
│  │  ¥72,000/person             │    │
│  │                    [Clone]  │    │
│  └─────────────────────────────┘    │
│                                     │
│    ┌───────────────────────────┐    │
│    │  🧭*     📋      💰      👤 │    │
│    └───────────────────────────┘    │
└─────────────────────────────────────┘
```

**Design notes:**
- Search: prominent, top of page
- Destination cards: square image + name, horizontal scroll
- Pro route cards: full width, author avatar, stats, clone button
- Clone button: Primary color, outlined, "Clone" text
- Phase 2 feature — MVP shows placeholder with "Coming soon"

---

### S7. Share Trip (Bottom Sheet)

**Trigger:** Share button on trip header

```
┌─────────────────────────────────────┐
│▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁│
│                                     │
│  Share Trip                         │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  🔗 trip.app/s/abc123XYZ456 │    │  ← Share link
│  │                       [📋]  │    │  ← Copy button
│  └─────────────────────────────┘    │
│                                     │
│  Anyone with this link can view     │
│  your trip itinerary and expenses.  │
│                                     │
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │ 📱   │ │ 💬   │ │ 📨   │       │  ← Share targets
│  │iMsg  │ │WhatsApp│ │Email │       │
│  └──────┘ └──────┘ └──────┘       │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  QR Code                    │    │  ← QR code for sharing
│  │  ┌─────────────────────┐    │    │
│  │  │  ▓▓ ░░ ▓▓ ░░ ▓▓    │    │    │
│  │  │  ░░ ▓▓ ░░ ▓▓ ░░    │    │    │
│  │  │  ▓▓ ░░ ▓▓ ░░ ▓▓    │    │    │
│  │  └─────────────────────┘    │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

---

### P1. Trip Share View (Public, No Login)

**Route:** /s/[token]
**Purpose:** View-only trip. Viral growth engine.

```
┌─────────────────────────────────────┐
│                                     │
│  🗼 Tokyo 2026                      │  ← Trip name
│  Jun 28 - Jul 2 · 4 buddies         │
│                                     │
│  ┌─────┬─────┬─────┐               │
│  │Plan │Spend│ Map │               │  ← Tab bar (view only)
│  └─────┴─────┴─────┘               │
│                                     │
│  [Same content as T1/T2/T3          │
│   but read-only — no FAB,           │
│   no edit, no delete]               │
│                                     │
│  ┌─────────────────────────────┐    │
│  │    Plan your own trip       │    │  ← CTA banner at bottom
│  │    Download Trip App    →   │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

**Design notes:**
- No login required
- Read-only: no FAB, no edit, no delete buttons
- CTA banner: sticky at bottom, Primary color, "Download" link
- This is the viral loop entry point

---

### G3. Profile Tab

**Purpose:** Settings, preferences, about.

```
┌─────────────────────────────────────┐
│  Profile                            │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  👤                          │    │  ← Avatar (placeholder)
│  │  Wayne                       │    │
│  │  wayne@email.com             │    │
│  └─────────────────────────────┘    │
│                                     │
│  Preferences                        │
│  ┌─────────────────────────────┐    │
│  │  Default Currency      HKD →│    │
│  ├─────────────────────────────┤    │
│  │  Dark Mode              ○   │    │  ← Phase 2
│  ├─────────────────────────────┤    │
│  │  Language              EN  →│    │  ← Phase 2
│  └─────────────────────────────┘    │
│                                     │
│  Data                               │
│  ┌─────────────────────────────┐    │
│  │  Export All Trips           →│    │
│  ├─────────────────────────────┤    │
│  │  Clear Offline Data         →│    │
│  └─────────────────────────────┘    │
│                                     │
│  About                              │
│  ┌─────────────────────────────┐    │
│  │  Version 1.0.0              │    │
│  │  Made by WY Limited         │    │
│  └─────────────────────────────┘    │
│                                     │
│    ┌───────────────────────────┐    │
│    │  🧭      📋      💰      👤* │    │
│    └───────────────────────────┘    │
└─────────────────────────────────────┘
```

**Design notes:**
- Settings items: iOS-style rows with chevron
- Minimal for MVP — just currency + version
- Phase 2: dark mode, language, export

---

## 5. Component Library

### 5.1 Trip Card

```
┌─────────────────────────────┐
│ 🗼 [Destination emoji]       │  ← Emoji from destination
│ [Trip Name]           [→]  │  ← Satoshi Bold 18px
│ [Date range · N buddies]   │  ← Caption, Text Secondary
│ [●●●● ○]                   │  ← Buddy dots (colored)
└─────────────────────────────┘
```

### 5.2 Spot Card

```
┌─────────────────────────────┐
│▎ [Category Icon] [Name]     │  ← Left border = category color
│  [Hours] · [Duration] · [¥] │  ← Caption
│  📍 [Area]            [⋮]  │  ← More menu
└─────────────────────────────┘
```

### 5.3 Expense Item

```
┌─────────────────────────────┐
│▎ [Category Icon] [Title]    │  ← Left border = category color
│  [Payer] paid · [Amount]    │  ← Caption
│  Split: [buddy names]       │  ← Smaller caption
└─────────────────────────────┘
```

### 5.4 Buddy Avatar

```
┌──────┐
│  W   │  ← Initial, Satoshi Medium 14px
└──────┘  ← 32px circle, random pastel bg
```

### 5.5 Category Chip

```
┌──────────┐
│ 🍜 Food  │  ← Emoji + label
└──────────┘  ← Active: Primary border + bg tint
              ← Inactive: Border only
```

### 5.6 Day Tab

```
┌──────┐
│Day 1 │  ← Active: Primary bg, white text
└──────┘  ← Inactive: Surface Dim bg, Text Secondary
```

### 5.7 FAB (Floating Action Button)

```
   ┌────┐
   │ ＋ │  ← 56px circle, Primary color, white icon
   └────┘  ← Elevation shadow, bottom-right above nav
```

---

## 6. Interaction Patterns

### 6.1 Bottom Sheet

- Drag handle: 36px wide, 4px height, centered, Border color
- Dismiss: swipe down, tap ✕, or tap outside
- Animation: 350ms spring curve
- Height: content-dependent, max 85% screen

### 6.2 Drag to Reorder

- Long press spot card → haptic feedback → lift animation
- Shadow increases while dragging
- Drop zone highlights with Primary tint
- Release → smooth snap into position

### 6.3 Swipe Actions (Phase 2)

- Spot card: swipe left → delete (red)
- Expense item: swipe left → delete (red), swipe right → edit (blue)

### 6.4 Pull to Refresh

- Standard iOS/Android pull-to-refresh
- Spinner: Primary color
- Refreshes data from Supabase

### 6.5 Empty States

Each empty state has:
- Centered illustration (simple line art)
- One-line message ("No spots yet")
- CTA button ("Add your first spot")

---

## 7. Responsive Notes

- Primary target: iPhone 15 (393×852) and Pixel 8 (412×915)
- Minimum supported: iPhone SE (375×667)
- Bottom nav: always visible, safe area aware
- Bottom sheets: full width with 16px horizontal margin
- Cards: full width with 16px horizontal margin
- Map: full bleed (no horizontal margin)

---

*Designed by WY Limited — The Agentic Dev Team*
*CTO: Agent | COO: ai-Wayne | CEO: Wayne*
