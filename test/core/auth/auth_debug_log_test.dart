import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/auth/auth_debug_log.dart';

void main() {
  test('authLogFilter is easy to grep in console', () {
    expect(authLogFilter, '🔐 AUTH');
  });

  test('AuthLogKind glyphs are distinct', () {
    final glyphs = AuthLogKind.values.map((k) => k.glyph).toSet();
    expect(glyphs.length, AuthLogKind.values.length);
  });
}
