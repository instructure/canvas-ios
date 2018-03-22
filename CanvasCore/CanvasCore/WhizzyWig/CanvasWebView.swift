//
//  CanvasWebView.swift
//  CanvasCore
//
//  Created by Derrick Hathaway on 11/3/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import WebKit
import CanvasKeymaster
import CanvasKit
import ReactiveSwift

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
        weak var webView: CanvasWebView?

        init(webView: CanvasWebView) {
            self.webView = webView
            super.init()
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "dismiss":
                webView?.requestClose?()
            case "canvas":
                webView?.onMessage?(["body": message.body])
            case "height":
                guard let height = message.body as? [String: Any] else { return }
                webView?.onHeightChange?(height)
            default:
                break
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
    public var onError: ((Error) -> Void)?

    @objc var requestClose: (() -> Void)?
    
    @objc
    public weak var presentingViewController: UIViewController?

    fileprivate var externalToolLaunchDisposable: Disposable?
    
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
            let fromTemplate = PageTemplateRenderer.htmlString(
                title: title,
                body: "<p>\(description)</p>",
                viewportWidth: bounds.width
            )
            loadHTMLString(fromTemplate, baseURL: nil)
        case let .html(title, body, baseURL):
            let fromTemplate = PageTemplateRenderer.htmlString(
                title: title,
                body: body,
                viewportWidth: bounds.width
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
    
    public init(config: WKWebViewConfiguration) {
        super.init(frame: .zero, configuration: config)
        translatesAutoresizingMaskIntoConstraints = false
        navigationDelegate = self
        uiDelegate = self
    }
    
    public convenience init() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        self.init(config: config)

        config.userContentController.add(MessageHandler(webView: self), name: "dismiss")
        config.userContentController.add(MessageHandler(webView: self), name: "canvas")
        config.userContentController.add(MessageHandler(webView: self), name: "height")

        if let jsPath = Bundle.core.url(forResource: "CanvasWebView", withExtension: "js"),
            let js = try? String(contentsOf: jsPath, encoding: .utf8) {
            let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            config.userContentController.addUserScript(script)
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    fileprivate func scroll(to fragment: String?, elseDo failBlock: @escaping () -> Void) {
        guard let f = fragment else {
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateViewport()
    }
    
    func updateViewport() {
        // don't mess with the viewport for external sources
        if case .some(.url) = source {
            return
        }

        let width = Int(bounds.width)
        let js = "(function (width) {let metaViewport = document.querySelector('meta[name=viewport]');if (metaViewport) {metaViewport.content='width = ' + width + ', user-scalable = no';} else {let meta = document.createElement('meta');meta.setAttribute( 'name', 'viewport' );meta.setAttribute( 'content', 'width = '+ width + ', user-scalable = yes' );document.getElementsByTagName('head')[0].appendChild(meta);}})(\(width))"
        evaluateJavaScript(js, completionHandler: nil)
    }
    
    public func htmlContentHeight(completionHandler: @escaping (CGFloat) -> Void) {
        evaluateJavaScript("document.getElementById('_end_').offsetTop") { result, error in
            guard let height = result as? NSNumber else { completionHandler(0.0); return }
            completionHandler(CGFloat(height))
        }
    }

    fileprivate func handle(error: Error) {
        (error as NSError).userInfo.forEach { key, value in print("\(key) => \(value)") }
        
        let e = error as NSError
        let failingURL = e.userInfo[NSURLErrorFailingURLErrorKey] as? URL ??
            (e.userInfo[NSURLErrorFailingURLStringErrorKey] as? String).flatMap(URL.init)
        
        if let url = failingURL {
            if let scheme = url.scheme, ["https", "http"].contains(scheme) {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                if success {
                    self.requestClose?()
                } else {
                    self.onError?(error)
                }
            })
        } else {
            self.onError?(error)
        }
    }
}

extension CanvasWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let request = action.request
        
        if let url = request.url, url.absoluteString.contains("google-drive-lti") {
            customUserAgent = CKILoginViewController.safariUserAgent()
        }

        if let url = request.url, url.path.contains("/external_tools/retrieve"), action.navigationType == .linkActivated {
            if let presentingViewController = presentingViewController, let session = CanvasKeymaster.the().currentClient?.authSession {
                ExternalToolManager.shared.launch(url, in: session, from: presentingViewController)
            }
            return decisionHandler(.cancel)
        }
        
        if Secrets.openExternalResourceIfNecessary(aURL: request.url) {
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
            scroll(to: url.fragment, elseDo: {
                if url.scheme != "http" && url.scheme != "https" && UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    handler(url)
                }
            })

            return decisionHandler(.cancel)
        }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if (!webView.isLoading) {
            updateViewport()
        }
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
