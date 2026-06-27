import UIKit
import UniformTypeIdentifiers

/// Share Extension: when user taps Share in Google Maps (or any app) and selects Triftly,
/// we receive the shared URL/text and open the main app with triftly://map?url=…
final class ShareViewController: UIViewController {

    private var didFinish = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        // Never leave Maps hanging if loadItem stalls.
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            self?.finishOnce()
        }

        processSharedContent()
    }

    private func processSharedContent() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            finishOnce()
            return
        }

        for item in extensionItems {
            if let text = item.attributedContentText?.string.trimmingCharacters(in: .whitespacesAndNewlines),
               !text.isEmpty {
                openMainApp(with: text)
                return
            }

            if let title = item.attributedTitle?.string.trimmingCharacters(in: .whitespacesAndNewlines),
               !title.isEmpty,
               title.contains("http") || title.contains("maps") {
                openMainApp(with: title)
                return
            }

            guard let attachments = item.attachments else { continue }
            for provider in attachments {
                if loadUrl(from: provider) { return }
                if loadPlainText(from: provider) { return }
            }
        }

        finishOnce()
    }

    private func loadUrl(from provider: NSItemProvider) -> Bool {
        let typeIds = [UTType.url.identifier, "public.url"]
        guard typeIds.contains(where: { provider.hasItemConformingToTypeIdentifier($0) }) else {
            return false
        }

        let typeId = typeIds.first(where: { provider.hasItemConformingToTypeIdentifier($0) })!
        provider.loadItem(forTypeIdentifier: typeId, options: nil) { [weak self] item, _ in
            DispatchQueue.main.async {
                if let url = item as? URL {
                    self?.openMainApp(with: url.absoluteString)
                    return
                }
                if let url = item as? NSURL {
                    self?.openMainApp(with: url.absoluteString ?? "")
                    return
                }
                if let string = item as? String, !string.isEmpty {
                    self?.openMainApp(with: string)
                    return
                }
                self?.finishOnce()
            }
        }
        return true
    }

    private func loadPlainText(from provider: NSItemProvider) -> Bool {
        let typeIds = [UTType.plainText.identifier, UTType.text.identifier, "public.plain-text", "public.text"]
        guard typeIds.contains(where: { provider.hasItemConformingToTypeIdentifier($0) }) else {
            return false
        }

        let typeId = typeIds.first(where: { provider.hasItemConformingToTypeIdentifier($0) })!
        provider.loadItem(forTypeIdentifier: typeId, options: nil) { [weak self] item, _ in
            DispatchQueue.main.async {
                if let string = item as? String, !string.isEmpty {
                    self?.openMainApp(with: string)
                    return
                }
                self?.finishOnce()
            }
        }
        return true
    }

    private func openMainApp(with urlOrText: String) {
        let payload = urlOrText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !payload.isEmpty else {
            finishOnce()
            return
        }

        var components = URLComponents()
        components.scheme = "triftly"
        components.host = "map"
        components.queryItems = [URLQueryItem(name: "url", value: payload)]

        guard let openURL = components.url else {
            finishOnce()
            return
        }

        extensionContext?.open(openURL, completionHandler: { [weak self] _ in
            DispatchQueue.main.async {
                self?.finishOnce()
            }
        })
    }

    private func finishOnce() {
        guard !didFinish else { return }
        didFinish = true
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
