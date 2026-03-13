import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triftly/features/4_map_view/utils/google_maps_share_parser.dart';

/// Receives URLs shared from other apps (e.g. Google Maps Share → Triftly).
/// Call [getPendingSharedLocation] after app start to get a parsed location if the app was opened via share.
class ShareReceiverService {
  ShareReceiverService._();

  static const MethodChannel _channel = MethodChannel('app/share');

  /// Returns a [LatLng] if the app was launched with a shared Google Maps URL (or similar) that we could parse; otherwise null.
  /// Call once after the first frame (e.g. in [WidgetsBinding.instance.addPostFrameCallback]) so the platform has set the intent.
  static Future<LatLng?> getPendingSharedLocation() async {
    try {
      final url = await _channel.invokeMethod('getPendingSharedUrl') as String?;
      if (url == null || url.isEmpty) return null;
      final result = GoogleMapsShareParser.parse(url);
      return result?.position;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
