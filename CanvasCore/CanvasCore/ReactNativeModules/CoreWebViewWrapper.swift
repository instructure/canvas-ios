//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import WebKit
import Core

public class CoreWebViewWrapper: UIView, RCTAutoInsetsProtocol {
    @objc public let webView = CoreWebView()

    @objc public var onError: RCTDirectEventBlock?
    @objc public var onFinishedLoading: RCTDirectEventBlock?
    @objc public var onHeightChange: RCTDirectEventBlock?
    @objc public var onMessage: RCTDirectEventBlock?
    @objc public var onNavigation: RCTDirectEventBlock?

    @objc public var source: [String: String]? {
        didSet {
            guard oldValue != source else { return }
            if let html = source?["html"] {
                webView.loadHTMLString(html)
            } else if let url = source?["uri"].flatMap({ URL(string: $0) }) {
                webView.load(URLRequest(url: url))
                if url.host == AppEnvironment.shared.currentSession?.baseURL.host {
                    webView.addFeature(.invertColorsInDarkMode)
                }
            } else {
                webView.loadHTMLString("")
            }
        }
    }

    @objc public var automaticallyAdjustContentInsets: Bool = false
    @objc public var contentInset: UIEdgeInsets = .zero {
        didSet { refreshContentInset() }
    }

    @objc public func refreshContentInset() {
        RCTView.autoAdjustInsets(for: self, with: webView.scrollView, updateOffset: false)
    }

    @objc public func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)?) {
        webView.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
    }

    public override func layoutSubviews() {
        if webView.superview == nil { setup() }
        super.layoutSubviews()
        webView.frame = bounds
    }

    func setup() {
        addSubview(webView)
        webView.linkDelegate = self
        webView.navigationDelegate = self
        webView.sizeDelegate = self
        webView.handle("canvas") { [weak self] message in
            self?.onMessage?([ "body": message.body ])
        }
    }
}

extension CoreWebViewWrapper: CoreWebViewSizeDelegate {
    public func coreWebView(_ webView: CoreWebView, didChangeContentHeight height: CGFloat) {
        onHeightChange?([ "height": height ])
    }
}

extension CoreWebViewWrapper: WKNavigationDelegate, CoreWebViewLinkDelegate {
    public var routeLinksFrom: UIViewController { parentViewController! }

    public func handleLink(_ url: URL) -> Bool {
        onNavigation?([ "url": url.absoluteString ])
        return true
    }

    public func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.webView.webView(webView, decidePolicyFor: action, decisionHandler: decisionHandler)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView.webView(webView, didFinish: navigation)
        onFinishedLoading?([:])
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onError?((error as NSError).userInfo)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        onError?((error as NSError).userInfo)
    }
}
