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
    /**
     - parameters:
        - height: The height of the html content. Doesn't include the height of the theme switcher button.
     */
    func coreWebView(_ webView: CoreWebView, didChangeContentHeight height: CGFloat)
}

@IBDesignable
open class CoreWebView: WKWebView {
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
    public static let processPool = WKProcessPool()

    @IBInspectable public var autoresizesHeight: Bool = false
    public weak var linkDelegate: CoreWebViewLinkDelegate?
    public weak var sizeDelegate: CoreWebViewSizeDelegate?
    public var isLinkNavigationEnabled = true
    public var contentInputAccessoryView: UIView? {
        didSet {
            addContentInputAccessoryView()
        }
    }

    private(set) var features: [CoreWebViewFeature] = []
    private var htmlString: String?
    private var baseURL: URL?
    private let themeSwitcherButton = UIButton()
    private var isInverted = false {
        didSet {
            updateHtmlContentView()
        }
    }
    private var isThemeDark = false {
        didSet {
            if oldValue != isThemeDark, !isThemeDark {
                isInverted = false
            }
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public init() {
        super.init(frame: .zero, configuration: .defaultConfiguration)
        setup()
    }

    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        configuration.applyDefaultSettings()
        super.init(frame: frame, configuration: configuration)
        setup()
    }

    public init(features: [CoreWebViewFeature], configuration: WKWebViewConfiguration = .defaultConfiguration) {
        configuration.applyDefaultSettings()
        features.forEach { $0.apply(on: configuration) }

        super.init(frame: .zero, configuration: configuration)

        features.forEach { $0.apply(on: self) }
        self.features = features
        setup()
    }

    /**
     This method is to add support for CanvasCore project. Can be removed when that project is removed
     as this method isn't safe for features modifying `WKWebViewConfiguration`.
     */
    public func addFeature(_ feature: CoreWebViewFeature) {
        features.append(feature)
        feature.apply(on: self)
    }

    private init(externalConfiguration: WKWebViewConfiguration) {
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
            guard let self = self,
                  let body = message.body as? [String: CGFloat],
                  let height = body["height"]
            else { return }

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

    @discardableResult
    open override func loadHTMLString(_ string: String, baseURL: URL? = AppEnvironment.shared.currentSession?.baseURL) -> WKNavigation? {
        self.htmlString = string
        self.baseURL = baseURL
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
            \(optionalDarkModeCssStyle(for: content))
            \(jquery)
            \(content)
            </html>
        """
    }

    /** Only inject dark theme css if there's none present yet.  */
    private func optionalDarkModeCssStyle(for content: String) -> String {
        guard content.contains("prefers-color-scheme:dark") else {
            return "<style>\(darkModeCss())</style>"
        }
        return ""
    }

    /** Enables simple dark mode support for unsupported webview pages. */
    public func darkModeCss() -> String {

        let light: UIUserInterfaceStyle = isInverted ? .dark : .light
        let dark: UIUserInterfaceStyle = isInverted ? .light : .dark
        let background = UIColor.backgroundLightest.hexString(userInterfaceStyle: light)
        let backgroundDark = UIColor.backgroundLightest.hexString(userInterfaceStyle: dark)
        let foreground = UIColor.textDarkest.hexString(userInterfaceStyle: light)
        let foregroundDark = UIColor.textDarkest.hexString(userInterfaceStyle: dark)

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

        features.forEach { $0.webView(webView, didFinish: navigation) }
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

// MARK: - WKUIDelegate Delegate

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

// MARK: - Cookie Keep-Alive

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

// MARK: - Input Accessory View For RCE Editor

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

// MARK: - String Conversion

extension CoreWebView {

    /**
     Escapes html reserved characters in the given string so they will display as plain text.
     */
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

// MARK: - Color Scheme Switching

extension CoreWebView {
    public var themeSwitcherHeight: CGFloat {
        isThemeDark ? themeSwitchButtonHeight + themeSwitchButtonTopPadding : 0
    }
    private var themeSwitchButtonHeight: CGFloat { 38 }
    private var themeSwitchButtonTopPadding: CGFloat { 16 }

    public func updateHtmlContentView() {

        themeSwitcherButton.setNeedsUpdateConfiguration()
        guard let htmlString = htmlString, let baseURL = baseURL else { return }
        if htmlString.contains("prefers-color-scheme:dark") {
            super.overrideUserInterfaceStyle = isInverted ? .light : .unspecified
        } else {
            super.loadHTMLString(self.html(for: htmlString), baseURL: baseURL)
        }
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        isThemeDark = self.viewController?.traitCollection.userInterfaceStyle == .dark
    }

    /**
     Adds the theme switcher button to parent and sets up constraints between the webview, the button and parent.
     - parameters:
        - leading: The leading padding between the webview and the parent view. If nil is passed then it's the caller's responsibility to add this constraint. Default is 0.
        - trailing: The trailing padding between the webview and the parent view. If nil is passed then it's the caller's responsibility to add this constraint. Default is 0.
        - top: The top padding between the webview and the theme switcher button. If nil is passed then it's the caller's responsibility to add this constraint. Default is 0.
        - bottom: The bottom padding between the webview and the parent view. If nil is passed then it's the caller's responsibility to add this constraint. Default is 0.
     */
    public func pinWithThemeSwitchButton(inside parent: UIView?,
                                         leading: CGFloat? = 0,
                                         trailing: CGFloat? = 0,
                                         top: CGFloat? = 0,
                                         bottom: CGFloat? = 0) {
        guard let parent else { return }

        let padding: CGFloat = 16

        var buttonHeight: CGFloat {
            isThemeDark ? themeSwitchButtonHeight : 0
        }

        var buttonTopPadding: CGFloat {
            isThemeDark ? themeSwitchButtonTopPadding : 0
        }

        themeSwitcherButton.isHidden = !isThemeDark
        let buttonHeightConstraint = self.themeSwitcherButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        let buttonTopConstraint = self.themeSwitcherButton.topAnchor.constraint(equalTo: parent.topAnchor, constant: buttonTopPadding)

        isThemeDark = parent.viewController?.traitCollection.userInterfaceStyle == .dark
        let buttonTitle = NSLocalizedString("Switch To Light Mode", bundle: .core, comment: "")
        let invertedTitle = NSLocalizedString("Switch To Dark Mode", bundle: .core, comment: "")
        self.themeSwitcherButton.setTitle(self.isInverted ? invertedTitle : buttonTitle, for: .normal)

        themeSwitcherButton.addAction(UIAction(title: "", handler: { _ in
            self.isInverted.toggle()
            self.themeSwitcherButton.setTitle(self.isInverted ? invertedTitle : buttonTitle, for: .normal)
        }), for: .primaryActionTriggered)

        var config = UIButton.Configuration.borderedProminent()
        config.cornerStyle = .capsule
        config.background.strokeWidth = 1.0
        config.image = UIImage(named: "unionLine", in: .core, with: .none)
        config.imagePadding = 9.5
        config.imagePlacement = .leading
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        themeSwitcherButton.configuration = config
        themeSwitcherButton.configurationUpdateHandler = { button in
            var style: UIUserInterfaceStyle = self.isInverted ? .light : .dark
            if !self.isThemeDark {
                style = .light
            }
            let traitCollection = UITraitCollection(userInterfaceStyle: style)
            var config = button.configuration
            config?.title = self.isInverted ? invertedTitle : buttonTitle
            config?.background.backgroundColor = .backgroundLightest.resolvedColor(with: traitCollection)
            config?.background.strokeColor = .borderDarkest.resolvedColor(with: traitCollection)
            config?.baseForegroundColor = .textDarkest.resolvedColor(with: traitCollection)
            button.configuration = config
            button.isHidden = !self.isThemeDark
            buttonHeightConstraint.constant = buttonHeight
            buttonTopConstraint.constant = buttonTopPadding
            button.superview?.backgroundColor = .backgroundLightest.resolvedColor(with: traitCollection)
            self.backgroundColor = .backgroundLightest.resolvedColor(with: traitCollection)
        }

        parent.addSubview(themeSwitcherButton)

        translatesAutoresizingMaskIntoConstraints = false
        themeSwitcherButton.translatesAutoresizingMaskIntoConstraints = false
        buttonHeightConstraint.isActive = true
        buttonTopConstraint.isActive = true
        themeSwitcherButton.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: padding).isActive = true
        themeSwitcherButton.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -padding).isActive = true
        themeSwitcherButton.bottomAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true

        if let leading = leading {
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: leading).isActive = true
        }
        if let trailing = trailing {
            parent.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing).isActive = true
        }
        if let top = top {
            topAnchor.constraint(equalTo: themeSwitcherButton.bottomAnchor, constant: top).isActive = true
        }
        if let bottom = bottom {
            parent.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom).isActive = true
        }
    }
}
