/// Tracks a pending trip share invite while routing buddies through sign-in or join confirm.
abstract final class ShareInviteFlow {
  static String? _pendingToken;
  static bool _awaitingSignIn = false;

  static String? get pendingToken => _pendingToken;

  static bool get awaitingSignIn => _awaitingSignIn;

  static void beginSignIn(String shareToken) {
    _pendingToken = shareToken;
    _awaitingSignIn = true;
  }

  static String? consumePendingToken() {
    final token = _pendingToken;
    _pendingToken = null;
    _awaitingSignIn = false;
    return token;
  }

  static void clear() {
    _pendingToken = null;
    _awaitingSignIn = false;
  }

  static bool clearAwaitingSignIn() {
    if (!_awaitingSignIn) return false;
    _awaitingSignIn = false;
    return true;
  }
}
