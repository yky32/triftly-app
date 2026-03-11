#import "GoogleMapsKeyProvider.h"
#import <GoogleMaps/GoogleMaps.h>

void ProvideGoogleMapsAPIKey(const char * _Nullable apiKey) {
  if (apiKey == NULL) return;
  NSString *key = [NSString stringWithUTF8String:apiKey];
  if (key.length == 0) return;
  [GMSServices provideAPIKey:key];
}
