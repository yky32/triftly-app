import '../models/shared_place.dart';

/// Holds inbound share state between trip picker and Add Spot sheet.
abstract final class SharedPlaceFlow {
  static SharedPlace? _pendingPlace;
  static String? _armedTripId;
  static SharedPlace? _armedPlace;

  static SharedPlace? get pendingPlace => _pendingPlace;

  static void setPending(SharedPlace place) {
    _pendingPlace = place;
  }

  static SharedPlace? consumePending() {
    final place = _pendingPlace;
    _pendingPlace = null;
    return place;
  }

  static void arm({required String tripId, required SharedPlace place}) {
    _armedTripId = tripId;
    _armedPlace = place;
  }

  /// Returns armed place when [tripId] matches; clears arm.
  static SharedPlace? consumeArmedForTrip(String tripId) {
    if (_armedTripId != tripId || _armedPlace == null) return null;
    final place = _armedPlace;
    _armedTripId = null;
    _armedPlace = null;
    return place;
  }

  static void clear() {
    _pendingPlace = null;
    _armedTripId = null;
    _armedPlace = null;
  }
}
