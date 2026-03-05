# Map terminology

A short reference for map-related terms used in this app and in Google’s APIs.

---

## Map items (sources in this app)

| Term | Meaning |
|------|--------|
| **Our markers** | POIs we define in code (e.g. sample locations). Full control over title, description, address, position. |
| **Tapped point** | A location the user taps on the map. We get only **LatLng** from the map; we then call **Geocoding** (and **Places**) to get address, name, types, etc. |

---

## Google APIs we use

| Term | Meaning |
|------|--------|
| **Geocoding API** | Converts **coordinates (LatLng) ↔ address**. We use **reverse geocoding**: LatLng → formatted address, `place_id`, `address_components`, **types**. |
| **Places API** | Rich place data. We use **Place Details**: given a **place_id** (from Geocoding), returns name, rating, opening hours, photo, website, phone, **types**. |
| **Maps SDK** | Renders the map and handles markers, camera, and tap (we get LatLng only; no built‑in “place name” for a tap). |

---

## Identifiers and geography

| Term | Meaning |
|------|--------|
| **LatLng** | Latitude and longitude (e.g. `22.3193, 114.1694`). The only data we get from a map tap. |
| **place_id** | Google’s stable ID for a place. From Geocoding or Places; use it to call Place Details. |
| **formatted_address** | Human‑readable full address (from Geocoding or Place Details). |
| **locality** | Short area name (e.g. city, district) from address_components — e.g. “Shibuya”, “Central”. |
| **address_components** | Structured address parts (street, city, country, etc.) with **types** (e.g. `locality`, `country`). |

---

## Place types (categories)

Google assigns **types** to a place (e.g. from Geocoding or Place Details). We store them in `MapLocation.types` and show them in the location detail bottom sheet.

### Point of interest vs establishment

| Term | Meaning |
|------|--------|
| **Point of interest (POI)** | A place people might want to go or notice. Can be natural or man‑made, with or without a business (e.g. landmark, park, monument, building, or a shop). |
| **Establishment** | A run place: business or facility with a name, usually address/hours/contact (e.g. restaurant, gym, museum, hotel). Many establishments are also returned as `point_of_interest`. |

### Common types (examples)

| Category | Example types |
|----------|----------------|
| Business / venue | `restaurant`, `cafe`, `bar`, `gym`, `spa`, `store`, `shopping_mall`, `supermarket` |
| Attractions | `tourist_attraction`, `museum`, `park`, `zoo`, `stadium`, `amusement_park` |
| Transport / travel | `transit_station`, `airport`, `train_station`, `bus_station`, `lodging`, `travel_agency` |
| Services | `bank`, `hospital`, `pharmacy`, `police`, `post_office`, `gas_station` |
| Administrative | `locality`, `administrative_area_level_1`, `political`, `neighborhood` |
| Generic | `point_of_interest`, `establishment`, `premise` |

Google often returns several types per place (e.g. `["gym", "point_of_interest", "establishment"]`). We show the first as the main category and all of them as chips in the bottom sheet.

---

## In this codebase

| Term | Where / meaning |
|------|------------------|
| **MapLocation** | Model in `lib/features/map_view/models/map_location.dart`. Holds id, title, address, position, plus optional placeId, rating, types, openingHoursText, photoUrl, website, phoneNumber, locality. |
| **GeocodingService** | `lib/features/map_view/data/geocoding_service.dart`. Reverse geocode (LatLng → address, place_id, locality, types). |
| **PlacesService** | `lib/features/map_view/data/places_service.dart`. Place Details by place_id → rating, hours, photo, website, phone, types. |
| **Location detail bottom sheet** | `location_detail_bottom_sheet.dart`. Shows one MapLocation: photo, title, rating, **all types** (chips), actions (Directions, Call, Save), address, hours, website, phone, coordinates. |

---

## Quick flow (tap on map)

1. User taps map → we get **LatLng**.
2. **Geocoding** (reverse) → formatted_address, **place_id**, locality, types.
3. If we have place_id → **Place Details** → name, rating, opening_hours, photo, website, phone, types.
4. We merge into **MapLocation** and show it in the **location detail bottom sheet** (with all categories/types).
