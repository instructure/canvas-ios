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

public protocol CoreWebViewLinkDelegate: AnyObject {
    func handleLink(_ url: URL) -> Bool
    func finishedNavigation()
    var routeLinksFrom: UIViewController { get }
}

extension CoreWebViewLinkDelegate {
    public func finishedNavigation() {}
}

extension CoreWebViewLinkDelegate where Self: UIViewController {
    public func handleLink(_ url: URL) -> Bool {
        AppEnvironment.shared.router.route(to: url, from: routeLinksFrom)
        return true
    }
    public var routeLinksFrom: UIViewController { return self }
}

public protocol CoreWebViewSizeDelegate: AnyObject {
    func coreWebView(_ webView: CoreWebView, didChangeContentHeight height: CGFloat)
}

private extension WKWebViewConfiguration {

    func applyDefaultSettings() {
        allowsInlineMediaPlayback = true
        processPool = CoreWebView.processPool
    }
}

@IBDesignable
open class CoreWebView: WKWebView {
    public enum PullToRefresh {
        case disabled
        case enabled(color: UIColor?)
    }

    public static var defaultConfiguration: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.applyDefaultSettings()
        return configuration
    }

    private static var BalsamiqRegularCSSFontFace: String = {
        let url = Bundle.core.url(forResource: "font_balsamiq_regular", withExtension: "css")!
        // swiftlint:disable:next force_try
        return try! String(contentsOf: url)
    }()

    private static var LatoRegularCSSFontFace: String = {
        let url = Bundle.core.url(forResource: "font_lato_regular", withExtension: "css")!
        // swiftlint:disable:next force_try
        return try! String(contentsOf: url)
    }()
    private lazy var refreshControl: CircleRefreshControl = {
        let refreshControl = CircleRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(refreshWebView(_:)),
            for: .valueChanged
        )
        return refreshControl
    }()
    private let pullToRefresh: PullToRefresh
    private var pullToRefreshNavigation: WKNavigation?

    @IBInspectable public var autoresizesHeight: Bool = false
    public weak var linkDelegate: CoreWebViewLinkDelegate?
    public weak var sizeDelegate: CoreWebViewSizeDelegate?

    public var isLinkNavigationEnabled = true

    public static let processPool = WKProcessPool()

    public init(pullToRefresh: PullToRefresh) {
        self.pullToRefresh = pullToRefresh
        super.init(frame: .zero)
    }

    public required init?(coder: NSCoder) {
        pullToRefresh = .disabled
        super.init(coder: coder)
        setup()
    }

    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        pullToRefresh = .disabled
        configuration.applyDefaultSettings()
        super.init(frame: frame, configuration: configuration)
        setup()
    }

    /**
     - parameters:
        - invertColorsInDarkMode: If this parameter is true, then the webview will inject a script that inverts colors on the loaded website. Useful if we load 3rd party content without dark mode support.
     */
    public init(
        customUserAgentName: String? = nil,
        disableZoom: Bool = false,
        pullToRefresh: PullToRefresh,
        pullToRefreshColor: UIColor? = nil,
        configuration: WKWebViewConfiguration? = nil,
        invertColorsInDarkMode: Bool = false
    ) {
        self.pullToRefresh = pullToRefresh

        let config = configuration ?? Self.defaultConfiguration
        config.applyDefaultSettings()

        if let customUserAgentName = customUserAgentName {
            config.applicationNameForUserAgent = customUserAgentName
        }

        super.init(frame: .zero, configuration: config)

        if disableZoom {
            addScript(zoomScript)
        }

        if invertColorsInDarkMode {
            addScript(colorInvertInDarkModeScript)
        }

        if case let .enabled(color) = pullToRefresh {
            addRefreshControl(color: color)
        }

        setup()
    }

    private init(externalConfiguration: WKWebViewConfiguration) {
        self.pullToRefresh = .disabled
        super.init(frame: .zero, configuration: externalConfiguration)
        navigationDelegate = self
        uiDelegate = self
    }

    private func setup() {
        customUserAgent = UserAgent.safari.description
        navigationDelegate = self
        uiDelegate = self
        isOpaque = false
        backgroundColor = UIColor.clear

        addScript(js)
        handle("resize") { [weak self] message in
            guard let self = self, let body = message.body as? [String: CGFloat], let height = body["height"] else { return }
            self.sizeDelegate?.coreWebView(self, didChangeContentHeight: height)
            if self.autoresizesHeight, let constraint = self.constraints.first(where: { $0.firstItem === self && $0.firstAttribute == .height }) {
                constraint.constant = height
                self.setNeedsLayout()
            }
        }
        handle("loadFrameSource") { [weak self] message in
            guard let src = message.body as? String else { return }
            self?.loadFrame(src: src)
        }
    }

    private func addRefreshControl(color: UIColor?) {
        scrollView.addSubview(refreshControl)
        scrollView.bounces = true
        refreshControl.color = color
    }

    @objc func refreshWebView(_ sender: UIRefreshControl) {
        guard pullToRefreshNavigation == nil else { return }
        pullToRefreshNavigation = reload()
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
            <style>\(darkModeCss)</style>
            \(jquery)
            \(content)
            </html>
        """
    }

    var zoomScript: String {
        "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
    }

    // Forces dark mode on webview pages.

    public var colorInvertInDarkModeScript: String {
        let darkCss = """
        @media (prefers-color-scheme: dark) {
            html {
                filter: invert(100%) hue-rotate(180deg);
            }
            img:not(.ignore-color-scheme), video:not(.ignore-color-scheme), .ignore-color-scheme {
                filter: invert(100%) hue-rotate(180deg) !important;
            }
        }
        """

        let cssString = darkCss.components(separatedBy: .newlines).joined()
        return """
           var element = document.createElement('style');
           element.innerHTML = '\(cssString)';
           document.head.appendChild(element);
        """
    }

    /** Enables simple dark mode support for unsupported webview pages. */
    private var darkModeCss: String {
        let background = UIColor.backgroundLightest.hexString(userInterfaceStyle: .light)
        let backgroundDark = UIColor.backgroundLightest.hexString(userInterfaceStyle: .dark)
        let foreground = UIColor.textDarkest.hexString(userInterfaceStyle: .light)
        let foregroundDark = UIColor.textDarkest.hexString(userInterfaceStyle: .dark)

           return """
                body.dark-theme {
                  --text-color: \(foregroundDark);
                  --bkg-color: \(backgroundDark);
                }
                body {
                  --text-color: \(foreground);
                  --bkg-color: \(background);
                }

                @media (prefers-color-scheme: dark) {
                  /* defaults to dark theme */
                  html.light-theme {
                    --text-color: \(foreground);
                    --bkg-color: \(background);
                  }
                  html {
                    --text-color: \(foregroundDark);
                    --bkg-color: \(backgroundDark);
                  }
                }
                html {
                  background: var(--bkg-color);
                  color: var(--text-color);
                }
                """
    }

    /**
     This is used only if we load a html string locally but not for real URL loads.
     The font-size property of the body tag is overriden by the OS so that's why we set the p tag's font-size.
     */
    var css: String {
        let buttonBack = Brand.shared.buttonPrimaryBackground
        let buttonText = Brand.shared.buttonPrimaryText
        let link = Brand.shared.linkColor
        let font: String
        let fontCSS: String
        let style = Typography.Style.body
        let uiFont = style.uiFont

        if AppEnvironment.shared.k5.isK5Enabled {
            font = "BalsamiqSans-Regular"
            fontCSS = Self.BalsamiqRegularCSSFontFace
        } else {
            font = "Lato-Regular"
            fontCSS = Self.LatoRegularCSSFontFace
        }

        return """
            \(fontCSS)
            html {
                font-family: \(font);
                font-size: \(uiFont.pointSize)px;
                -webkit-tap-highlight-color: transparent;
            }
            body {
                margin: 16px;
            }
            p {
                font-size: \(uiFont.pointSize)px;
                line-height: \(style.lineHeight.toPoints(for: uiFont))px;
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
            function loadMathJaxIfNecessary() {
              let foundMath = !!document.querySelector('math') || document.body.innerText.includes('\\\\') || document.body.innerText.includes('$$')
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
                window.MathJax = { displayAlign: 'inherit', messageStyle: 'none' }
                const script = document.createElement('script')
                script.src = 'https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-AMS-MML_HTMLorMML'
                document.body.appendChild(script)
              }
            }
            loadMathJaxIfNecessary()

            function fixLTITools() {
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
                            iframe.replaceWith(video)
                        }
                    } else {
                        iframe.addEventListener('error', event => replace(event.target))
                    }
                })
            }
            fixLTITools()

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
                const height = window.editor && window.editor.contentHeight || document.documentElement.scrollHeight
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
            if (window.ResizeObserver) {
                new ResizeObserver(checkSize).observe(document.documentElement)
            }
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

        if let from = linkDelegate?.routeLinksFrom, let vc = from.presentedViewController,
           let baseUrl = AppEnvironment.shared.currentSession?.baseURL.absoluteString,
           let requestUrl = action.request.url?.absoluteString,
           let webViewUrl = webView.url?.absoluteString,
           requestUrl.contains(baseUrl), !webViewUrl.contains(baseUrl),
           let url = action.request.url?.path {
            vc.dismiss(animated: true) {
                AppEnvironment.shared.router.route(to: url, from: from)
            }
            return decisionHandler(.cancel)
        }

        // Check for #fragment link click
        if action.navigationType == .linkActivated,
           action.sourceFrame == action.targetFrame,
           let url = action.request.url, let fragment = url.fragment,
           let lhsString: String.SubSequence = self.url?.absoluteString.split(separator: "#").first,
           let rhsString: String.SubSequence = url.absoluteString.split(separator: "#").first,
           lhsString == rhsString {
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
        linkDelegate?.finishedNavigation()
        if let fragment = url?.fragment {
            scrollIntoView(fragment: fragment)
        }

        if navigation == pullToRefreshNavigation {
            refreshControl.endRefreshing()
            pullToRefreshNavigation = nil
        }
    }

    public func scrollIntoView(fragment: String, then: ((Bool) -> Void)? = nil) {
        guard autoresizesHeight else { return }
        let script = """
            (() => {
                let fragment = CSS.escape(\(CoreWebView.jsString(fragment)))
                let target = document.querySelector(`a[name=${fragment}],#${fragment}`)
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

extension CoreWebView: WKUIDelegate {
    public func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        guard let from = linkDelegate?.routeLinksFrom else { return completionHandler(false) }
        let alert = UIAlertController(title: frame.request.url?.host, message: message, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("OK", comment: ""), style: .default) { _ in
            completionHandler(true)
        })
        AppEnvironment.shared.router.show(alert, from: from, options: .modal())
    }

    public func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        guard let from = linkDelegate?.routeLinksFrom else { return completionHandler(false) }
        let alert = UIAlertController(title: frame.request.url?.host, message: message, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            completionHandler(false)
        })
        alert.addAction(AlertAction(NSLocalizedString("OK", comment: ""), style: .default) { _ in
            completionHandler(true)
        })
        AppEnvironment.shared.router.show(alert, from: from, options: .modal())
    }

    public func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (String?) -> Void
    ) {
        guard let from = linkDelegate?.routeLinksFrom else { return completionHandler(defaultText) }
        let alert = UIAlertController(title: frame.request.url?.host, message: prompt, preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            completionHandler(nil)
        })
        alert.addAction(AlertAction(NSLocalizedString("OK", comment: ""), style: .default) { _ in
            completionHandler(alert.textFields?[0].text)
        })
        AppEnvironment.shared.router.show(alert, from: from, options: .modal())
    }

    public func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard let from = linkDelegate?.routeLinksFrom else { return nil }
        let controller = CoreWebViewController()
        // Don't change the processPool of this configuration otherwise it will crash
        controller.webView = CoreWebView(externalConfiguration: configuration)
        controller.webView.linkDelegate = linkDelegate
        AppEnvironment.shared.router.show(
            controller,
            from: from,
            options: .modal(.formSheet, embedInNav: true, addDoneButton: true)
        )
        return controller.webView
    }

    public func webViewDidClose(_ webView: WKWebView) {
        guard let controller = linkDelegate?.routeLinksFrom else { return }
        AppEnvironment.shared.router.dismiss(controller)
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
