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

public typealias URLHandler = (URL)->()
var WhizzyWigOpenURLHandler: URLHandler?

private func renderHTML(_ html: String, width: Float, fontColor: UIColor, backgroundColor: UIColor, padding: UIEdgeInsets) -> String {
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

open class WhizzyWigView: UIWebView, UIWebViewDelegate {
    @objc open var contentFinishedLoading: ()->() = {}
    @objc open var didRecieveMessage: (String)->() = {_ in }
    @objc open var contentHeight: CGFloat {
        let heightString = stringByEvaluatingJavaScript(from: "document.getElementById('whizzy_content').scrollHeight") ?? "43.0"
        return CGFloat((heightString as NSString).doubleValue)
    }
    @objc open var contentWidth: CGFloat {
        guard let widthString = stringByEvaluatingJavaScript(from: "document.documentElement.scrollWidth") else {
            return frame.width
        }
        return CGFloat((widthString as NSString).doubleValue)
    }
    @objc open var contentFontColor = UIColor.black
    @objc open var contentBackgroundColor = UIColor.white
    @objc open var contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    @objc open var useAPISafeLinks: Bool = true
    @objc open var allowLinks: Bool = true {
        didSet {
            isUserInteractionEnabled = allowLinks
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        scrollView.isScrollEnabled = false
    }
    
    open override func loadHTMLString(_ string: String, baseURL: URL?) {
        super.loadHTMLString(renderHTML(string, width: Float(frame.size.width), fontColor: contentFontColor, backgroundColor: contentBackgroundColor, padding: contentInsets), baseURL: baseURL)
    }
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        
        if !allowLinks && navigationType == .linkClicked {
            return false
        } else if allowLinks && navigationType == .linkClicked && request.url != nil && request.url?.host != nil {
            if let requestURL = request.url {
                WhizzyWigOpenURLHandler?(requestURL)
            }
            return false
        }
        
        if request.url?.scheme == "whizzywig" {
            contentFinishedLoading()
            return false
        }
        if request.url?.scheme == "canvas-message", let path = request.url?.path {
            didRecieveMessage(path)
            return false
        }
        
        return true
    }
    
    open func webViewDidFinishLoad(_ webView: UIWebView) {
        if useAPISafeLinks {
            webView.replaceHREFsWithAPISafeURLs()
        }
    }
    
    @objc public static func setOpenURLHandler(_ urlHandler: @escaping URLHandler) {
        WhizzyWigOpenURLHandler = urlHandler
    }
}
