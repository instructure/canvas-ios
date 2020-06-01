//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public protocol CoreWebViewLinkDelegate: class {
    func handleLink(_ url: URL) -> Bool
    var routeLinksFrom: UIViewController { get }
}

extension CoreWebViewLinkDelegate where Self: UIViewController {
    public func handleLink(_ url: URL) -> Bool {
        AppEnvironment.shared.router.route(to: url, from: routeLinksFrom)
        return true
    }
    public var routeLinksFrom: UIViewController { return self }
}

@IBDesignable
open class CoreWebView: WKWebView {
    @IBInspectable public var autoresizesHeight: Bool = false
    public weak var linkDelegate: CoreWebViewLinkDelegate?

    public var isLinkNavigationEnabled = true

    public static let processPool = WKProcessPool()

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        configuration.processPool = CoreWebView.processPool
        super.init(frame: frame, configuration: configuration)
        setup()
    }

    func setup() {
        customUserAgent = UserAgent.safari.description
        navigationDelegate = self

        addScript(js)
        handle("resize") { [weak self] message in
            guard let self = self else { return }
            if self.autoresizesHeight, let body = message.body as? [String: CGFloat], let height = body["height"],
                let constraint = self.constraints.first(where: { $0.firstItem === self && $0.firstAttribute == .height }) {
                constraint.constant = height
                self.setNeedsLayout()
            }
        }
        handle("loadFrameSource") { [weak self] message in
            guard let src = message.body as? String else { return }
            self?.loadFrame(src: src)
        }
    }

    public var contentInputAccessoryView: UIView? {
        didSet {
            addContentInputAccessoryView()
        }
    }

    @discardableResult
    open override func loadHTMLString(_ string: String, baseURL: URL? = AppEnvironment.shared.currentSession?.baseURL) -> WKNavigation? {
        return super.loadHTMLString(html(for: string), baseURL: baseURL)
    }

    func loadFrame(src: String) {
        let url = URL(string: src)
        let request = GetWebSessionRequest(to: url)
        AppEnvironment.shared.api.makeRequest(request) { [weak self] response, _, _ in performUIUpdate {
            guard let response = response else { return }
            self?.load(URLRequest(url: response.session_url))
        } }
    }

    func html(for content: String) -> String {
        // If it looks like jQuery is used, include the same version of jQuery as web.
        let jquery = content.contains("$(") || content.contains("$.")
            ? "<script defer src=\"https://cdnjs.cloudflare.com/ajax/libs/jquery/1.7.2/jquery.min.js\"></script>"
            : ""

        return """
            <!doctype html>
            <html
                lang="\(CoreWebView.htmlString(Locale.current.identifier))"
                dir="\(effectiveUserInterfaceLayoutDirection == .leftToRight ? "ltr" : "rtl")"
            >
            <meta name="viewport" content="initial-scale=1, minimum-scale=1, maximum-scale=1, user-scalable=no" />
            <style>\(css)</style>
            \(jquery)
            \(content)
            </html>
        """
    }

    var css: String {
        let buttonBack = Brand.shared.buttonPrimaryBackground.ensureContrast(against: .named(.backgroundLightest))
        let buttonText = Brand.shared.buttonPrimaryText.ensureContrast(against: buttonBack)
        let link = Brand.shared.linkColor.ensureContrast(against: .named(.backgroundLightest))

        return """
            html {
                background: \(UIColor.named(.backgroundLightest).hexString);
                color: \(UIColor.named(.textDarkest).hexString);
                font-family: system-ui;
                font-size: \(UIFont.scaledNamedFont(.regular16).pointSize)px;
                -webkit-tap-highlight-color: transparent;
            }
            body {
                margin: 16px;
            }
            a {
                color: \(link.hexString);
                overflow-wrap: break-word;
            }
            h2 {
                font-weight: 300;
            }
            h3, h4 {
                font-weight: 400;
            }
            iframe {
                border: none;
                width: 100% !important;
                margin: 0;
                padding-top: 0;
            }
            img, video {
                max-width: 100% !important;
                height: auto !important;
                margin: 0 auto 0 auto;
                padding: 0;
            }
            .canvas-ios-lti-launch-button {
                display: block;
                margin: 20 auto 20 auto;
                padding: 12px 8px 12px 8px;
                background-color: \(buttonBack.hexString);
                border-radius: 4px;
                color: \(buttonText.hexString);
                font-weight: 600;
                text-decoration: none;
                text-align: center;
            }
            .lock-explanation {
                font-weight: 500;
                font-size: 1rem;
                text-align: center;
            }
        """
    }

    var js: String {
        let buttonText = NSLocalizedString("Launch External Tool", bundle: .core, comment: "")

        return """
            // Handle Math Equations
            let foundMath = !!document.querySelector('math')
            document.querySelectorAll('img.equation_image').forEach(img => {
              let mathml = img.getAttribute('x-canvaslms-safe-mathml')
              if (!mathml && !img.dataset.equationContent) return
              foundMath = true
              const div = document.createElement('div')
              div.innerHTML = mathml || '<span>$$' + img.dataset.equationContent + '$$</span>'
              div.firstChild.setAttribute('style', img.getAttribute('style'))
              img.parentNode.replaceChild(div.firstChild, img)
            })
            if (foundMath) {
              window.MathJax = { displayAlign: 'inherit' }
              const script = document.createElement('script')
              script.src = 'https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-AMS-MML_HTMLorMML'
              document.body.appendChild(script)
            }

            // Replace all iframes with a button to launch in SFSafariViewController
            document.querySelectorAll('iframe').forEach(iframe => {
                const replace = iframe => {
                    const a = document.createElement('a')
                    a.textContent = \(CoreWebView.jsString(buttonText))
                    a.classList.add('canvas-ios-lti-launch-button')
                    a.href = iframe.src
                    iframe.parentNode.replaceChild(a, iframe)
                }
                if (/\\/(courses|accounts)\\/[^\\/]+\\/external_tools\\/retrieve/.test(iframe.src)) {
                    replace(iframe)
                } else if (/\\/media_objects_iframe\\/m-\\w+/.test(iframe.src)) {
                    const match = iframe.src.match(/\\/media_objects_iframe\\/(m-\\w+)/)
                    if (match.length == 2) {
                        const mediaID = match[1]
                        const video = document.createElement('video')
                        video.src = '/users/self/media_download?entryId='+mediaID+'&media_type=video&redirect=1'
                        video.setAttribute('poster', '/media_objects/'+mediaID+'/thumbnail?width=550&height=448')
                        video.setAttribute('controls', '')
                        video.setAttribute('preload', 'none')
                        iframe.parentNode.parentNode.replaceChild(video, iframe.parentNode)
                    }
                } else {
                    iframe.addEventListener('error', event => replace(event.target))
                }
            })

            // If there is only one iframe
            // and id="cnvs_content"
            // and the src is a canvas file
            // reload the webview with an authenticated version of the iframe's src
            // https://community.canvaslms.com/thread/31562-canvas-ios-app-not-loading-iframe-content
            const iframes = document.querySelectorAll('iframe');
            if (iframes.length == 1 && /\\/courses\\/\\d+\\/files\\/\\d+\\/download/.test(iframes[0].src) && iframes[0].id === "cnvs_content") {
                window.webkit.messageHandlers.loadFrameSource.postMessage(iframes[0].src)
            }

            // Send content height whenever it changes
            let lastHeight = 0
            let lastWidth = window.innerWidth
            const checkSize = () => {
                let height = document.documentElement.scrollHeight
                if (lastHeight !== height) {
                    lastHeight = height
                    window.webkit.messageHandlers.resize.postMessage({ height })
                }
            }
            const observer = new MutationObserver(checkSize)
            observer.observe(document.documentElement, { attributes: true, childList: true, subtree: true })
            window.addEventListener('resize', () => {
                let width = window.innerWidth
                if (lastWidth !== width) {
                    lastWidth = width
                    checkSize()
                }
            })
            window.addEventListener('load', () => {
                checkSize()
                document.addEventListener('load', checkSize, true)
            })
            window.addEventListener('error', checkSize, true)
            checkSize()
        """
    }
}

