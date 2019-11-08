//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class LoginWebViewController: UIViewController, LoginWebViewProtocol {
    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        return WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
    }()

    var presenter: LoginWebPresenter?
    var env: AppEnvironment!

    static func create(env: AppEnvironment = .shared,
                       authenticationProvider: String? = nil,
                       host: String,
                       mdmLogin: MDMLogin? = nil,
                       loginDelegate: LoginDelegate?,
                       method: AuthenticationMethod) -> LoginWebViewController {
        let controller = LoginWebViewController()
        controller.env = env
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
        webView.accessibilityIdentifier = "LoginWeb.webView"
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

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard [NSURLAuthenticationMethodNTLM, NSURLAuthenticationMethodHTTPBasic].contains(challenge.protectionSpace.authenticationMethod) else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        DispatchQueue.main.async {
            let alert = UIAlertController(title: NSLocalizedString("Login", comment: ""), message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = NSLocalizedString("Username", comment: "")
            }
            alert.addTextField { textField in
                textField.placeholder = NSLocalizedString("Password", comment: "")
                textField.isSecureTextEntry = true
            }
            alert.addAction(AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
                completionHandler(.performDefaultHandling, nil)
            })
            alert.addAction(AlertAction(NSLocalizedString("OK", comment: ""), style: .default) { _ in
                if let username = alert.textFields?.first?.text, let password = alert.textFields?.last?.text {
                    let credential = URLCredential(user: username, password: password, persistence: .forSession)
                    completionHandler(.useCredential, credential)
                }
            })
            self.env.router.show(alert, from: self, options: [.modal])
        }
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
