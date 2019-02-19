//
// Copyright (C) 2018-present Instructure, Inc.
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

@IBDesignable
open class CoreWebView: WKWebView {
    public enum Navigation {
        case withinWebView
        case deepLink((URL) -> Bool?)
    }

    @IBInspectable public var autoresizesHeight: Bool = false
    public var navigation = Navigation.withinWebView
    private lazy var messagePasser: MessagePasser = {
        return MessagePasser(webView: self)
    }()

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

        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
        configuration.userContentController.add(messagePasser, name: "resize")
    }

    @discardableResult
    open override func loadHTMLString(_ string: String, baseURL: URL? = Keychain.currentSession?.baseURL) -> WKNavigation? {
        return super.loadHTMLString(html(for: string), baseURL: baseURL)
    }

    func html(for content: String) -> String {
        // If it looks like jQuery is used, include the same version of jQuery as web.
        let jquery = content.contains("$(") || content.contains("$.")
            ? "<script defer src=\"https://cdnjs.cloudflare.com/ajax/libs/jquery/1.7.2/jquery.min.js\"></script>"
            : ""

        return """
            <!doctype html>
            <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no" />
            <style>\(css)</style>
            \(jquery)
            \(content)
        """
    }

    var css: String {
        let buttonBack = Brand.shared.buttonPrimaryBackground.ensureContrast(against: .named(.backgroundLightest))
        let buttonFore = Brand.shared.buttonPrimaryText.ensureContrast(against: buttonBack)
        let link = Brand.shared.linkColor.ensureContrast(against: .named(.backgroundLightest))

        return """
            body {
                color: \(UIColor.named(.textDarkest).hexString);
                font: -apple-system-body;
                margin: 16px;
            }
            a {
                color: \(link.hexString);
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
                color: \(buttonFore.hexString);
                text-decoration: none;
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
                if (!img.dataset.mathml && !img.dataset.equationContent) return
                foundMath = true
                const div = document.createElement('div')
                div.innerHTML = img.dataset.mathml || `$$${img.dataset.equationContent}$$`
                img.parentNode.replaceChild(div.firstChild, img)
            })
            if (foundMath) {
                const script = document.createElement('script')
                script.src = 'https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-AMS-MML_HTMLorMML'
                document.body.appendChild(script)
            }

            // Replace all iframes with a button to launch in SFSafariViewController
            document.querySelectorAll('iframe').forEach(iframe => {
                const replace = iframe => {
                    const a = document.createElement('a')
                    a.textContent = '\(buttonText)'
                    a.classList.add('canvas-ios-lti-launch-button')
                    a.href = iframe.src
                    iframe.parentNode.replaceChild(a, iframe)
                }
                if (/\\/courses\\/\\d+\\/external_tools\\/retrieve/.test(iframe.src)) {
                    replace(iframe)
                } else {
                    iframe.addEventListener('error', event => replace(event.target))
                }
            })

            // Send content height whenever it changes
            let lastHeight = 0
            const checkSize = () => {
                let height = document.documentElement.scrollHeight
                if (lastHeight !== height) {
                    lastHeight = height
                    window.webkit.messageHandlers.resize.postMessage({ height })
                }
            }
            const observer = new MutationObserver(checkSize)
            observer.observe(document.documentElement, { attributes: true, childList: true, subtree: true })
            window.addEventListener('resize', checkSize)
            window.addEventListener('load', checkSize)
            document.addEventListener('load', checkSize, true)
            checkSize()
        """
    }

    /// This works around a memory leak caused by the WKUserContentController keeping a strong reference to
    /// message handlers. This has a weak reference back to the CoreWebView, breaking the cycle.
    private class MessagePasser: NSObject, WKScriptMessageHandler {
        weak var webView: CoreWebView?

        init(webView: CoreWebView) {
            self.webView = webView
            super.init()
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            webView?.handleScriptMessage(message)
        }
    }

    func handleScriptMessage(_ message: WKScriptMessage) {
        switch message.name {
        case "resize":
            if autoresizesHeight, let body = message.body as? [String: CGFloat], let height = body["height"],
                let constraint = constraints.first(where: { $0.firstItem === self && $0.firstAttribute == .height }) {
                constraint.constant = height
                setNeedsLayout()
            }
        default:
            break
        }
    }
}

extension CoreWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Check for #fragment link click
        if action.navigationType == .linkActivated, action.sourceFrame == action.targetFrame,
            let url = action.request.url, let fragment = url.fragment,
            self.url?.absoluteString.split(separator: "#").first == url.absoluteString.split(separator: "#").first {
            scrollIntoView(fragment: fragment)
            return decisionHandler(.allow) // let web view scroll to link too, if necessary
        }

        // Forward decision to external handler
        if action.navigationType == .linkActivated, let url = action.request.url,
            case .deepLink(let handle) = navigation, handle(url) == true {
            return decisionHandler(.cancel)
        }

        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let fragment = url?.fragment {
            scrollIntoView(fragment: fragment)
        }
    }

    public func scrollIntoView(fragment: String) {
        guard autoresizesHeight else { return }
        let script = """
            (() => {
                let target = document.querySelector('a[name=\"\(fragment)\"],#\(fragment)')
                return target ? target.clientTop || target.offsetTop : null
            })()
        """
        evaluateJavaScript(script) { (result: Any?, _: Error?) in
            guard var offset = result as? CGFloat else { return }
            var view: UIView = self
            while let parent = view.superview {
                offset += view.frame.minY
                view = parent
                guard let scrollView = parent as? UIScrollView, scrollView.isScrollEnabled else { continue }
                let y = min(offset, scrollView.contentSize.height - scrollView.frame.height)
                scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: y), animated: true)
                break
            }
        }
    }
}

extension CoreWebView {
    static var cookieKeepAliveTimer: Timer?
    static var cookieKeepAliveWebView = CoreWebView()

    public static func keepCookieAlive(for env: AppEnvironment) {
        guard env.api.accessToken != nil else { return }
        DispatchQueue.main.async {
            cookieKeepAliveTimer?.invalidate()
            let interval: TimeInterval = 10 * 60 // ten minutes
            cookieKeepAliveTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                let useCase = RequestUseCase(api: env.api, database: env.database, request: GetWebSessionRequest(to: env.api.baseURL.appendingPathComponent("users/self")))
                useCase.addSaveOperation { data, _, _ in DispatchQueue.main.async {
                    guard let url = data?.session_url else { return }
                    cookieKeepAliveWebView.load(URLRequest(url: url))
                } }
                env.queue.addOperation(useCase)
            }
            cookieKeepAliveTimer?.fire()
        }
    }

    public static func stopCookieKeepAlive() {
        DispatchQueue.main.async {
            cookieKeepAliveTimer?.invalidate()
            cookieKeepAliveTimer = nil
        }
    }
}
