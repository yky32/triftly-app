import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/navigation/share_invite_flow.dart';

void main() {
  tearDown(ShareInviteFlow.clear);

  test('beginSignIn stores token and awaiting flag', () {
    ShareInviteFlow.beginSignIn('abc123');
    expect(ShareInviteFlow.pendingToken, 'abc123');
    expect(ShareInviteFlow.awaitingSignIn, isTrue);
  });

  test('clearAwaitingSignIn keeps token for post-auth resume', () {
    ShareInviteFlow.beginSignIn('abc123');
    expect(ShareInviteFlow.clearAwaitingSignIn(), isTrue);
    expect(ShareInviteFlow.pendingToken, 'abc123');
    expect(ShareInviteFlow.awaitingSignIn, isFalse);
  });

  test('consumePendingToken clears everything', () {
    ShareInviteFlow.beginSignIn('abc123');
    expect(ShareInviteFlow.consumePendingToken(), 'abc123');
    expect(ShareInviteFlow.pendingToken, isNull);
    expect(ShareInviteFlow.awaitingSignIn, isFalse);
  });
}
