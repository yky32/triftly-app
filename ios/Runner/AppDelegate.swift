import AuthenticationServices
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  static var pendingSharedUrl: String?
  static var pendingOAuthCallback: String?

  private var authChannel: FlutterMethodChannel?
  private var shareChannel: FlutterMethodChannel?
  private var oauthSession: ASWebAuthenticationSession?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    "AIzaSyDN6sSxZP-Xf47aRGGPuABsjyM_f6cC_MU".withCString { ProvideGoogleMapsAPIKey($0) }
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      shareChannel = FlutterMethodChannel(name: "app/share", binaryMessenger: controller.binaryMessenger)
      shareChannel?.setMethodCallHandler { call, result in
        if call.method == "getPendingSharedUrl" {
          let url = AppDelegate.pendingSharedUrl
          AppDelegate.pendingSharedUrl = nil
          result(url)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }

      authChannel = FlutterMethodChannel(name: "com.triftly/auth", binaryMessenger: controller.binaryMessenger)
      authChannel?.setMethodCallHandler { [weak self] call, result in
        guard let self = self else {
          result(FlutterError(code: "unavailable", message: "App delegate released", details: nil))
          return
        }

        switch call.method {
        case "getPendingOAuthCallback":
          let pending = AppDelegate.pendingOAuthCallback
          AppDelegate.pendingOAuthCallback = nil
          result(pending)
        case "startOAuthSession":
          self.startOAuthSession(call: call, result: result)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    if let url = launchOptions?[.url] as? URL {
      storeSharedMapUrl(url)
      deliverOAuthCallback(url)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    storeSharedMapUrl(url)
    deliverOAuthCallback(url)

    return super.application(app, open: url, options: options)
  }

	private func storeSharedMapUrl(_ url: URL) {
		guard url.scheme == "triftly", url.host == "map",
			  let comp = URLComponents(url: url, resolvingAgainstBaseURL: false),
			  let payload = comp.queryItems?.first(where: { $0.name == "url" })?.value else { return }

		let decoded = payload.removingPercentEncoding ?? payload
		guard !decoded.isEmpty else { return }

		AppDelegate.pendingSharedUrl = decoded
		shareChannel?.invokeMethod("onSharedUrlReady", arguments: nil)
	}

  private func startOAuthSession(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let urlString = args["url"] as? String,
          let callbackScheme = args["callbackScheme"] as? String,
          let url = URL(string: urlString) else {
      result(FlutterError(code: "invalid_args", message: "Missing OAuth URL or callback scheme", details: nil))
      return
    }

    oauthSession?.cancel()

    let session = ASWebAuthenticationSession(
      url: url,
      callbackURLScheme: callbackScheme
    ) { [weak self] callbackURL, error in
      DispatchQueue.main.async {
        self?.oauthSession = nil

        if let error = error {
          if let authError = error as? ASWebAuthenticationSessionError,
             authError.code == .canceledLogin {
            result(FlutterError(code: "canceled", message: "User canceled Google sign-in", details: nil))
            return
          }
          result(FlutterError(code: "oauth_failed", message: error.localizedDescription, details: nil))
          return
        }

        guard let callbackURL = callbackURL else {
          result(FlutterError(code: "no_callback", message: "No OAuth callback URL", details: nil))
          return
        }

        result(callbackURL.absoluteString)
      }
    }

    if #available(iOS 13.0, *) {
      session.presentationContextProvider = self
    }

    oauthSession = session

    guard session.start() else {
      oauthSession = nil
      result(FlutterError(code: "start_failed", message: "Could not start OAuth session", details: nil))
      return
    }
  }

  private func deliverOAuthCallback(_ url: URL) {
    guard url.scheme == "triftly", url.host == "login-callback" else { return }
    let absolute = url.absoluteString
    AppDelegate.pendingOAuthCallback = absolute
    authChannel?.invokeMethod("onOAuthCallback", arguments: absolute)
  }
}

extension AppDelegate: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    if let window = self.window {
      return window
    }

    return UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow } ?? ASPresentationAnchor()
  }
}
