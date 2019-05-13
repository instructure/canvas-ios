//
// Copyright (C) 2018-present Instructure, Inc.
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

class LoginWebViewController: UIViewController, LoginWebViewProtocol {
    let webView = WKWebView(frame: UIScreen.main.bounds)

    var presenter: LoginWebPresenter?

    static func create(authenticationProvider: String? = nil, host: String, mdmLogin: MDMLogin? = nil, loginDelegate: LoginDelegate?, method: AuthenticationMethod) -> LoginWebViewController {
        let controller = LoginWebViewController()
        controller.title = host
        controller.presenter = LoginWebPresenter(
            authenticationProvider: authenticationProvider,
            host: host,
            mdmLogin: mdmLogin,
            loginDelegate: loginDelegate,
            method: method,
            view: controller
        )
        return controller
    }

    override func loadView() {
        webView.accessibilityIdentifier = "LoginWebPage.webView"
        webView.backgroundColor = .named(.backgroundLightest)
        webView.customUserAgent = UserAgent.safari.description
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func loadRequest(_ request: URLRequest) {
        webView.load(request)
    }

    func evaluateJavaScript(_ script: String) {
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
}

extension LoginWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            return decisionHandler(.allow)
        }

        let action = presenter?.navigationActionPolicyForURL(url: url) ?? .cancel
        decisionHandler(action)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        presenter?.webViewFinishedLoading()
    }
}

extension LoginWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame != true {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
