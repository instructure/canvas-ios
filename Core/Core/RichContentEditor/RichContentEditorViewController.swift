//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import MobileCoreServices
import UIKit
import WebKit

public protocol RichContentEditorDelegate: class {
    func rce(_ editor: RichContentEditorViewController, canSubmit: Bool)
    func rce(_ editor: RichContentEditorViewController, didError error: Error)
}

public class RichContentEditorViewController: UIViewController {
    public weak var delegate: RichContentEditorDelegate?
    public var fileUploadContext: FileUploadContext?
    var presenter: RichContentEditorPresenter?
    private var html: String?
    lazy var toolbar = RichContentToolbarView()
    public lazy var webView = CoreWebView(frame: .zero)

    public static func create(env: AppEnvironment = .shared, uploadTo context: FileUploadContext?) -> RichContentEditorViewController {
        let controller = RichContentEditorViewController()
        if let context = context {
            controller.presenter = RichContentEditorPresenter(env: env, view: controller, uploadTo: context)
        }
        controller.fileUploadContext = context
        return controller
    }

    public var placeholder: String = "" {
        didSet {
            webView.evaluateJavaScript("content.setAttribute('placeholder', \(CoreWebView.jsString(placeholder)))")
        }
    }

    public override func loadView() {
        view = webView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupScriptMessaging()
        toolbar.controller = self
        webView.contentInputAccessoryView = toolbar
        webView.scrollView.keyboardDismissMode = .interactive
        webView.loadHTMLString("""
            <style>
            :root {
                --background-danger: \(UIColor.named(.backgroundDanger).hexString);
                --background-darkest: \(UIColor.named(.backgroundDarkest).hexString);
                --brand-link-color: \(Brand.shared.linkColor.ensureContrast(against: .white).hexString);
                --brand-primary: \(Brand.shared.primary.ensureContrast(against: .white).hexString);
                --text-dark: \(UIColor.named(.textDark).hexString);
            }
            </style>
            <div id="content" contenteditable=\"true\" placeholder=\"\(placeholder)\">\(html ?? "")</div>
        """)
    }
}

extension RichContentEditorViewController {
    func undo() {
        webView.evaluateJavaScript("editor.execCommand('undo')")
    }
    func redo() {
        webView.evaluateJavaScript("editor.execCommand('redo')")
    }
    func toggleBold() {
        webView.evaluateJavaScript("editor.execCommand('bold')")
    }
    func toggleItalic() {
        webView.evaluateJavaScript("editor.execCommand('italic')")
    }
    func setTextColor(_ color: UIColor) {
        webView.evaluateJavaScript("editor.execCommand('foreColor', '\(color.hexString)')")
    }
    func toggleUnordered() {
        webView.evaluateJavaScript("editor.execCommand('insertUnorderedList')")
    }
    func toggleOrdered() {
        webView.evaluateJavaScript("editor.execCommand('insertOrderedList')")
    }
    func updateLink(href: String, text: String) {
        webView.evaluateJavaScript("editor.updateLink(\(CoreWebView.jsString(href)), \(CoreWebView.jsString(text)))")
    }
    func updateImage(src: String, alt: String) {
        webView.evaluateJavaScript("editor.updateImage(\(CoreWebView.jsString(src)), \(CoreWebView.jsString(alt)))")
    }

    func backupRange() {
        webView.evaluateJavaScript("editor.backupRange()")
    }

    public func focus() {
        webView.evaluateJavaScript("editor.focus()")
    }

    public func setHTML(_ html: String) {
        self.html = html // Save to try again when editor is ready
        webView.evaluateJavaScript("editor.setHTML(\(CoreWebView.jsString(html)))")
    }

    public func getHTML(_ callback: @escaping (String) -> Void) {
        webView.evaluateJavaScript("editor.getHTML()") { (value, _) in
            callback(value as? String ?? "")
        }
    }

    func updateState(_ state: [String: Any?]?) {
        toolbar.updateState(state)
        let isEmpty = state?["isEmpty"] as? Bool ?? true
        let isUploading = !(presenter?.files.isEmpty ?? true)
        delegate?.rce(self, canSubmit: !isEmpty && !isUploading)
    }
}

