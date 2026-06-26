import '../bloc/cloud_sync/cloud_sync_bloc.dart';

/// Data-layer callback surface for cloud sync progress (no UI types).
abstract interface class CloudSyncReporter {
  void begin();
  void succeed();
  void fail(Object error);
  void recordPushFailure(Object error);
}

/// Bridges repository sync calls into [CloudSyncBloc] events at bootstrap.
final class CloudSyncReporterBridge implements CloudSyncReporter {
  void Function(CloudSyncEvent)? _dispatch;

  void bind(void Function(CloudSyncEvent) dispatch) {
    _dispatch = dispatch;
  }

  @override
  void begin() => _dispatch?.call(const CloudSyncStarted());

  @override
  void succeed() => _dispatch?.call(const CloudSyncSucceeded());

  @override
  void fail(Object error) => _dispatch?.call(CloudSyncFailed(error));

  @override
  void recordPushFailure(Object error) =>
      _dispatch?.call(CloudSyncPushFailed(error));
}
