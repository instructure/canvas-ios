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
import WebKit


public class ArcVideoPickerViewController: UIViewController {
    
    let arcLTIURL: URL
    let videoPickedAction: (URL)->()
    
    private let webView: WKWebView
    fileprivate var loaded = false
    
    
    /// Initializer
    ///
    /// - parameter arcLTIURL:          The arc lti launch URL. See `Assignment`s function to create one.
    /// - parameter videoPickedAction:  The handler to be executed after picking a video. This class dismisses itself automatically prior to calling this handler.
    public init(arcLTIURL: URL, videoPickedAction: @escaping (URL)->() = { _ in }) {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore.default()
        
        self.webView = WKWebView(frame: CGRect.zero, configuration: config)
        self.arcLTIURL = arcLTIURL
        self.videoPickedAction = videoPickedAction
        super.init(nibName: nil, bundle: nil)
        
        webView.navigationDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // https://mobiledev.instructure.com/courses/24219/external_tools/282032/resource_selection?launch_type=homework_submission&assignment_id=405404
        APIBridge.shared().call("getAuthenticatedSessionURL", args: [arcLTIURL.absoluteString]) { [weak self] response, error in
            if let data = response as? [String: Any],
                let sessionURL = data["session_url"] as? String,
                let url = URL(string: sessionURL) {
                self?.webView.load(URLRequest(url: url))
            } else if let url = self?.arcLTIURL {
                self?.webView.load(URLRequest(url: url))
            }
        }
    }
    
    func close() {
        navigationController?.popViewController(animated: true)
    }
}

extension ArcVideoPickerViewController: WKNavigationDelegate {
    
    // For those of you who think this is hack:
    // It totally is. Deal with it.
    // Why? When selecting a video from the device, Arc is doing (or iOS) some sort of refresh of the page. That
    // Was causing the upload to cancel too soon. So, this is what I could figure out to prevent that.
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if loaded && navigationAction.request.url == arcLTIURL {
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if !loaded && navigationResponse.response.url == arcLTIURL {
            loaded = true
        }
        
        if navigationResponse.response.url?.absoluteString.contains("success/external_tool_dialog") == true {
            webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in

                // The video url is in the redirect's page's content, in between a @id":" marker and the following comma
                let mark = "@id&quot;:&quot;"
                if let html = html as? String, let startIndex = html.range(of: mark) {
                    let startFRD = startIndex.upperBound
                    let r = Range(uncheckedBounds: (lower: startFRD, upper: html.endIndex))
                    if let nextCommaRange = html.range(of: "&quot;,", options: [], range: r, locale: nil) {
                        let dirtyURLRange = Range(uncheckedBounds: (lower: startFRD, upper: nextCommaRange.lowerBound))
                        let dirtyURLString = URL(string: html.substring(with: dirtyURLRange))?.absoluteString
                        if let dirtyURLString = dirtyURLString, let cleanURLString = String(htmlEncodedString: dirtyURLString), let url = URL(string: cleanURLString) {
                            self.close()
                            self.videoPickedAction(url)
                        }
                    }
                }
            }
        }
        
        decisionHandler(.allow)
    }
}

extension String {
    init?(htmlEncodedString: String) {
        let encodedData = htmlEncodedString.data(using: String.Encoding.utf8)!
        let attributedOptions: [String: Any] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
        ]
        guard let attributedString = try? NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil) else { return nil }
        self.init(attributedString.string)
    }
}

