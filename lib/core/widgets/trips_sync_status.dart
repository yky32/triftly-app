import '../bloc/cloud_sync/cloud_sync_bloc.dart';
import '../bloc/session/session_bloc.dart';

/// Trips-tab sync row content (below app bar).
enum TripsSyncKind { idle, syncing, error }

class TripsSyncStatus {
  const TripsSyncStatus._({
    required this.kind,
    required this.label,
    this.errorDetail,
  });

  final TripsSyncKind kind;
  final String label;
  final String? errorDetail;

  bool get isError => kind == TripsSyncKind.error;

  bool get isSyncing => kind == TripsSyncKind.syncing;

  /// Builds the status line for the current session + cloud sync state.
  static TripsSyncStatus resolve({
    required SessionState session,
    required CloudSyncState sync,
  }) {
    if (!sync.isConfigured) {
      return const TripsSyncStatus._(
        kind: TripsSyncKind.idle,
        label: 'Local only — cloud sync unavailable',
      );
    }

    if (!session.isCloudSignedIn) {
      return const TripsSyncStatus._(
        kind: TripsSyncKind.idle,
        label: 'Sign in to sync trips across devices',
      );
    }

    if (sync.hasError) {
      return TripsSyncStatus._(
        kind: TripsSyncKind.error,
        label: 'Could not sync trips',
        errorDetail: sync.lastError,
      );
    }

    if (sync.isSyncing) {
      return const TripsSyncStatus._(
        kind: TripsSyncKind.syncing,
        label: 'Syncing trips…',
      );
    }

    if (sync.lastSuccessAt == null) {
      return const TripsSyncStatus._(
        kind: TripsSyncKind.idle,
        label: 'Not synced yet · pull to refresh',
      );
    }

    return TripsSyncStatus._(
      kind: TripsSyncKind.idle,
      label: sync.lastSuccessLabel,
    );
  }
}
