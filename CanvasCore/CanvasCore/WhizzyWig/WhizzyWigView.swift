//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import UIKit
import WebKit

public typealias URLHandler = (URL)->()
var WhizzyWigOpenURLHandler: URLHandler?

private func renderHTML(_ html: String, width: CGFloat, fontColor: UIColor, backgroundColor: UIColor, padding: UIEdgeInsets) -> String {
    let bundle = Bundle(for: WhizzyWigView.classForCoder())
    let templateURL = bundle.url(forResource: "WhizzyWigTemplate", withExtension: "html")
    var template = try! String(contentsOf: templateURL!, encoding: String.Encoding.utf8)

    template = template.replacingOccurrences(of: "{{content-width}}", with: "\(width)")
    func colorString(_ color: UIColor) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        r = r * 255; g = g * 255; b = b * 255
        return "rgb(\(Int(r)),\(Int(g)),\(Int(b)))"
    }
    template = template.replacingOccurrences(of: "{{font-color}}", with: colorString(fontColor))
    template = template.replacingOccurrences(of: "{{background-color}}", with: colorString(backgroundColor))
    let paddingString: String = {
        return "\(Int(padding.top))px \(Int(padding.right))px \(Int(padding.bottom))px \(Int(padding.left))px;"
    }()
    template = template.replacingOccurrences(of: "{{padding}}", with: paddingString)
    return template.replacingOccurrences(of: "{{content}}", with: html)
}

open class WhizzyWigView: WKWebView, WKNavigationDelegate {
    @objc open var contentFinishedLoading: ()->() = {}
    @objc open var didRecieveMessage: (String)->() = {_ in }
    @objc open private(set) var contentHeight: CGFloat = 43
    @objc open private(set) var contentWidth: CGFloat = 0
    @objc open var contentFontColor = UIColor.black
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
        return super.loadHTMLString(renderHTML(string, width: frame.width, fontColor: contentFontColor, backgroundColor: contentBackgroundColor, padding: contentInsets), baseURL: baseURL)
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
