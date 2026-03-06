# Triftly

**Drift Through Your Day – Plans, Maps, Budget**

A production-ready Flutter app with enterprise-grade features and best practices.

## 🚀 Core Features

- Theming scaffolding with [`ThemeExtension`](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)
- Routing scaffolding with [`go_router`](https://pub.dev/packages/go_router)
- Localization scaffolding with [`flutter_localizations`](https://pub.dev/packages/flutter_localizations)
- State management with [`flutter_bloc`](https://pub.dev/packages/flutter_bloc)
- Forms with [`flutter_form_builder`](https://pub.dev/packages/flutter_form_builder) and [`form_builder_validators`](https://pub.dev/packages/form_builder_validators)
- Toggle environment variables with a single argument (`--dart-define=ENV=dev`, `--dart-define=ENV=stag`, `--dart-define=ENV=prod`)

## Getting Started

Clone the repository and use it as a base for development.

Use the following command to install dependencies:

```bash
flutter pub get
```

To run the app, run the following command:

```bash
flutter run
```

## Environment Variables

Go to the `env` folder and edit the files inside, then run the app with the `--dart-define` argument.

```bash
flutter run --dart-define=ENV=dev
```

Or replace `dev` with `stag` or `prod` to toggle between staging and production environments.

## Theming

Define all styles in the `theme/theme.dart` file. Do not define styles inside components.
If you want to define some variables that are not available in the `ThemeData` class, you can define them in the `theme/theme_extension.dart` file.

## Routing

Define all routes in the `enum/route.dart` file, then update the `route/router_config.dart` file.

## Localization

To create a new locale, create a new file inside the `l10n` folder and run the app, the localization will be generated automatically.

## State Management

Use **Bloc only** (no Cubit). All state is managed via [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) with events and states. Define blocs as specific as possible—e.g. `LoginBloc`, `ThemeBloc`, `ForgotPasswordBloc`—and avoid a single catch‑all bloc (e.g. no `UserBloc` for all auth logic).

## Bottom Sheets

Bottom sheets in this app follow a consistent set of behaviors and design rules:

- **Drag handle** – Every bottom sheet shows a drag handle (pill) at the top to signal that it can be dragged to dismiss. Use `BottomSheetDragHandle` from `app_bottom_sheet.dart`.
- **Tap-to-unfocus** – Tapping outside any focused text field must unfocus it and dismiss the keyboard so the sheet content is not blocked. Wrap sheet content in `TapToUnfocus` from `app_bottom_sheet.dart`.
- **Borderless inputs** – Text fields inside bottom sheets use borderless styling (no visible border; optional subtle underline). Do not use outlined or filled bordered fields in sheets.
- **Keyboard insets** – Sheet layout must account for the keyboard (e.g. `MediaQuery.viewInsetsOf(context).bottom`) so content remains visible and scrollable when the keyboard is open.
- **Present via `showAppModalBottomSheet`** – Use the shared helper in `app_bottom_sheet.dart` so sheets use the root navigator and consistent styling.

Do not use `SnackBar` / `showSnackBar` in this app; use other patterns for feedback (e.g. inline validation, dialogs, or in-sheet messaging).

## Layout & nav bar

To avoid content being blocked by the bottom nav bar, use the global layout constants in `lib/core/constants/layout_constants.dart`:

- **`LayoutConstants.scrollPaddingBelowNavBar(BuildContext context)`** – Returns the bottom padding (safe area + nav bar height) to use for scroll views and lists so the last items are visible above the nav bar.
- **`LayoutConstants.bottomNavBarHeight`** – The nominal nav bar height (72); adjust here if the nav bar design changes.
- **`LayoutConstants.scrollPaddingBelowNavBarInsets(BuildContext context)`** – Same as above but returns `EdgeInsets.only(bottom: ...)` for padding widgets.

Use for any scrollable content that could extend behind the bottom nav (e.g. `SingleChildScrollView`, `ListView`, day itinerary).

## Map & location data

The map tab uses **Geocoding** (and is prepared for **Places**) so users see useful info when tapping the map and can later add spots to the routine builder.

- **Geocoding**: Set `GOOGLE_MAPS_API_KEY` in `env/.env.dev` (same key as Maps). Enable **Geocoding API** in [Google Cloud Console](https://console.cloud.google.com/apis/library/geocoding-backend.googleapis.com) for the same project. Reverse geocode turns a tap (LatLng) into address and place ID.
- **MapLocation** in `lib/features/map_view/models/map_location.dart` holds: title, address, description, position, plus optional `placeId`, `rating`, `types`, `openingHoursText`, `photoUrl`, `website`, `phoneNumber`, `locality` for when you add Places API later.
- **Places API**: Place Details is integrated. After reverse geocode, the app fetches place details by `place_id` (rating, opening hours, photo, website, phone). Enable **Places API** in Cloud Console. The bottom sheet shows photo, rating, types, opening hours, website, and phone when returned.

**Troubleshooting: Map shows "Dropped pin" (no POI/address) on real device**

If the location detail sheet shows only "Dropped pin" and coordinates when tapping the map on a **real device** (while it works in simulator), check:

1. **API key on device** – The app loads `GOOGLE_MAPS_API_KEY` from `env/.env.dev` (or `.env.stag` / `.env.prod` when built with `ENV=stag` or `ENV=prod`). For TestFlight/release builds, ensure the env file used for that build contains the key (e.g. `env/.env.prod` if you build with `--dart-define=ENV=prod`).
2. **API key restrictions** – In [Google Cloud Console](https://console.cloud.google.com/apis/credentials) → your API key → Application restrictions: if set to "iOS apps", add your **iOS bundle ID** (e.g. `com.yourcompany.triftly`). If set to "Android apps", add your **package name** and SHA-1. A key restricted to a debug certificate or simulator may work in dev but not on a real device or TestFlight.
3. **APIs enabled** – Enable **Geocoding API** and **Places API** (and **Maps SDK for iOS** / **Maps SDK for Android**) for the same Google Cloud project.
4. **Debug logs** – Run the app from Xcode (iOS) or Android Studio and watch the console. On failure you’ll see `[GeocodingService]` or `[PlacesService]` messages (e.g. key missing, `status=REQUEST_DENIED`, or an exception). Fix the reported cause (key, restrictions, or network).

## Map ↔ Routine Builder integration

The **Map** tab and **Routine Builder** are wired both ways so users can add spots from the map and fill spot location from the map.

**Map → Routine (add spot from map)**

- On the Map tab, search or tap a point → location detail bottom sheet opens.
- **"Add to routine"** converts the MapLocation to a RoutineSpot (title, address, description, default times), closes the sheet, and navigates to the **Routine** tab with that spot as route `extra`.
- The Routine page opens the add-spot bottom sheet pre-filled with the spot; the user can adjust times/icon and save.

**Routine → Map (pick location for a spot)**

- In **Add spot** or **Edit spot** (routine day), the **Location** field has a **"Pick on map"** button.
- Tapping it opens **Map** in pick mode (`MapViewPage.pickLocation`): same map UI with app bar “Pick location”, user taps on the map → we reverse geocode and fetch place details → “Use this location” returns the result to the sheet.
- A preview card shows title and address with **"Use this location"** / **"Choose another"**. On **Use this location**, the picker pops and returns the MapLocation to the sheet.
- The add/edit spot sheet then fills **Location** (address), **Title** (if empty), and **Description** (if returned) from the picked location.

Shared pieces: `buildMapLocationFromTap` in `lib/features/map_view/utils/location_from_tap.dart`, GeocodingService, PlacesService. The map picker reuses this logic so behaviour matches the Map tab.

## Share from Google Maps (native app → Triftly)

Users can search a location in the **native Google Maps app** and use **Share → Triftly** to open that location in the app’s map tab.

**Flow**

1. User opens Google Maps, searches or selects a place, taps **Share**.
2. System share sheet appears; user chooses **Triftly**.
3. Triftly opens (or comes to foreground), shows splash briefly, then navigates to the **Map** tab with the shared location: map centers on it, shows the pin, and opens the location detail bottom sheet (reverse geocode + place details). User can then “Add to routine” as usual.

**Android**

- The app is a **share target** for `text/plain`. When the user picks Triftly from the share sheet, the main activity receives the shared URL (or text) via `Intent.ACTION_SEND` and `EXTRA_TEXT`. `MainActivity` stores it and exposes it to Flutter via the `app/share` method channel (`getPendingSharedUrl`). Splash screen calls `ShareReceiverService.getPendingSharedLocation()`, parses the URL with `GoogleMapsShareParser`, and navigates to `/map` with the parsed `LatLng` as route extra.

**iOS**

- The app registers the **URL scheme** `triftly://`. Opening `triftly://map?url=<encoded_google_maps_url>` stores the URL and passes it to Flutter via the same `app/share` channel so the map can show the location.
- To have **Triftly appear in the system Share sheet** when the user taps Share in Google Maps, add a **Share Extension** in Xcode:
  1. File → New → Target → Share Extension.
  2. Name it e.g. “Triftly Share”, use the same bundle ID with a suffix (e.g. `com.yky.triftly.share`).
  3. In the extension’s `Info.plist`, set `NSExtensionActivationSupportsWebURLWithMaxCount` / support `public.url` and `public.plain-text`.
  4. In the extension’s view controller, get the shared URL from `NSExtensionContext.inputItems`, then open the main app:  
     `UIApplication.shared.open(URL(string: "triftly://map?url=\(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)`  
     and call `extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)`.
  5. Ensure the main app’s **App Groups** (if used) or URL scheme is configured so the extension can open the app.

**Parsing**

- `lib/features/map_view/utils/google_maps_share_parser.dart` parses common Google Maps share URLs (`?q=lat,lng`, `?query=...`, `/@lat,lng,zoom`, and plain `lat,lng` text) and returns a `LatLng` so the map can center and show the detail sheet.
