#import <Foundation/Foundation.h>

/// Call from Swift to provide the Google Maps API key (avoids "No such module 'GoogleMaps'" in Swift).
void ProvideGoogleMapsAPIKey(const char * _Nullable apiKey);
