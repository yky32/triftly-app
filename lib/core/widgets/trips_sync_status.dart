import '../bloc/cloud_sync/cloud_sync_bloc.dart';
import '../bloc/session/session_bloc.dart';

/// Trips-tab sync status (center app-bar pill + full labels).
enum TripsSyncKind { idle, syncing, error }

class TripsSyncStatus {
  const TripsSyncStatus._({
    required this.kind,
    required this.label,
    required this.session,
    required this.sync,
    this.errorDetail,
  });

  final TripsSyncKind kind;
  final String label;
  final String? errorDetail;
  final SessionState session;
  final CloudSyncState sync;

  bool get isError => kind == TripsSyncKind.error;

  bool get isSyncing => kind == TripsSyncKind.syncing;

  bool get isGuestMode => !session.isCloudSignedIn;

  /// Elapsed [MM:SS] since [syncedAt] for the compact pill.
  static String justSyncedCenterLabel(DateTime syncedAt, [DateTime? now]) {
    final diff = (now ?? DateTime.now()).difference(syncedAt);
    final mm = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    return 'Just synced $mm:$ss';
  }

  /// Shorter copy for the centered app-bar pill.
  String get centerLabel {
    if (!sync.isConfigured) return 'Guest Mode = Offline';

    if (!session.isCloudSignedIn) return 'Guest Mode = Offline';

    if (sync.hasError) return 'Sync failed';

    if (sync.isSyncing) return 'Syncing…';

    if (sync.lastSuccessAt == null) return 'Not synced';

    final at = sync.lastSuccessAt!;
    if (DateTime.now().difference(at).inSeconds < 45) {
      return justSyncedCenterLabel(at);
    }

    final full = sync.lastSuccessLabel;
    if (full.startsWith('Synced ') && full.endsWith(' ago')) {
      final middle = full.substring(7, full.length - 5);
      final parts = middle.split(' ');
      if (parts.length == 2) {
        final n = parts[0];
        final unit = parts[1];
        if (unit.startsWith('minute')) return '${n}m';
        if (unit.startsWith('hour')) return '${n}h';
      }
      return middle;
    }
    if (full.startsWith('Synced on ')) return full.replaceFirst('Synced on ', '');
    return full;
  }

  /// Builds the status line for the current session + cloud sync state.
  static TripsSyncStatus resolve({
    required SessionState session,
    required CloudSyncState sync,
  }) {
    if (!sync.isConfigured) {
      return TripsSyncStatus._(
        kind: TripsSyncKind.idle,
        label: 'Guest mode — cloud sync unavailable',
        session: session,
        sync: sync,
      );
    }

    if (!session.isCloudSignedIn) {
      return TripsSyncStatus._(
        kind: TripsSyncKind.idle,
        label: 'Guest mode — trips stay offline on this device',
        session: session,
        sync: sync,
      );
    }

    if (sync.hasError) {
      return TripsSyncStatus._(
        kind: TripsSyncKind.error,
        label: 'Could not sync trips',
        errorDetail: sync.lastError,
        session: session,
        sync: sync,
      );
    }

    if (sync.isSyncing) {
      return TripsSyncStatus._(
        kind: TripsSyncKind.syncing,
        label: 'Syncing trips…',
        session: session,
        sync: sync,
      );
    }

    if (sync.lastSuccessAt == null) {
      return TripsSyncStatus._(
        kind: TripsSyncKind.idle,
        label: 'Not synced yet · pull to refresh',
        session: session,
        sync: sync,
      );
    }

    return TripsSyncStatus._(
      kind: TripsSyncKind.idle,
      label: sync.lastSuccessLabel,
      session: session,
      sync: sync,
    );
  }
}
