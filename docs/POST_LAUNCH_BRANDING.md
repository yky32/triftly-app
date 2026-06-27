# Post-launch branding & UI polish

**Status:** Deferred until after launch  
**Decision date:** 2026-06-23  
**Owner:** Wayne / WY Limited  

---

## Decision

Ship the current functional UI for launch. Run a dedicated **branding pass** afterward — custom icon language, neobank-grade polish, and visual consistency — without blocking cloud sync, share, or TestFlight milestones.

**Do not** block launch work on icon packs, custom SVG sets, or a full design-system rewrite.

---

## Current state (pre-launch)

| Area | Today |
|------|--------|
| **Icons** | Flutter **Material Icons** (mostly `_outlined` / `_rounded`) |
| **Font** | **Satoshi** (Bold / Medium / Regular) |
| **Chrome** | Liquid glass surfaces (`GlassSurface`, nav island, spend shells) |
| **Sync status** | Center app-bar pill on Trips (`TripsSyncCenterBanner`) — cloud Material icons |
| **Reference vibe** | Things 3, Linear, Arc — see `DESIGN_SPEC.md` §0 |

---

## Target direction (post-launch)

Inspiration discussed: **Mox Bank**-style neobank UI — youthful, local, minimal chrome, soft rounded strokes. Mox uses a **custom proprietary icon set** (R/GA design system), not an off-the-shelf pack. Goal for Triftly is to **match the feel**, not copy assets.

**Reference (mood only):**

- https://marklaw.me/mox  
- https://www.t8creations.com/mox  

**Icon candidates to evaluate (pick one system, apply app-wide):**

| Option | Browse | Notes |
|--------|--------|--------|
| **Phosphor** (recommended first look) | https://phosphoricons.com | Light/Regular weights; friendly fintech feel |
| **Lucide** | https://lucide.dev/icons | Clean outline; sharp modern SaaS |
| **Material Symbols Rounded** | https://fonts.google.com/icons?icon.style=Rounded | Smallest migration from today |
| **SF Symbols** (iOS-first) | https://developer.apple.com/sf-symbols/ | Native on iPhone; Android needs fallback |
| **Custom SVG set** | — | True brand ownership; highest effort |

**Trips sync pill — icon mapping to revisit:**

| State | Material (today) | Phosphor (example) |
|--------|------------------|---------------------|
| Synced | `cloud_done_outlined` | `cloudCheck` (Light) |
| Signed out / local | `cloud_off_outlined` | `cloudSlash` |
| Syncing | `CircularProgressIndicator` | `arrowsClockwise` / `circleNotch` |
| Error | `cloud_off_outlined` | `cloudWarning` or dot-only |

Alternative considered: **status dot + text only** (no cloud glyph) for a more premium neobank look.

---

## Scope (post-launch epic)

### P0 — Icon & status language

- [ ] Choose icon system (Phosphor vs Lucide vs custom vs hybrid iOS/Android)
- [ ] Define weight + size tokens (e.g. 14px Light in pills, 20px Regular in lists)
- [ ] Replace sync pill icons (`lib/core/widgets/cloud_sync_banner.dart`)
- [ ] Audit tab bar, app bars, trip cards, sheets, Tools grid

### P1 — Brand cohesion

- [ ] Icon + typography pairing review (Satoshi + chosen icon stroke weight)
- [ ] Color token pass (primary, tertiary text, error/sync states)
- [ ] Empty states & illustrations (line art vs icon-only)
- [ ] Dark mode polish (currently light-first)

### P2 — Optional custom brand

- [ ] Commission or draw Triftly-specific icons (Explore, Plan, Spend metaphors)
- [ ] App icon / splash alignment with in-app icon language
- [ ] Marketing site ↔ app visual parity

---

## Out of scope until branding epic

- Swapping icons ad hoc in individual PRs (avoid mixed icon families)
- Duotone / heavy Fill icons in small chips (keep pills minimal)
- Copying Mox or any bank’s proprietary assets

---

## Implementation notes (when started)

1. Add one Flutter package (e.g. `phosphoricons_flutter`) or asset pipeline for SVGs — **single source**, not mixed with Material.
2. Introduce a thin wrapper (e.g. `TriftlyIcons.syncSuccess`) so screens don’t import pack names directly.
3. Update `ARCHITECTURE.md` Icons row and `assets/icons/ATTRIBUTION.md` with license/attribution.
4. Regression pass: Trips tab, Me/Profile, Tools, trip detail tabs, bottom sheets.

---

## Related docs

- `DESIGN_SPEC.md` — current design system (pre-branding)
- `.cursor/rules/liquid-glass-ui.mdc` — glass surfaces (keep during branding)
- `.cursor/rules/trips-ui-polish.mdc` — sheet/trips patterns (keep during branding)
- `docs/SPEND_VISION.md` — Spend product vision (separate from visual branding)

---

*Last updated: 2026-06-23*