extension CoreWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if action.navigationType == .linkActivated && !isLinkNavigationEnabled {
            decisionHandler(.cancel)
            return
        }

        // Check for #fragment link click
        if action.navigationType == .linkActivated, action.sourceFrame == action.targetFrame,
            let url = action.request.url, let fragment = url.fragment,
            self.url?.absoluteString.split(separator: "#").first == url.absoluteString.split(separator: "#").first {
            scrollIntoView(fragment: fragment)
            return decisionHandler(.allow) // let web view scroll to link too, if necessary
        }

        // Handle "Launch External Tool" button
        if action.navigationType == .linkActivated, let tools = LTITools(link: action.request.url),
            let from = linkDelegate?.routeLinksFrom {
            tools.presentTool(from: from, animated: true)
            return decisionHandler(.cancel)
        }

        // Forward decision to delegate
        if action.navigationType == .linkActivated, let url = action.request.url,
            linkDelegate?.handleLink(url) == true {
            return decisionHandler(.cancel)
        }

        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let fragment = url?.fragment {
            scrollIntoView(fragment: fragment)
        }
    }

    public func scrollIntoView(fragment: String, then: ((Bool) -> Void)? = nil) {
        guard autoresizesHeight else { return }
        let script = """
            (() => {
                let target = document.querySelector('a[name=\"\(fragment)\"],#\(fragment)')
                return target && target.getBoundingClientRect().y
            })()
        """
        evaluateJavaScript(script) { (result: Any?, _: Error?) in
            guard var offset = result as? CGFloat else {
                then?(false)
                return
            }
            var view: UIView = self
            while let parent = view.superview {
                offset += view.frame.minY
                view = parent
                guard let scrollView = parent as? UIScrollView, scrollView.isScrollEnabled else { continue }
                let y = min(offset, scrollView.contentSize.height - scrollView.frame.height)
                scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: y), animated: true)
                break
            }
            then?(true)
        }
    }
}

