import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/utils/shared_map_parser.dart';

void main() {
  group('SharedMapParser', () {
    test('parses Google Maps place URL with name and coordinates', () {
      const url =
          'https://www.google.com/maps/place/%E7%9B%88%E5%8C%AF%E5%9D%8A/@22.441,114.071,17z';
      final place = SharedMapParser.parse(url)!;

      expect(place.name, '盈匯坊');
      expect(place.latitude, closeTo(22.441, 0.001));
      expect(place.longitude, closeTo(114.071, 0.001));
      expect(place.addressLine, contains('google.com/maps'));
    });

    test('parses share text with title line and URL', () {
      const text = '盈匯坊 · 錦田\nhttps://maps.google.com/?q=22.44,114.07';
      final place = SharedMapParser.parse(text)!;

      expect(place.name, '盈匯坊');
      expect(place.addressLine, contains('maps.google.com'));
    });

    test('falls back to raw text when unrecognized', () {
      const text = 'Meet at the hotel lobby';
      final place = SharedMapParser.parse(text)!;

      expect(place.name, isNull);
      expect(place.addressLine, text);
    });
  });
}
