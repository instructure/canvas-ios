//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import ReactiveSwift
import Core

public class CanvasWebView: WKWebView {
    
    public enum Navigation {
        case `internal`
        case external((URL) -> Void)
    }
    
    public enum Source {
        case error(String)
        case html(title: String?, body: String, baseURL: URL?)
        case url(URL)
    }
    
    fileprivate class MessageHandler: NSObject, WKScriptMessageHandler {
        @objc weak var webView: CanvasWebView?
        enum Name: String, CaseIterable {
            case dismiss
            case canvas
            case height
            case loadFrameSource
        }

        @objc init(webView: CanvasWebView) {
            self.webView = webView
            super.init()
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let name = MessageHandler.Name(rawValue: message.name) else {
                return
            }
            switch name {
            case .dismiss:
                webView?.requestClose?()
            case .canvas:
                webView?.onMessage?(["body": message.body])
            case .height:
                guard let height = message.body as? [String: Any] else { return }
                webView?.onHeightChange?(height)
            case .loadFrameSource:
                guard let src = message.body as? String else {
                    return
                }
                webView?.loadFrame(src: src)
            }
        }
    }

    fileprivate var source: Source?
    public var navigation = Navigation.internal

    @objc
    public var finishedLoading: (() -> Void)?
    
    @objc
    public var onMessage: (([String: Any]) -> Void)?
    
    @objc
    public var onHeightChange: (([String: Any]) -> Void)?

    @objc
    public var onRefresh: (() -> Void)? {
        didSet {
            if onRefresh != nil {
                let refreshControl = CircleRefreshControl()
                refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
                self.refreshControl = refreshControl
                scrollView.addSubview(refreshControl)
            }
        }
    }
    
    @objc
    public var onError: ((Error) -> Void)?

    @objc var requestClose: (() -> Void)?
    
    @objc
    public weak var presentingViewController: UIViewController?

    fileprivate var externalToolLaunchDisposable: Disposable?

    fileprivate var refreshControl: CircleRefreshControl?

    @objc
    public func setNavigationHandler(routeToURL: @escaping (URL) -> Void) {
        navigation = .external(routeToURL)
    }
    
    @objc
    public func load(html: String, title: String?, baseURL: URL?, routeToURL: @escaping (URL) -> Void) {
        navigation = .external(routeToURL)
        load(source: .html(title: title, body: html, baseURL: baseURL))
    }
    
    public func load(source: Source) {
        self.source = source
        switch source {
        case let .error(description):
            // 🤔 I wonder if I can put emoji in a localized string?
            let title = NSLocalizedString("⚠️ Error Loading Content", comment: "web content failed to load")
            let fromTemplate = htmlString(
                title: title,
                body: "<p>\(description)</p>"
            )
            loadHTMLString(fromTemplate, baseURL: nil)
        case let .html(title, body, baseURL):
            let fromTemplate = htmlString(
                title: title,
                body: body
            )
            loadHTMLString(fromTemplate, baseURL: baseURL)
        case let .url(url):
            if url.isFileURL {
                loadFileURL(url, allowingReadAccessTo: url)
                return
            }
            load(URLRequest(url: url))
        }
    }
    
    @objc public init(config: WKWebViewConfiguration) {
        config.processPool = CoreWebView.processPool
        super.init(frame: .zero, configuration: config)
        customUserAgent = UserAgent.safari.description
        translatesAutoresizingMaskIntoConstraints = false
        navigationDelegate = self
        uiDelegate = self
    }
    
    public convenience init() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        self.init(config: config)

        for message in MessageHandler.Name.allCases {
            config.userContentController.add(MessageHandler(webView: self), name: message.rawValue)
        }

