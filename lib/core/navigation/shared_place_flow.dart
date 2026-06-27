import '../models/shared_place.dart';

/// Holds inbound share state between trip picker and Add Spot sheet.
abstract final class SharedPlaceFlow {
  static const _dedupeWindow = Duration(seconds: 10);

  static SharedPlace? _pendingPlace;
  static String? _armedTripId;
  static SharedPlace? _armedPlace;
  static String? _activeRaw;
  static String? _lastHandledRaw;
  static DateTime? _lastHandledAt;

  static SharedPlace? get pendingPlace => _pendingPlace;

  /// True while presenting picker / opening Add Spot for [raw], or shortly after success.
  static bool shouldSuppress(String raw) {
    if (_activeRaw == raw) return true;
    return _lastHandledRaw == raw &&
        _lastHandledAt != null &&
        DateTime.now().difference(_lastHandledAt!) < _dedupeWindow;
  }

  static void beginHandling(String raw) => _activeRaw = raw;

  static void clearActive() => _activeRaw = null;

  static void markHandled(String raw) {
    _lastHandledRaw = raw;
    _lastHandledAt = DateTime.now();
    _activeRaw = null;
  }

  /// Queues [place] unless it should be suppressed as a duplicate.
  static void stage(SharedPlace place) {
    if (shouldSuppress(place.raw)) return;
    _pendingPlace = place;
  }

  static void setPending(SharedPlace place) => stage(place);

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
    _activeRaw = null;
  }
}
