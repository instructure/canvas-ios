
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

public typealias URLHandler = (NSURL)->()
var WhizzyWigOpenURLHandler: URLHandler?

private func renderHTML(html: String, width: Float, fontColor: UIColor, backgroundColor: UIColor, padding: UIEdgeInsets) -> String {
    let bundle = NSBundle(forClass: WhizzyWigView.classForCoder())
    let templateURL = bundle.URLForResource("WhizzyWigTemplate", withExtension: "html")
    var template = try! String(contentsOfURL: templateURL!, encoding: NSUTF8StringEncoding)

    template = template.stringByReplacingOccurrencesOfString("{{content-width}}", withString: "\(width)")
    func colorString(color: UIColor) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        r = r * 255; g = g * 255; b = b * 255
        return "rgb(\(Int(r)),\(Int(g)),\(Int(b)))"
    }
    template = template.stringByReplacingOccurrencesOfString("{{font-color}}", withString: colorString(fontColor))
    template = template.stringByReplacingOccurrencesOfString("{{background-color}}", withString: colorString(backgroundColor))
    let paddingString: String = {
        return "\(Int(padding.top))px \(Int(padding.right))px \(Int(padding.bottom))px \(Int(padding.left))px;"
    }()
    template = template.stringByReplacingOccurrencesOfString("{{padding}}", withString: paddingString)
    return template.stringByReplacingOccurrencesOfString("{{content}}", withString: html)
}

public class WhizzyWigView: UIWebView, UIWebViewDelegate {
    public var contentFinishedLoading: ()->() = {}
    public var contentHeight: CGFloat {
        let heightString = stringByEvaluatingJavaScriptFromString("document.getElementById('whizzy_content').scrollHeight") ?? "43.0"
        return CGFloat((heightString as NSString).doubleValue)
    }
    public var contentFontColor = UIColor.blackColor()
    public var contentBackgroundColor = UIColor.whiteColor()
    public var contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    public var useAPISafeLinks: Bool = true
    public var allowLinks: Bool = true {
        didSet {
            userInteractionEnabled = allowLinks
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.scrollEnabled = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        scrollView.scrollEnabled = false
    }
    
    public override func loadHTMLString(string: String, baseURL: NSURL?) {
        super.loadHTMLString(renderHTML(string, width: Float(frame.size.width), fontColor: contentFontColor, backgroundColor: contentBackgroundColor, padding: contentInsets), baseURL: baseURL)
    }
    
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if !allowLinks && navigationType == .LinkClicked {
            return false
        } else if allowLinks && navigationType == .LinkClicked && request.URL != nil && request.URL?.host != nil {
            if let requestURL = request.URL {
                WhizzyWigOpenURLHandler?(requestURL)
            }
            return false
        }
        
        if request.URL?.scheme == "whizzywig" {
            contentFinishedLoading()
            return false
        }
        
        return true
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        if useAPISafeLinks {
            webView.replaceHREFsWithAPISafeURLs()
        }
    }
    
    public static func setOpenURLHandler(urlHandler: URLHandler) {
        WhizzyWigOpenURLHandler = urlHandler
    }
}