        if let jsPath = Bundle.core.url(forResource: "CanvasWebView", withExtension: "js"),
            var js = try? String(contentsOf: jsPath, encoding: .utf8) {
            js = js.replacingOccurrences(of: "{$LTI_LAUNCH_TEXT$}", with: NSLocalizedString("Launch External Tool", bundle: .core, comment: ""))
            let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            config.userContentController.addUserScript(script)
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    fileprivate func isSamePage(_ url: URL) -> Bool {
        guard let origin = self.url else { return false }
        let base = origin.absoluteString.split(separator: "#").first
        let to = url.absoluteString.split(separator: "#").first
        return base == to
    }
    
    fileprivate func scroll(to url: URL, elseDo failBlock: @escaping () -> Void) {
        guard let f = url.fragment, isSamePage(url) else {
            failBlock()
            return
        }
        
        let scroll = "(function () { let e = document.querySelector('a[name=\"\(f)\"],#\(f)'); if (e) { e.scrollIntoView(); return true; } else { return false } })()"
        evaluateJavaScript(scroll) { result, error in
            let success = ((result as? NSNumber)?.boolValue == true)
                || (result as? String == "true")
            if !success {
                failBlock()
            }
        }
    }
    
    @objc public func htmlContentHeight(completionHandler: @escaping (CGFloat) -> Void) {
        evaluateJavaScript("document.documentElement.scrollHeight") { result, error in
            completionHandler(result as? CGFloat ?? 0.0)
        }
    }

    fileprivate func handle(error: Error) {
        stopRefreshing()
        (error as NSError).userInfo.forEach { key, value in print("\(key) => \(value)") }
        
        let e = error as NSError
        let failingURL = e.userInfo[NSURLErrorFailingURLErrorKey] as? URL ??
            (e.userInfo[NSURLErrorFailingURLStringErrorKey] as? String).flatMap(URL.init)
        
        if let url = failingURL {
            if let scheme = url.scheme, ["https", "http"].contains(scheme) {
                return
            }
            UIApplication.shared.open(url) { success in
                if success {
                    self.requestClose?()
                } else {
                    self.onError?(error)
                }
            }
        } else {
            self.onError?(error)
        }
    }

    @objc
    fileprivate func handleRefresh(_ control: CircleRefreshControl) {
        onRefresh?()
    }

    /// Reloads `self` with an authenticated url for `src`
    @objc func loadFrame(src: String) {
        let url = URL(string: src)
        let request = GetWebSessionRequest(to: url)
        AppEnvironment.shared.api.makeRequest(request) { [weak self] response, urlResponse, error in
            DispatchQueue.main.async {
                guard let response = response else {
                    self?.onError?(error ?? NSError.internalError())
                    return
                }
                self?.load(URLRequest(url: response.session_url))
            }
        }
    }
}

extension CanvasWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let request = action.request
        
        if let url = request.url, url.absoluteString.contains("google-drive-lti") {
            customUserAgent = UserAgent.safari.description
        }

        if action.navigationType == .linkActivated, let url = request.url, LTITools(link: url) != nil,
            let from = presentingViewController, let session = Session.current {
            ExternalToolManager.shared.launch(url, in: session, from: from)
            return decisionHandler(.cancel)
        }

        // FIXME: Workaround for Harvard's video player
        if let url = request.url, url.absoluteString.contains("harvard.edu/engage/player/watch.html") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return decisionHandler(.cancel)
        }
        
        switch action.navigationType {
        case .other,
             .reload,
             .formSubmitted,
             .formResubmitted:
            return decisionHandler(.allow)
        default: break
        }

        switch navigation {
        case .internal:
            return decisionHandler(.allow)

        case .external(let handler):
            guard let url = request.url else {
                return decisionHandler(.allow)
            }
            
            // let's see if it's an #fragment first
            scroll(to: url, elseDo: {
                if url.scheme != "http" && url.scheme != "https" && UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    handler(url)
                }
            })

            return decisionHandler(.cancel)
        }
    }

    @objc
    public func stopRefreshing() {
        refreshControl?.endRefreshing()
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        stopRefreshing()
        finishedLoading?()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handle(error: error)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handle(error: error)
    }
}

extension CanvasWebView: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print(windowFeatures)
        let target = CanvasWebView(config: configuration)
        
        let web = CanvasWebViewController(webView: target, showDoneButton: true)
        web.webView.customUserAgent = customUserAgent
        
        let nav = UINavigationController(rootViewController: web)
        presentingViewController?.present(nav, animated: true, completion: nil)
        return target
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        requestClose?()
    }
}
