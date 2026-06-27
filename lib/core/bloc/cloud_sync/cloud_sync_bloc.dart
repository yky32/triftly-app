import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../environment.dart';
import '../../repositories/cloud_trip_sync.dart';
import '../../repositories/hive_trip_repository.dart';
import '../session/session_bloc.dart';
import '../../sync/cloud_sync_reporter.dart';

part 'cloud_sync_event.dart';
part 'cloud_sync_state.dart';

/// App-wide cloud sync UI state (Trips banner, Me → Trip sync).
class CloudSyncBloc extends Bloc<CloudSyncEvent, CloudSyncState> {
  CloudSyncBloc({
    required SessionBloc sessionBloc,
    required CloudSyncReporterBridge syncReporter,
    required HiveTripRepository tripRepository,
  })  : _sessionBloc = sessionBloc,
        _tripRepository = tripRepository,
        _syncReporter = syncReporter,
        super(CloudSyncState()) {
    syncReporter.bind(add);
    on<CloudSyncStarted>(_onStarted);
    on<CloudSyncSucceeded>(_onSucceeded);
    on<CloudSyncFailed>(_onFailed);
    on<CloudSyncPushFailed>(_onPushFailed);
    on<CloudSyncErrorCleared>(_onErrorCleared);
    on<CloudSyncSignedOut>(_onSignedOut);
    on<CloudSyncRetryRequested>(_onRetryRequested);
  }

  final SessionBloc _sessionBloc;
  final HiveTripRepository _tripRepository;
  final CloudSyncReporterBridge _syncReporter;

  CloudSyncReporter get reporter => _syncReporter;

  int _activeSyncCount = 0;

  void _onStarted(CloudSyncStarted event, Emitter<CloudSyncState> emit) {
    _activeSyncCount++;
    emit(state.copyWith(isSyncing: true, clearLastError: true));
  }

  void _onSucceeded(CloudSyncSucceeded event, Emitter<CloudSyncState> emit) {
    if (_activeSyncCount > 0) _activeSyncCount--;
    if (_activeSyncCount > 0) return;
    emit(state.copyWith(
      isSyncing: false,
      lastSuccessAt: DateTime.now(),
      clearLastError: true,
    ));
  }

  void _onFailed(CloudSyncFailed event, Emitter<CloudSyncState> emit) {
    _activeSyncCount = 0;
    emit(state.copyWith(
      isSyncing: false,
      lastError: CloudSyncState.messageFrom(event.error),
    ));
  }

  void _onPushFailed(CloudSyncPushFailed event, Emitter<CloudSyncState> emit) {
    emit(state.copyWith(
      lastError: CloudSyncState.messageFrom(event.error),
    ));
  }

  void _onErrorCleared(CloudSyncErrorCleared event, Emitter<CloudSyncState> emit) {
    emit(state.copyWith(clearLastError: true));
  }

  void _onSignedOut(CloudSyncSignedOut event, Emitter<CloudSyncState> emit) {
    _activeSyncCount = 0;
    emit(CloudSyncState(isConfigured: state.isConfigured));
  }

  Future<void> _onRetryRequested(
    CloudSyncRetryRequested event,
    Emitter<CloudSyncState> emit,
  ) async {
    final user = _sessionBloc.state.user;
    if (user == null || !CloudTripSync.isCloudUserId(user.id)) return;

    try {
      await CloudTripSync.syncForUser(
        user,
        _tripRepository,
        syncReporter: _syncReporter,
      );
      event.onComplete?.call();
    } catch (_) {
      // Pull failure recorded via reporter; UI reads [CloudSyncState.lastError].
    }
  }
}
