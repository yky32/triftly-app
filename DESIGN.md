# Triftly — Product architecture

Light-mode-first Flutter app. Design tokens live in `lib/core/theme/` (`AppColors`, `CustomTheme`).

## Use cases → screens

| Use case | Screen | Nav |
|----------|--------|-----|
| Plan a trip (days + spots) | **Trips** list + **Plan trip** (`/trips/plan`) | Trips tab + full-screen planner |
| Share with travel buddies | Trip detail → **Invite** (placeholder deep link; login required later) | — |
| Handy view while travelling | **Today** — today’s spots, check-offs, progress | Today tab |
| Follow the routine | Same data as planner; Today toggles spot completion | Today tab |
| Track trip spending | **Spend** — budget UI tied to active trip dates | Spend tab |

## Navigation (minimal)

Bottom bar — **3 tabs only** (`AppConfig.enabledNavPages`):

1. **Today** — in-trip companion  
2. **Trips** — library + entry to planner  
3. **Spend** — group spending for the active trip  

Full-screen (no bottom bar):

- `/trips/plan` — day carousel, add/edit spots (`RoutineBuilderPage`)  
- `/login`, `/settings`  
- `/map` — optional, off by default  

Configured in `lib/core/constants/app_config.dart` and `lib/router/app_page.dart`.

## Data (current)

Single source of truth for itinerary: `RoutineRepository` (SharedPreferences).

- One **active saved routine** (trip + spots by day + labels)  
- **Saved trip summaries** for the Trips grid  
- **Active trip** = saved routine whose date range includes today → powers Today + Spend  

Future: backend sync, multi-trip storage, spend ledger, share/deep-link service.

## Layers

```
lib/
  core/           theme, env, navigation helpers
  router/         go_router shell + overlay routes
  features/
    1_today/      in-trip dashboard (TodayBloc)
    2_trips/      trip library (TripsBloc)
    3_routine_builder/  planner UI + RoutineRepository
    5_spend_tracker/    spend tab (SpendBloc → active trip)
    _standalone/  login, settings
  services/       trip_share_service (placeholder)
  widgets/        nav bar, bottom sheets
```

## Patterns

- **Bloc** + **stateless** screens (see README)  
- **No SnackBar** — inline state, sheets, dialogs  
- **Skeletonizer** for loading  
- Planner opens via `AppNavigation.openTripPlanner()` (`context.push`)

## Extending

- **Share**: implement `TripShareService` + auth gate after login API is real  
- **Spend**: add `SpendRepository` keyed by trip id  
- **Map**: re-enable `AppPage.map` in `AppConfig`; spots can deep-link to map  