extension CoreWebView {
    static var cookieKeepAliveTimer: Timer?
    static var cookieKeepAliveWebView = CoreWebView()

    public static func keepCookieAlive(for env: AppEnvironment) {
        guard env.api.loginSession?.accessToken != nil else { return }
        performUIUpdate {
            cookieKeepAliveTimer?.invalidate()
            let interval: TimeInterval = 10 * 60 // ten minutes
            cookieKeepAliveTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                let request = GetWebSessionRequest(to: env.api.baseURL.appendingPathComponent("users/self"))
                env.api.makeRequest(request) { data, _, _ in performUIUpdate {
                    guard let url = data?.session_url else { return }
                    cookieKeepAliveWebView.load(URLRequest(url: url))
                } }
            }
            cookieKeepAliveTimer?.fire()
        }
    }

    public static func stopCookieKeepAlive() {
        performUIUpdate {
            cookieKeepAliveTimer?.invalidate()
            cookieKeepAliveTimer = nil
        }
    }
}

extension CoreWebView {
    private func addContentInputAccessoryView() {
        guard
            let contentView = scrollView.subviews.first(where: { String(describing: type(of: $0)).hasPrefix("WKContent") }),
            let superClass = object_getClass(contentView)
        else { return }
        let contentClassName = "CoreWebContent"
        if let contentClass = NSClassFromString(contentClassName) {
            object_setClass(contentView, contentClass)
            return
        }
        guard
            let method = class_getInstanceMethod(CoreWebView.self, #selector(CoreWebView.getParentContentInputAccessoryView)),
            let contentClass = objc_allocateClassPair(superClass, contentClassName, 0)
        else { return }
        class_addMethod(contentClass, #selector(getter: UIResponder.inputAccessoryView), method_getImplementation(method), method_getTypeEncoding(method))
        objc_registerClassPair(contentClass)
        object_setClass(contentView, contentClass)
    }

    @objc func getParentContentInputAccessoryView() -> UIView? {
        var view: UIView? = self
        while view != nil {
            if let webView = view as? CoreWebView {
                return webView.contentInputAccessoryView
            }
            view = view?.superview
        }
        return nil
    }
}

extension CoreWebView {
    public static func jsString(_ string: String?) -> String {
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

    public static func htmlString(_ string: String?) -> String {
        guard let string = string else { return "" }
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "'", with: "&#39;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
