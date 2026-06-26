import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/bootstrap/flutter_dev_error_filters.dart';

void main() {
  test('isKnownSimulatorKeyboardSyncNoise matches Meta Left hot-restart noise', () {
    final noise = AssertionError(
      'A KeyUpEvent is dispatched, but the state shows that the physical key is not pressed. '
      'Meta Left',
    );

    expect(isKnownSimulatorKeyboardSyncNoise(noise), isTrue);
  });

  test('isKnownSimulatorKeyboardSyncNoise ignores unrelated errors', () {
    expect(isKnownSimulatorKeyboardSyncNoise(StateError('bad state')), isFalse);
    expect(
      isKnownSimulatorKeyboardSyncNoise(Exception('KeyUpEvent only')),
      isFalse,
    );
  });
}
