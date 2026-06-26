import 'package:flutter/foundation.dart';

import '../environment.dart';

/// Observable cloud sync state for pilot UI (last success, errors, in-flight).
class CloudSyncStatus extends ChangeNotifier {
  bool isSyncing = false;
  DateTime? lastSuccessAt;
  String? lastError;

  bool get isConfigured => Environment.hasSupabase;

  bool get hasError => lastError != null;

  void begin() {
    isSyncing = true;
    notifyListeners();
  }

  void succeed() {
    isSyncing = false;
    lastSuccessAt = DateTime.now();
    lastError = null;
    notifyListeners();
  }

  void fail(Object error) {
    isSyncing = false;
    lastError = _message(error);
    notifyListeners();
  }

  /// Local save succeeded but cloud push failed — keep last pull success time.
  void recordPushFailure(Object error) {
    lastError = _message(error);
    notifyListeners();
  }

  void clearError() {
    lastError = null;
    notifyListeners();
  }

  String get lastSuccessLabel {
    final at = lastSuccessAt;
    if (at == null) return 'Not synced yet';
    final diff = DateTime.now().difference(at);
    if (diff.inSeconds < 45) return 'Synced just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return 'Synced $m ${m == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return 'Synced $h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    return 'Synced on ${_shortDate(at)}';
  }

  static String _shortDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _message(Object error) {
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) return raw.substring(11);
    return raw;
  }
}
