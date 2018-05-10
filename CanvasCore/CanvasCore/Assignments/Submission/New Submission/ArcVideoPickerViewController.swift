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
    
    // Reverting back to UIWebView because can actually get the request httpBody, WKWebView didn't work for that
    private let webView: UIWebView
    
    /// Initializer
    ///
    /// - parameter arcLTIURL:          The arc lti launch URL. See `Assignment`s function to create one.
    /// - parameter videoPickedAction:  The handler to be executed after picking a video. This class dismisses itself automatically prior to calling this handler.
    public init(arcLTIURL: URL, videoPickedAction: @escaping (URL)->() = { _ in }) {
        self.webView = UIWebView(frame: .zero)
        self.arcLTIURL = arcLTIURL
        self.videoPickedAction = videoPickedAction
        super.init(nibName: nil, bundle: nil)
        
        webView.delegate = self
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
        
        // https://mobiledev.instructure.com/courses/24219/external_tools/282032/resource_selection?launch_type=homework_submission&assignment_id=405404
        APIBridge.shared().call("getAuthenticatedSessionURL", args: [arcLTIURL.absoluteString]) { [weak self] response, error in
            if let data = response as? [String: Any],
                let sessionURL = data["session_url"] as? String,
                let url = URL(string: sessionURL) {
                self?.webView.loadRequest(URLRequest(url: url))
            } else if let url = self?.arcLTIURL {
                self?.webView.loadRequest(URLRequest(url: url))
            }
        }
    }
    
    func close() {
        navigationController?.popViewController(animated: true)
    }
}

extension ArcVideoPickerViewController: UIWebViewDelegate {
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if request.url?.absoluteString.contains("success/external_tool_dialog") == true {
            // This is a poor mans way to parse a form body. It works though, and works well!
            // It uses a fake base url and then puts the form body as the query string.
            // URLComponents will then parse the query string correctly!
            if let data = request.httpBody,
                let dataString = String(data: data, encoding: String.Encoding.utf8) {
                let fakeBaseURL = "http://base.url?\(dataString)"
                let components = URLComponents(string: fakeBaseURL)
                let contentItems = components?.queryItems?.filter { $0.name == "content_items" }
                if let jsonData = contentItems?.first?.value?.data(using: .utf8),
                    let json = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? [String: Any],
                    let graph = json["@graph"] as? [[String: Any]],
                    let urlString = graph.first?["url"] as? String,
                    let url = URL(string: urlString) {
                    
                    self.close()
                    self.videoPickedAction(url)
                    return false
                }
            }
        }
        
        return true
    }
}
