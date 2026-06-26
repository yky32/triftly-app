part of 'cloud_sync_bloc.dart';

sealed class CloudSyncEvent extends Equatable {
  const CloudSyncEvent();

  @override
  List<Object?> get props => [];
}

/// Pull or full sync started (from repository layer).
final class CloudSyncStarted extends CloudSyncEvent {
  const CloudSyncStarted();
}

/// Pull or full sync completed successfully.
final class CloudSyncSucceeded extends CloudSyncEvent {
  const CloudSyncSucceeded();
}

/// Pull or full sync failed.
final class CloudSyncFailed extends CloudSyncEvent {
  const CloudSyncFailed(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}

/// Local save succeeded but cloud push failed.
final class CloudSyncPushFailed extends CloudSyncEvent {
  const CloudSyncPushFailed(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}

final class CloudSyncErrorCleared extends CloudSyncEvent {
  const CloudSyncErrorCleared();
}

/// User tapped Retry — bloc orchestrates cloud pull.
final class CloudSyncRetryRequested extends CloudSyncEvent {
  const CloudSyncRetryRequested({this.onComplete});

  final void Function()? onComplete;

  @override
  List<Object?> get props => [onComplete];
}
