//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

public class ArcVideoPickerViewController: UIViewController {
    
    @objc let arcLTIURL: URL
    @objc let videoPickedAction: (URL)->()
    
    // Reverting back to UIWebView because can actually get the request httpBody, WKWebView didn't work for that
    private let webView: UIWebView
    
    /// Initializer
    ///
    /// - parameter arcLTIURL:          The arc lti launch URL. See `Assignment`s function to create one.
    /// - parameter videoPickedAction:  The handler to be executed after picking a video. This class dismisses itself automatically prior to calling this handler.
    @objc public init(arcLTIURL: URL, videoPickedAction: @escaping (URL)->() = { _ in }) {
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

        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.pin(inside: view)
        
        // https://mobiledev.instructure.com/courses/24219/external_tools/282032/resource_selection?launch_type=homework_submission&assignment_id=405404
        let url = arcLTIURL
        AppEnvironment.shared.api.makeRequest(GetWebSessionRequest(to: url)) { [weak self] response, _, _ in
            DispatchQueue.main.async { self?.webView.loadRequest(URLRequest(url: response?.session_url ?? url)) }
        }
    }
    
    @objc func close() {
        navigationController?.popViewController(animated: true)
    }
}

extension ArcVideoPickerViewController: UIWebViewDelegate {
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        
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
