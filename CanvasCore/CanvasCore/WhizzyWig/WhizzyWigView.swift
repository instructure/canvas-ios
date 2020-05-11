//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import UIKit
import WebKit
import Core

public typealias URLHandler = (URL)->()
var WhizzyWigOpenURLHandler: URLHandler? = { url in
    guard let from = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController() else { return }
    AppEnvironment.shared.router.route(to: url, from: from)
}

private func renderHTML(_ html: String, fontColor: UIColor, backgroundColor: UIColor, padding: UIEdgeInsets) -> String {
    let bundle = Bundle(for: WhizzyWigView.classForCoder())
    let templateURL = bundle.url(forResource: "WhizzyWigTemplate", withExtension: "html")
    var template = try! String(contentsOf: templateURL!, encoding: String.Encoding.utf8)

    template = template.replacingOccurrences(of: "{{fontColorDark}}", with: fontColor.hex)
    template = template.replacingOccurrences(of: "{{fontSize}}", with: "\(UIFont.scaledNamedFont(.regular16).pointSize)")
    template = template.replacingOccurrences(of: "{{backgroundColor}}", with: backgroundColor.hex)
    let paddingString = "\(padding.top)px \(padding.right)px \(padding.bottom)px \(padding.left)px;"
    template = template.replacingOccurrences(of: "{{padding}}", with: paddingString)
    template = template.replacingOccurrences(of: "{{linkColor}}", with: Brand.current.linkColor.hex)
    template = template.replacingOccurrences(of: "{{buttonPrimaryText}}", with: Brand.current.primaryButtonTextColor.hex)
    template = template.replacingOccurrences(of: "{{buttonPrimaryBackground}}", with: Brand.current.primaryButtonColor.hex)
    template = template.replacingOccurrences(of: "{{ltiLaunchText}}", with: NSLocalizedString("Launch External Tool", comment: ""))

    return template.replacingOccurrences(of: "{{content}}", with: html)
}

open class WhizzyWigView: WKWebView, WKNavigationDelegate {
    @objc open var contentFinishedLoading: ()->() = {}
    @objc open var didRecieveMessage: (String)->() = {_ in }
    @objc open private(set) var contentHeight: CGFloat = 43
    @objc open private(set) var contentWidth: CGFloat = 0
    @objc open var contentFontColor = Brand.current.fontColorDark
    @objc open var contentBackgroundColor = UIColor.white
    @objc open var contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    @objc open var useAPISafeLinks: Bool = true
    @objc open var allowLinks: Bool = true {
        didSet {
            isUserInteractionEnabled = allowLinks
        }
    }

    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        navigationDelegate = self
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = false
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        navigationDelegate = self
        scrollView.isScrollEnabled = false
    }

    @discardableResult
    open override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        return super.loadHTMLString(renderHTML(string, fontColor: contentFontColor, backgroundColor: contentBackgroundColor, padding: contentInsets), baseURL: baseURL)
    }

    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let navigationType = navigationAction.navigationType
        let request = navigationAction.request
        if !allowLinks && navigationType == .linkActivated {
            return decisionHandler(.cancel)
        } else if allowLinks && navigationType == .linkActivated && request.url != nil && request.url?.host != nil {
            if let requestURL = request.url {
                WhizzyWigOpenURLHandler?(requestURL)
            }
            return decisionHandler(.cancel)
        }

        if let url = request.url, url.scheme == "whizzywig" {
            contentHeight = CGFloat(Double(url.pathComponents[2]) ?? 43)
            contentWidth = CGFloat(Double(url.pathComponents[1]) ?? Double(frame.width))
            contentFinishedLoading()
            return decisionHandler(.cancel)
        }
        if request.url?.scheme == "canvas-message", let path = request.url?.path {
            didRecieveMessage(path)
            return decisionHandler(.cancel)
        }

        return decisionHandler(.allow)
    }

    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if useAPISafeLinks {
            webView.replaceHREFsWithAPISafeURLs()
        }
    }
    
    @objc public static func setOpenURLHandler(_ urlHandler: @escaping URLHandler) {
        WhizzyWigOpenURLHandler = urlHandler
    }
}
