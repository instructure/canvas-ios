//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import MobileCoreServices
import UIKit
import WebKit
import UniformTypeIdentifiers

public protocol RichContentEditorDelegate: AnyObject {
    func rce(_ editor: RichContentEditorViewController, canSubmit: Bool)
    func rce(_ editor: RichContentEditorViewController, didError error: Error)
}

public class RichContentEditorViewController: UIViewController {
    let toolbar = RichContentToolbarView()
    public var webView = CoreWebView(frame: .zero)

    let batchID = UUID.string
    public weak var delegate: RichContentEditorDelegate?
    var env = AppEnvironment.shared
    public var placeholder: String = "" {
        didSet {
            webView.evaluateJavaScript("content.setAttribute('placeholder', \(CoreWebView.jsString(placeholder)))")
        }
    }
    public var a11yLabel: String = "" {
        didSet {
            webView.evaluateJavaScript("content.setAttribute('aria-label', \(CoreWebView.jsString(a11yLabel)))")
        }
    }

    var selection: CGRect = .zero
    public var context = Context.currentUser
    public var uploadContext = FileUploadContext.myFiles
    let uploadManager = UploadManager.shared

    lazy var files = uploadManager.subscribe(batchID: batchID) { [weak self] in
        self?.updateUploadProgress()
    }

    lazy var featureFlags = env.subscribe(GetEnabledFeatureFlags(context: context)) {}
    /// The base url to be used for API access during file upload.
    public var fileUploadBaseURL: URL?

    public static func create(context: Context, uploadTo uploadContext: FileUploadContext) -> RichContentEditorViewController {
        let controller = RichContentEditorViewController()
        controller.context = context
        controller.uploadContext = uploadContext
        return controller
    }

    public override func loadView() {
        view = webView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupScriptMessaging()
        toolbar.controller = self
        webView.isOpaque = false
        webView.contentInputAccessoryView = toolbar
        webView.scrollView.keyboardDismissMode = .interactive
        webView.accessibilityIdentifier = "RichContentEditor.webView"

        featureFlags.refresh { [weak self] _ in
            self?.loadHTML()
        }
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }
        getHTML { [weak self] htmlString in
            self?.html = htmlString
            if self?.traitCollection.userInterfaceStyle != .dark {
                self?.webView.updateHtmlContentView()
            }
        }
    }

    public func showError(_ error: Error) {
        delegate?.rce(self, didError: error)
    }

    func loadHTML() {
        webView.loadHTMLString("""
            <style>
            :root {
                --brand-linkColor: \(Brand.shared.linkColor.hexString);
                --brand-primary: \(Brand.shared.primary.hexString);
                --color-backgroundDanger: \(UIColor.backgroundDanger.hexString);
                --color-backgroundDarkest: \(UIColor.backgroundDarkest.hexString);
                --color-backgroundLightest: \(UIColor.backgroundLightest.hexString);
                --color-textDark: \(UIColor.textDark.hexString);
                --color-textDarkest: \(UIColor.textDarkest.hexString);

                font-size: \(Typography.Style.body.uiFont.pointSize)px;
                font-family: \(AppEnvironment.shared.k5.isK5Enabled ? "BalsamiqSans-Regular" : "Lato-Regular");
            }
            </style>
            <div id="content" contenteditable=\"true\" placeholder=\"\(placeholder)\" aria-label=\"\(a11yLabel)\"></div>
        """)
    }

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

    private var html: String?
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
        updateScroll(state)
        toolbar.updateState(state)
        let isEmpty = state?["isEmpty"] as? Bool ?? true
        let isUploading = state?["isUploading"] as? Bool ?? false
        delegate?.rce(self, canSubmit: !isEmpty && !isUploading)
    }

    func setFeatureFlags() {
        let flags = featureFlags.map { $0.name }
        if let data = try? JSONSerialization.data(withJSONObject: flags),
            let flags = String(data: data, encoding: .utf8) {
            webView.evaluateJavaScript("editor.featureFlags = \(flags)")
        }
    }

    func updateScroll(_ state: [String: Any?]?) {
        guard
            let r = state?["selection"] as? [String: CGFloat],
            let x = r["x"], let y = r["y"], let width = r["width"], let height = r["height"]
        else { return }
        var rect = CGRect(x: x, y: y, width: width, height: height)
        guard rect != selection else { return }
        selection = rect
        var scrollView = webView.scrollView
        if webView.autoresizesHeight {
            var view: UIView = webView
            while let parent = view.superview {
                rect = rect.offsetBy(dx: view.frame.minX, dy: view.frame.minY)
                view = parent
                guard let scroll = parent as? UIScrollView, scroll.isScrollEnabled else { continue }
                scrollView = scroll
                break
            }
        }
        if rect.maxY - scrollView.frame.height > scrollView.contentOffset.y {
            let y = rect.maxY - scrollView.frame.height
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: y), animated: true)
        } else if rect.minY < scrollView.contentOffset.y {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: rect.minY), animated: true)
        }
    }

    func editLink(href: String?, text: String?) {
        backupRange()
        let alert = UIAlertController(title: NSLocalizedString("Link to Website URL", bundle: .core, comment: ""), message: nil, preferredStyle: .alert)
        alert.addTextField { (field: UITextField) in
            field.placeholder = NSLocalizedString("Text", bundle: .core, comment: "")
            field.text = text
        }
        alert.addTextField { (field: UITextField) in
            field.placeholder = NSLocalizedString("URL", bundle: .core, comment: "")
            field.text = href
            field.keyboardType = .URL
        }
        alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        alert.addAction(AlertAction(NSLocalizedString("OK", bundle: .core, comment: ""), style: .default) { [weak self] _ in
            let text = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            var href = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !href.isEmpty, URLComponents.parse(href).scheme == nil {
                href = "https://\(href)"
            }
            self?.updateLink(href: href, text: text)
        })
        env.router.show(alert, from: self, options: .modal())
    }
}

