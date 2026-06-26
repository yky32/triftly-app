part of 'cloud_sync_bloc.dart';

class CloudSyncState extends Equatable {
  CloudSyncState({
    bool? isConfigured,
    this.isSyncing = false,
    this.lastSuccessAt,
    this.lastError,
  }) : isConfigured = isConfigured ?? Environment.hasSupabase;

  final bool isConfigured;
  final bool isSyncing;
  final DateTime? lastSuccessAt;
  final String? lastError;

  bool get hasError => lastError != null;

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

  CloudSyncState copyWith({
    bool? isConfigured,
    bool? isSyncing,
    DateTime? lastSuccessAt,
    String? lastError,
    bool clearLastError = false,
  }) =>
      CloudSyncState(
        isConfigured: isConfigured ?? this.isConfigured,
        isSyncing: isSyncing ?? this.isSyncing,
        lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
        lastError: clearLastError ? null : (lastError ?? this.lastError),
      );

  static String messageFrom(Object error) {
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) return raw.substring(11);
    return raw;
  }

  static String _shortDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [isConfigured, isSyncing, lastSuccessAt, lastError];
}
