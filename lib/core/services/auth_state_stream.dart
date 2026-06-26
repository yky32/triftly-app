/// Replays the latest auth user when a new listener subscribes.
///
/// Broadcast streams do not buffer — without this, [SessionBloc] misses the
/// session restored during [AuthRepository.initialize].
Stream<T?> replayAuthState<T>(T? current, Stream<T?> updates) async* {
  yield current;
  yield* updates;
}
