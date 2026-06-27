import UIKit
import UniformTypeIdentifiers

/// Share Extension: when user taps Share in Google Maps (or any app) and selects Triftly,
/// we receive the shared URL/text and open the main app with triftly://map?url=...
final class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        processSharedContent()
    }

    private func processSharedContent() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            finish()
            return
        }

        for item in extensionItems {
            guard let attachments = item.attachments else { continue }
            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] url, _ in
                        if let shareURL = (url as? URL) ?? (url as? NSURL) as URL? {
                            self?.openMainApp(with: shareURL.absoluteString)
                        } else {
                            self?.finish()
                        }
                    }
                    return
                }
                if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] text, _ in
                        if let string = text as? String {
                            self?.openMainApp(with: string)
                        } else {
                            self?.finish()
                        }
                    }
                    return
                }
            }
        }
        finish()
    }

    private func openMainApp(with urlOrText: String) {
        let encoded = urlOrText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlOrText
        guard let openURL = URL(string: "triftly://map?url=\(encoded)") else {
            finish()
            return
        }

        extensionContext?.open(openURL, completionHandler: { [weak self] _ in
            self?.finish()
        })
    }

    private func finish() {
        DispatchQueue.main.async { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
}
