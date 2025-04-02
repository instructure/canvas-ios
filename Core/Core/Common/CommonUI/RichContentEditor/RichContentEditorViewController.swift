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
import Combine

public protocol RichContentEditorDelegate: AnyObject {
    func rce(_ editor: RichContentEditorViewController, canSubmit: Bool)
    func rce(_ editor: RichContentEditorViewController, isUploading: Bool)
    func rce(_ editor: RichContentEditorViewController, didError error: Error)
    func rceDidFocus(_ editor: RichContentEditorViewController)
}

public extension RichContentEditorDelegate {
    func rce(_ editor: RichContentEditorViewController, canSubmit: Bool) {}
    func rce(_ editor: RichContentEditorViewController, isUploading: Bool) {}
    func rceDidFocus(_ editor: RichContentEditorViewController) {}
}

public class RichContentEditorViewController: UIViewController {
    let toolbar = RichContentToolbarView()
    public var webView = CoreWebView(frame: .zero)

    private let batchID = UUID.string
    public weak var delegate: RichContentEditorDelegate?
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
    private var focusObserver: AnyCancellable?

    private var env: AppEnvironment = .defaultValue

    private lazy var files = env.uploadManager.subscribe(batchID: batchID) { [weak self] in
        self?.updateUploadProgress()
    }

    private lazy var featureFlags = env.subscribe(GetEnabledFeatureFlags(context: context)) {}
    /// The base url to be used for API access during file upload.
    public var fileUploadBaseURL: URL?

    public static func create(env: AppEnvironment, context: Context, uploadTo uploadContext: FileUploadContext) -> RichContentEditorViewController {
        let controller = RichContentEditorViewController()
        controller.context = context
        controller.env = env
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

        subscribeForTraitChanges()
    }

    private func showError(_ error: Error) {
        delegate?.rce(self, didError: error)
    }

    private func loadHTML() {
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

    func focus() {
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
        delegate?.rce(self, isUploading: isUploading)
    }

    func subscribeToFocusTrigger(_ trigger: AnyPublisher<Void, Never>) {
        focusObserver?.cancel()
        focusObserver = trigger.sink { [weak self] in
            self?.focus()
        }
    }

    private func didFocus() {
        delegate?.rceDidFocus(self)
    }

    private func setFeatureFlags() {
        let flags = featureFlags.map { $0.name }
        if let data = try? JSONSerialization.data(withJSONObject: flags),
            let flags = String(data: data, encoding: .utf8) {
            webView.evaluateJavaScript("editor.featureFlags = \(flags)")
        }
    }

    private func updateScroll(_ state: [String: Any?]?) {
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
        let alert = UIAlertController(title: String(localized: "Link to Website URL", bundle: .core), message: nil, preferredStyle: .alert)
        alert.addTextField { (field: UITextField) in
            field.placeholder = String(localized: "Text", bundle: .core)
            field.text = text
        }
        alert.addTextField { (field: UITextField) in
            field.placeholder = String(localized: "URL", bundle: .core)
            field.text = href
            field.keyboardType = .URL
        }
        alert.addAction(AlertAction(String(localized: "Cancel", bundle: .core), style: .cancel))
        alert.addAction(AlertAction(String(localized: "OK", bundle: .core), style: .default) { [weak self] _ in
            let text = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            var href = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !href.isEmpty, URLComponents.parse(href).scheme == nil {
                href = "https://\(href)"
            }
            self?.updateLink(href: href, text: text)
        })
        env.router.show(alert, from: self, options: .modal())
    }

    private func subscribeForTraitChanges() {
        let traits = [UITraitUserInterfaceStyle.self]
        registerForTraitChanges(traits) { (controller: RichContentEditorViewController, previousTraitCollection: UITraitCollection) in
            guard previousTraitCollection.userInterfaceStyle != controller.traitCollection.userInterfaceStyle else { return }
            controller.getHTML { [weak self] htmlString in
                self?.html = htmlString
            }
        }
    }
}

extension RichContentEditorViewController {
    private enum Message: String, CaseIterable {
        case link, ready, state, retryUpload, focused
    }

    private func setupScriptMessaging() {
        for message in Message.allCases {
            webView.handle(message.rawValue) { [weak self] message in
                self?.handleScriptMessage(message)
            }
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

    private func handleScriptMessage(_ message: WKScriptMessage) {
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
        case .focused:
            didFocus()
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
                    throw NSError.instructureError(String(localized: "No image found from image picker", bundle: .core))
                }
            } catch {
                self.showError(error)
            }
        }
    }

    private func retry(_ url: URL) {
        if ["png", "jpeg", "jpg"].contains(url.pathExtension) {
            createFile(url, isRetry: true, then: uploadImage)
        } else {
            createFile(url, isRetry: true, then: uploadMedia)
        }
    }

    private func createFile(_ url: URL, isRetry: Bool, then: @escaping (URL, File, Bool) -> Void) {
        let context = env.uploadManager.viewContext
        context.performAndWait {
            do {
                let url = try self.env.uploadManager.copyFileToSharedContainer(url)
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

    private func uploadImage(_ url: URL, file: File, isRetry: Bool) {
        do {
            if !isRetry {
                let string = CoreWebView.jsString(url.absoluteString)
                let base64 = try Data(contentsOf: url).base64EncodedString()
                let datauri = CoreWebView.jsString("data:image/png;base64,\(base64)")
                webView.evaluateJavaScript("editor.insertImagePlaceholder(\(string), \(datauri))")
            }
            env.uploadManager.upload(file: file, to: uploadContext, baseURL: fileUploadBaseURL)
        } catch {
            updateFile(file, error: error)
        }
    }

    private func uploadMedia(_ url: URL, file: File, isRetry: Bool) {
        if !isRetry {
            let string = CoreWebView.jsString(url.absoluteString)
            webView.evaluateJavaScript("editor.insertVideoPlaceholder(\(string))")
        }
        UploadMedia(type: .video, url: url, file: file, context: context).fetch { [weak self] mediaID, error in
            self?.updateFile(file, error: error, mediaID: mediaID)
        }
    }

    private func updateFile(_ file: File, error: Error?, mediaID: String? = nil) {
        let context = env.uploadManager.viewContext
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

    private func updateUploadProgress() {
        let data = try? JSONSerialization.data(withJSONObject: files.map { file -> [String: Any?] in [
            "localFileURL": file.localFileURL?.absoluteString,
            "url": file.url?.absoluteString,
            "mediaEntryID": file.mediaEntryID,
            "uploadError": file.uploadError,
            "uploadErrorTitle": String(localized: "Failed Upload", bundle: .core),
            "bytesSent": file.bytesSent,
            "size": file.size
        ] })
        let json = data.flatMap({ String(data: $0, encoding: .utf8) }) ?? "[]"
        webView.evaluateJavaScript("editor.updateUploadProgress(\(json))")

        let completes = files.filter { $0.mediaEntryID != nil || $0.url != nil || $0.uploadError != nil }
        guard !completes.isEmpty else { return }
        let context = env.uploadManager.viewContext
        context.performAndWait {
            context.delete(completes)
            try? context.save()
        }
    }
}
