import 'Flutter'
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  static var pendingSharedUrl: String?
  static var pendingOAuthCallback: String?

  private var authChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    "AIzaSyDN6sSxZP-Xf47aRGGPuABsjyM_f6cC_MU".withCString { ProvideGoogleMapsAPIKey($0) }
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let shareChannel = FlutterMethodChannel(name: "app/share", binaryMessenger: controller.binaryMessenger)
      shareChannel.setMethodCallHandler { call, result in
        if call.method == "getPendingSharedUrl" {
          let url = AppDelegate.pendingSharedUrl
          AppDelegate.pendingSharedUrl = nil
          result(url)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }

      authChannel = FlutterMethodChannel(name: "com.triftly/auth", binaryMessenger: controller.binaryMessenger)
      authChannel?.setMethodCallHandler { call, result in
        if call.method == "getPendingOAuthCallback" {
          let pending = AppDelegate.pendingOAuthCallback
          AppDelegate.pendingOAuthCallback = nil
          result(pending)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    if let url = launchOptions?[.url] as? URL {
      deliverOAuthCallback(url)
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

    deliverOAuthCallback(url)

    return super.application(app, open: url, options: options)
  }

  private func deliverOAuthCallback(_ url: URL) {
    guard url.scheme == "triftly", url.host == "login-callback" else { return }
    let absolute = url.absoluteString
    AppDelegate.pendingOAuthCallback = absolute
    authChannel?.invokeMethod("onOAuthCallback", arguments: absolute)
  }
}