extension RichContentEditorViewController {
    enum Message: String, CaseIterable {
        case link, ready, state, retryUpload
    }

    func setupScriptMessaging() {
        for message in Message.allCases {
            webView.handle(message.rawValue, handler: handleScriptMessage)
        }
        if let url = Bundle.core.url(forResource: "RichContentEditor", withExtension: "js"), let source = try? String(contentsOf: url, encoding: .utf8) {
            webView.addScript(source)
        }
        if let url = Bundle.core.url(forResource: "RichContentEditor", withExtension: "css"), let css = try? String(contentsOf: url, encoding: .utf8) {
            let source = """
            var style = document.createElement('style');
            style.textContent = \(CoreWebView.jsString(css));
            document.head.appendChild(style);
            """
            webView.addScript(source)
        }
    }

    func handleScriptMessage(_ message: WKScriptMessage) {
        guard let name = Message(rawValue: message.name) else { return }
        switch name {
        case .link:
            toolbar.linkAction()
        case .ready:
            setFeatureFlags()
            if let html = html { setHTML(html) }
            updateState(nil)
        case .state:
            updateState(message.body as? [String: Any?])
        case .retryUpload:
            guard let url = (message.body as? String).flatMap({ URL(string: $0) }) else { return }
            retry(url)
        }
    }
}

extension RichContentEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func insertFrom(_ sourceType: UIImagePickerController.SourceType) {
        backupRange()
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.imageExportPreset = .compatible
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(sourceType) ? sourceType : .photoLibrary
        picker.mediaTypes = [ UTType.image.identifier, UTType.movie.identifier ]
        env.router.show(picker, from: self, options: .modal())
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            self.files.refresh() // Actualize lazy local store
            do {
                if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                    self.createFile(try image.write(), isRetry: false, then: self.uploadImage)
                } else if let url = info[.mediaURL] as? URL {
                    self.createFile(url, isRetry: false, then: self.uploadMedia)
                } else {
                    throw NSError.instructureError(NSLocalizedString("No image found from image picker", bundle: .core, comment: ""))
                }
            } catch {
                self.showError(error)
            }
        }
    }

    func retry(_ url: URL) {
        if ["png", "jpeg", "jpg"].contains(url.pathExtension) {
            createFile(url, isRetry: true, then: uploadImage)
        } else {
            createFile(url, isRetry: true, then: uploadMedia)
        }
    }

    func createFile(_ url: URL, isRetry: Bool, then: @escaping (URL, File, Bool) -> Void) {
        let context = uploadManager.viewContext
        context.performAndWait {
            do {
                let url = try self.uploadManager.copyFileToSharedContainer(url)
                let file: File = context.insert()
                file.filename = url.lastPathComponent
                file.batchID = self.batchID
                file.localFileURL = url
                file.size = url.lookupFileSize()
                if let session = env.currentSession {
                    file.setUser(session: session)
                }
                try context.save()
                then(url, file, isRetry)
            } catch {
                self.showError(error)
            }
        }
    }

    func uploadImage(_ url: URL, file: File, isRetry: Bool) {
        do {
            if !isRetry {
                let string = CoreWebView.jsString(url.absoluteString)
                let base64 = try Data(contentsOf: url).base64EncodedString()
                let datauri = CoreWebView.jsString("data:image/png;base64,\(base64)")
                webView.evaluateJavaScript("editor.insertImagePlaceholder(\(string), \(datauri))")
            }
            uploadManager.upload(file: file, to: uploadContext, baseURL: fileUploadBaseURL)
        } catch {
            updateFile(file, error: error)
        }
    }

    func uploadMedia(_ url: URL, file: File, isRetry: Bool) {
        if !isRetry {
            let string = CoreWebView.jsString(url.absoluteString)
            webView.evaluateJavaScript("editor.insertVideoPlaceholder(\(string))")
        }
        UploadMedia(type: .video, url: url, file: file, context: context).fetch { [weak self] mediaID, error in
            self?.updateFile(file, error: error, mediaID: mediaID)
        }
    }

    func updateFile(_ file: File, error: Error?, mediaID: String? = nil) {
        let context = uploadManager.viewContext
        context.performAndWait { [weak self] in
            do {
                guard let file = try? context.existingObject(with: file.objectID) as? File else { return }
                file.uploadError = error?.localizedDescription ?? file.uploadError
                file.mediaEntryID = mediaID
                try context.save()
            } catch {
                self?.showError(error)
            }
        }
    }

    func updateUploadProgress() {
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

        let completes = files.filter { $0.mediaEntryID != nil || $0.url != nil || $0.uploadError != nil }
        guard !completes.isEmpty else { return }
        let context = uploadManager.viewContext
        context.performAndWait {
            context.delete(completes)
            try? context.save()
        }
    }
}
