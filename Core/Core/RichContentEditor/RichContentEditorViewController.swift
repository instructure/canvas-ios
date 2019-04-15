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

import WebKit
import UIKit

public protocol RichContentEditorDelegate: class {
    func rce(_ editor: RichContentEditorViewController, didChangeEmpty isEmpty: Bool)
}

public class RichContentEditorViewController: UIViewController {
    public weak var delegate: RichContentEditorDelegate?
    private var html: String?
    lazy var toolbar = RichContentToolbarView()
    public lazy var webView = CoreWebView(frame: .zero)

    public var placeholder: String = "" {
        didSet {
            webView.evaluateJavaScript("content.setAttribute('placeholder', \(jsString(placeholder)))")
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
                html, body {
                    height: 100%;
                    margin: 0;
                    padding: 0;
                }
                * {
                    outline: 0px solid transparent;
                    -webkit-tap-highlight-color: rgba(0,0,0,0);
                    -webkit-touch-callout: none;
                }
                #content {
                    box-sizing: border-box;
                    min-height: 100%;
                    padding: 1em;
                }
                #content:empty:before {
                    content: attr(placeholder);
                    color: \(UIColor.named(.textDark).hexString);
                }
                .editor-active {
                    border: 2px dashed \(UIColor.named(.borderDarkest).hexString);
                }
                .video-preview {
                    background-color: \(UIColor.named(.backgroundDarkest).hexString);
                    height: 111px;
                    width: 192px;
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
        webView.evaluateJavaScript("editor.updateLink(\(jsString(href)), \(jsString(text)))")
    }
    func updateImage(src: String, alt: String) {
        webView.evaluateJavaScript("editor.updateImage(\(jsString(src)), \(jsString(alt)))")
    }

    func backupRange() {
        webView.evaluateJavaScript("editor.backupRange()")
    }

    public func focus() {
        webView.evaluateJavaScript("editor.focus()")
    }

    public func setHTML(_ html: String) {
        self.html = html // Save to try again when editor is ready
        webView.evaluateJavaScript("editor.setHTML(\(jsString(html)))")
    }

    public func getHTML(_ callback: @escaping (String) -> Void) {
        webView.evaluateJavaScript("editor.getHTML()") { (value, _) in
            callback(value as? String ?? "")
        }
    }

    func updateState(_ state: [String: Any?]?) {
        toolbar.updateState(state)
        delegate?.rce(self, didChangeEmpty: state?["isEmpty"] as? Bool != false)
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
        case link, ready, state
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
        }
    }
}

private func jsString(_ string: String?) -> String {
    guard let string = string else { return "null" }
    let escaped = string
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "'", with: "\\'")
        .replacingOccurrences(of: "\r", with: "\\r")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "\u{2028}", with: "\\u2028")
        .replacingOccurrences(of: "\u{2029}", with: "\\u2029")
    return "'\(escaped)'"
}
