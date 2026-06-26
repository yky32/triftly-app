import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  static var pendingSharedUrl: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    "AIzaSyDN6sSxZP-Xf47aRGGPuABsjyM_f6cC_MU".withCString { ProvideGoogleMapsAPIKey($0) }
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "app/share", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, result in
        if call.method == "getPendingSharedUrl" {
          let url = AppDelegate.pendingSharedUrl
          AppDelegate.pendingSharedUrl = nil
          result(url)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if url.scheme == "triftly", url.host == "map",
       let comp = URLComponents(url: url, resolvingAgainstBaseURL: false),
       let urlParam = comp.queryItems?.first(where: { $0.name == "url" })?.value,
       let decoded = urlParam.removingPercentEncoding {
      AppDelegate.pendingSharedUrl = decoded
    }
    // Forward all URLs (including triftly://login-callback OAuth) to Flutter plugins.
    return super.application(app, open: url, options: options)
  }
}
