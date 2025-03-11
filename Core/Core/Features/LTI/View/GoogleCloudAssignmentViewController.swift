//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@preconcurrency import WebKit

class GoogleCloudAssignmentViewController: UIViewController {
    let url: URL
    let webView: WKWebView
    let env = AppEnvironment.shared

    init(url: URL) {
        self.url = url
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: configuration)
        // Pretend to be desktop Safari so that we always get the full document editor
        webView.customUserAgent = UserAgent.desktopSafari.description
        super.init(nibName: nil, bundle: nil)
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: url))
    }

    override func loadView() {
        view = webView
    }
}

extension GoogleCloudAssignmentViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Google has the user authenticate in a separate window.
        let webView = WKWebView(frame: .zero, configuration: configuration)
        // This window does not allow faking the user agent
        webView.customUserAgent = UserAgent.safari.description
        webView.navigationDelegate = self
        webView.addScript("window.close = function() { location.href = 'canvas-core://window.close'; }")
        let controller = UIViewController()
        controller.view = webView
        env.router.show(controller, from: self, options: .modal(.formSheet, embedInNav: true, addDoneButton: true))
        return webView
    }
}

extension GoogleCloudAssignmentViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "canvas-core", url.host == "window.close" {
            presentedViewController?.dismiss(animated: true, completion: nil)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}