extension RichContentEditorViewController {
    /// This works around a memory leak caused by the WKUserContentController keeping a strong reference to
    /// message handlers. This has a weak reference back to the controller, breaking the cycle.
    private class MessagePasser: NSObject, WKScriptMessageHandler {
        weak var parent: RichContentEditorViewController?

        init(parent: RichContentEditorViewController) {
            self.parent = parent
            super.init()
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            parent?.handleScriptMessage(message)
        }
    }

    enum Message: String, CaseIterable {
        case link, ready, state, retryUpload
    }

    func setupScriptMessaging() {
        let messenger = MessagePasser(parent: self)
        for message in Message.allCases {
            webView.configuration.userContentController.add(messenger, name: message.rawValue)
        }
        if let url = Bundle.core.url(forResource: "RichContentEditor", withExtension: "js"), let source = try? String(contentsOf: url, encoding: .utf8) {
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(script)
        }
        if let url = Bundle.core.url(forResource: "RichContentEditor", withExtension: "css"), let css = try? String(contentsOf: url, encoding: .utf8) {
            let source = """
            var style = document.createElement('style');
            style.textContent = \(CoreWebView.jsString(css));
            document.head.appendChild(style);
            """
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(script)
        }
    }

    func handleScriptMessage(_ message: WKScriptMessage) {
        guard let name = Message(rawValue: message.name) else { return }
        switch name {
        case .link:
            toolbar.linkAction()
        case .ready:
            if let html = html { setHTML(html) }
        case .state:
            updateState(message.body as? [String: Any?])
        case .retryUpload:
            guard let url = (message.body as? String).flatMap({ URL(string: $0) }) else { return }
            presenter?.retry(url)
        }
    }
}

extension RichContentEditorViewController: RichContentEditorViewProtocol {
    func editLink(href: String?, text: String?) {
        backupRange()
        let alert = UIAlertController(title: NSLocalizedString("Link to Website URL", bundle: .core, comment: ""), message: nil, preferredStyle: .alert)
        alert.addTextField { (field: UITextField) in
            field.placeholder = NSLocalizedString("Text", bundle: .core, comment: "")
            field.text = href
        }
        alert.addTextField { (field: UITextField) in
            field.placeholder = NSLocalizedString("URL", bundle: .core, comment: "")
            field.text = text
            field.keyboardType = .URL
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", bundle: .core, comment: ""), style: .default) { [weak self] _ in
            let text = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            var href = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !href.isEmpty, URLComponents.parse(href).scheme == nil {
                href = "https://\(href)"
            }
            self?.updateLink(href: href, text: text)
        })
        present(alert, animated: true)
    }

    func insertFrom(_ sourceType: UIImagePickerController.SourceType) {
        backupRange()
        let picker = UIImagePickerController()
        picker.delegate = presenter
        picker.sourceType = sourceType
        picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        present(picker, animated: true, completion: nil)
    }

    public func insertImagePlaceholder(_ url: URL, placeholder: String) {
        let string = CoreWebView.jsString(url.absoluteString)
        let datauri = CoreWebView.jsString(placeholder)
        webView.evaluateJavaScript("editor.insertImagePlaceholder(\(string), \(datauri))")
    }

    public func insertVideoPlaceholder(_ url: URL) {
        let string = CoreWebView.jsString(url.absoluteString)
        webView.evaluateJavaScript("editor.insertVideoPlaceholder(\(string))")
    }

    public func updateUploadProgress(of files: [File]) {
        let data = try? JSONSerialization.data(withJSONObject: files.map { file -> [String: Any?] in [
            "localFileURL": file.localFileURL?.absoluteString,
            "url": file.url?.absoluteString,
            "mediaEntryID": file.mediaEntryID,
            "uploadError": file.uploadError,
            "uploadErrorTitle": NSLocalizedString("Failed Upload", bundle: .core, comment: ""),
            "bytesSent": file.bytesSent,
            "size": file.size,
        ] })
        let json = data.flatMap({ String(data: $0, encoding: .utf8) }) ?? "[]"
        webView.evaluateJavaScript("editor.updateUploadProgress(\(json))")
    }

    public func showError(_ error: Error) {
        delegate?.rce(self, didError: error)
    }
}
