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
    lazy var webView = CoreWebView(frame: .zero)
    public weak var delegate: RichContentEditorDelegate?

    public var placeholder: String = "" {
        didSet {
            webView.evaluateJavaScript("content.setAttribute('placeholder', \(jsString(placeholder)))")
        }
    }

    private var html: String?
    var foreColor: UIColor = UIColor.named(.textDarkest)
    var linkHref: String?
    var linkText: String?
    var imageSrc: String?
    var imageAlt: String?

    lazy var toolbar: UIView = {
        let toolbar = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45))
        toolbar.backgroundColor = UIColor.named(.backgroundLightest)
        toolbar.clipsToBounds = true
        toolbar.contentMode = .top
        let scroll = UIScrollView()
        scroll.layer.borderColor = UIColor.named(.borderMedium).cgColor
        scroll.layer.borderWidth = 1
        toolbar.addSubview(scroll)
        scroll.pin(inside: toolbar, leading: -1, trailing: -1, top: nil, bottom: -1)
        scroll.heightAnchor.constraint(equalToConstant: 46).isActive = true
        let stack = UIStackView(arrangedSubviews: [
            undoButton, redoButton, boldButton, italicButton, colorButton,
            unorderedButton, orderedButton, linkButton, /*imageButton,*/
        ])
        scroll.backgroundColor = UIColor.named(.backgroundLightest)
        scroll.addSubview(stack)
        stack.pin(inside: scroll)
        scroll.tintColor = UIColor.named(.textDarkest)
        toolbar.sizeToFit()
        return toolbar
    }()
    lazy var undoButton = toolbarButton(label: NSLocalizedString("Undo", bundle: .core, comment: ""), icon: .reply, action: #selector(self.undo))
    lazy var redoButton = toolbarButton(label: NSLocalizedString("Redo", bundle: .core, comment: ""), icon: .forward, action: #selector(self.redo))
    lazy var boldButton = toolbarButton(label: NSLocalizedString("Bold", bundle: .core, comment: ""), icon: .bold, action: #selector(self.toggleBold))
    lazy var italicButton = toolbarButton(label: NSLocalizedString("Italic", bundle: .core, comment: ""), icon: .italic, action: #selector(self.toggleItalic))
    lazy var colorButton = toolbarButton(label: NSLocalizedString("Text Color", bundle: .core, comment: ""), icon: .textColor, action: #selector(self.pickColor))
    lazy var unorderedButton = toolbarButton(label: NSLocalizedString("Unordered List", bundle: .core, comment: ""), icon: .bulletList, action: #selector(self.toggleUnordered))
    lazy var orderedButton = toolbarButton(label: NSLocalizedString("Ordered List", bundle: .core, comment: ""), icon: .numberedList, action: #selector(self.toggleOrdered))
    lazy var linkButton = toolbarButton(label: NSLocalizedString("Insert Link", bundle: .core, comment: ""), icon: .link, action: #selector(self.insertLink))
    lazy var imageButton = toolbarButton(label: NSLocalizedString("Insert Image", bundle: .core, comment: ""), icon: .image, action: #selector(self.insertImage))

    func toolbarButton(label: String, icon: UIImage.InstIconName, action: Selector) -> UIButton {
        let button = UIButton()
        button.accessibilityIdentifier = "RichContentEditor.\(action)Button"
        button.accessibilityLabel = label
        button.imageEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.heightAnchor.constraint(equalToConstant: 46).isActive = true
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: action, for: .primaryActionTriggered)
        button.setImage(UIImage.icon(icon, .solid), for: .normal)
        return button
    }

    lazy var colorToolbar: UIView = {
        let scroll = UIScrollView()
        scroll.layer.borderColor = UIColor.named(.borderMedium).cgColor
        scroll.layer.borderWidth = 1
        toolbar.insertSubview(scroll, at: 0)
        scroll.pin(inside: toolbar, leading: -1, trailing: -1, top: nil, bottom: 44)
        scroll.heightAnchor.constraint(equalToConstant: 46).isActive = true
        let colors = [ "#FFFFFF", "#2D3B45", "#8B969E", "#EE0612", "#FC5E13", "#FFC100", "#89C540", "#1482C8", "#65469F" ]
        let stack = UIStackView(arrangedSubviews: colors.map(foreColorButton))
        scroll.backgroundColor = UIColor.named(.backgroundLightest)
        scroll.addSubview(stack)
        stack.pin(inside: scroll)
        return scroll
    }()

    func foreColorButton(color: String) -> UIButton {
        let label = String.localizedStringWithFormat(NSLocalizedString("Set text color to %@", bundle: .core, comment: ""), color)
        let button = toolbarButton(label: label, icon: .empty, action: #selector(self.setColor(_:)))
        button.accessibilityIdentifier = "RichContentEditor.color\(color.dropFirst())Button"
        button.constraints.first(where: { $0.firstAttribute == .width })?.constant = 46
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.tintColor = UIColor(hexString: color)
        if color.lowercased() == UIColor.white.hexString {
            let border = UIView(frame: CGRect(x: 8, y: 8, width: 30, height: 30))
            border.layer.borderColor = UIColor.named(.borderMedium).cgColor
            border.layer.borderWidth = 1
            border.layer.cornerRadius = 15
            border.isUserInteractionEnabled = false
            button.addSubview(border)
        }
        return button
    }

    func updateState(_ state: [String: Any?]?) {
        foreColor = UIColor(hexString: state?["foreColor"] as? String) ?? UIColor.named(.textDarkest)
        linkHref = state?["linkHref"] as? String
        linkText = state?["linkText"] as? String
        imageSrc = state?["imageSrc"] as? String
        imageAlt = state?["imageAlt"] as? String
        let active = Brand.shared.linkColor
        boldButton.tintColor = (state?["bold"] as? Bool) == true ? active : nil
        italicButton.tintColor = (state?["italic"] as? Bool) == true ? active : nil
        unorderedButton.tintColor = (state?["unorderedList"] as? Bool) == true ? active : nil
        orderedButton.tintColor = (state?["orderedList"] as? Bool) == true ? active : nil
        linkButton.tintColor = linkHref != nil ? active : nil
        imageButton.tintColor = imageSrc != nil ? active : nil

        let colorBlock = colorButton.viewWithTag(938) ?? {
            let colorBlock = UIView(frame: CGRect(x: 16.5, y: 28, width: 17, height: 4))
            colorBlock.layer.borderWidth = 1
            colorBlock.isUserInteractionEnabled = false
            colorBlock.tag = 938
            colorButton.addSubview(colorBlock)
            return colorBlock
        }()
        colorBlock.backgroundColor = foreColor
        if foreColor.hexString == UIColor.white.hexString {
            colorBlock.layer.borderColor = UIColor.named(.borderMedium).cgColor
        } else {
            colorBlock.layer.borderColor = foreColor.cgColor
        }

        delegate?.rce(self, didChangeEmpty: state?["isEmpty"] as? Bool != false)
    }

    public override func loadView() {
        view = webView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupScriptMessaging()
        webView.contentInputAccessoryView = toolbar
        updateState(nil)
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
                    width: 100%;
                    height: 100%;
                    -webkit-overflow-scrolling: touch;
                    overflow: auto;
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
    @objc func undo(_ sender: UIButton? = nil) {
        webView.evaluateJavaScript("editor.execCommand('undo')")
    }
    @objc func redo(_ sender: UIButton? = nil) {
        webView.evaluateJavaScript("editor.execCommand('redo')")
    }
    @objc func toggleBold(_ sender: UIButton? = nil) {
        webView.evaluateJavaScript("editor.execCommand('bold')")
    }
    @objc func toggleItalic(_ sender: UIButton? = nil) {
        webView.evaluateJavaScript("editor.execCommand('italic')")
    }
    @objc func setColor(_ sender: UIButton) {
        webView.evaluateJavaScript("editor.setTextColor('\(sender.tintColor.hexString)')")
        hideColorPicker()
    }
    @objc func toggleUnordered(_ sender: UIButton?) {
        webView.evaluateJavaScript("editor.execCommand('insertUnorderedList')")
    }
    @objc func toggleOrdered(_ sender: UIButton?) {
        webView.evaluateJavaScript("editor.execCommand('insertOrderedList')")
    }

    @objc func pickColor(_ sender: UIButton?) {
        webView.evaluateJavaScript("editor.backupRange()")
        if toolbar.frame.height == 90 {
            hideColorPicker()
        } else {
            showColorPicker()
        }
    }

    func showColorPicker() {
        toolbar.constraints.first(where: { $0.firstAttribute == .height })?.constant = 90
        colorToolbar.alpha = 0
        colorToolbar.transform = CGAffineTransform(translationX: 0, y: 46)
        toolbar.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.colorToolbar.alpha = 1
            self.colorToolbar.transform = .identity
            self.toolbar.layoutIfNeeded()
        }
    }

    func hideColorPicker() {
        colorToolbar.alpha = 1
        colorToolbar.transform = .identity
        toolbar.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.colorToolbar.alpha = 0
            self.colorToolbar.transform = CGAffineTransform(translationX: 0, y: 46)
            self.toolbar.layoutIfNeeded()
        }, completion: { _ in
            self.toolbar.constraints.first(where: { $0.firstAttribute == .height })?.constant = 45
        })
    }

    @objc func insertLink(_ sender: UIButton?) {
        webView.evaluateJavaScript("editor.backupRange()")
        let alert = UIAlertController(title: NSLocalizedString("Link to Website URL", bundle: .core, comment: ""), message: nil, preferredStyle: .alert)
        alert.addTextField { (field: UITextField) in
            field.placeholder = NSLocalizedString("Text", bundle: .core, comment: "")
            field.text = self.linkText
        }
        alert.addTextField { (field: UITextField) in
            field.placeholder = NSLocalizedString("URL", bundle: .core, comment: "")
            field.text = self.linkHref
            field.keyboardType = .URL
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", bundle: .core, comment: ""), style: .default) { _ in
            let text = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            var href = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !href.isEmpty, URLComponents.parse(href).scheme == nil {
                href = "http://\(href)"
            }
            self.webView.evaluateJavaScript("editor.updateLink(\(jsString(href)), \(jsString(text)))")
        })
        present(alert, animated: true)
    }

    @objc func insertImage(_ sender: UIButton?) {
        // TODO
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
        case blur, focus, html, linkTap, paste, ready, state
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
        case .ready:
            if webView.isFirstResponder { focus() }
            if let html = html { setHTML(html) }
        case .state:
            updateState(message.body as? [String: Any?])
        default:
            break
        }
    }
}

private func jsString(_ string: String?) -> String {
    guard let string = string else { return "null" }
    let escaped = string
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "'", with: "\\'")
    return "'\(escaped)'"
}
