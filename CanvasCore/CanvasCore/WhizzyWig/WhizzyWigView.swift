//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
    open var contentFinishedLoading: ()->() = {}
    open var contentHeight: CGFloat {
        let heightString = stringByEvaluatingJavaScript(from: "document.getElementById('whizzy_content').scrollHeight") ?? "43.0"
        return CGFloat((heightString as NSString).doubleValue)
    }
    open var contentFontColor = UIColor.black
    open var contentBackgroundColor = UIColor.white
    open var contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    open var useAPISafeLinks: Bool = true
    open var allowLinks: Bool = true {
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
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
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
        
        return true
    }
    
    open func webViewDidFinishLoad(_ webView: UIWebView) {
        if useAPISafeLinks {
            webView.replaceHREFsWithAPISafeURLs()
        }
    }
    
    open static func setOpenURLHandler(_ urlHandler: @escaping URLHandler) {
        WhizzyWigOpenURLHandler = urlHandler
    }
}
