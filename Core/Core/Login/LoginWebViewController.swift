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

enum AuthenticationMethod {
    case normalLogin
    case canvasLogin
    case siteAdminLogin
    case manualOAuthLogin
}

class LoginWebViewController: UIViewController, ErrorViewController {
    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        return WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
    }()

    var mobileVerifyModel: APIVerifyClient?
    var authenticationProvider: String?
    let env = AppEnvironment.shared
    var host = ""
    weak var loginDelegate: LoginDelegate?
    var method = AuthenticationMethod.normalLogin
    var task: URLSessionTask?
    var mdmLogin: MDMLogin?

    deinit {
        task?.cancel()
    }

    static func create(authenticationProvider: String? = nil, host: String, mdmLogin: MDMLogin? = nil, loginDelegate: LoginDelegate?, method: AuthenticationMethod) -> LoginWebViewController {
        let controller = LoginWebViewController()
        controller.title = host
        controller.authenticationProvider = authenticationProvider
        controller.host = host
        controller.mdmLogin = mdmLogin
        controller.loginDelegate = loginDelegate
        controller.method = method
        return controller
    }

    override func loadView() {
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.accessibilityIdentifier = "LoginWeb.webView"
        webView.backgroundColor = .named(.backgroundLightest)
        webView.customUserAgent = UserAgent.safari.description
        webView.navigationDelegate = self
        webView.uiDelegate = self

        // Manual OAuth provided mobileVerifyModel
        if mobileVerifyModel != nil {
            return loadLoginWebRequest()
        }

        // Lookup OAuth from mobile verify
        task?.cancel()
        task = URLSessionAPI().makeRequest(GetMobileVerifyRequest(domain: host)) { [weak self] (response, _, _) in performUIUpdate {
            self?.mobileVerifyModel = response
            self?.task = nil
            self?.loadLoginWebRequest()
        } }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func loadLoginWebRequest() {
        if let verify = mobileVerifyModel, let url = verify.base_url, let clientID = verify.client_id {
            let requestable = LoginWebRequest(authMethod: method, clientID: clientID, provider: authenticationProvider)
            if let request = try? requestable.urlRequest(relativeTo: url, accessToken: nil, actAsUserID: nil) {
                webView.load(request)
            }
        }
    }
}

extension LoginWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return decisionHandler(.allow)
        }

        if components.host?.contains("community.canvaslms.com") == true {
            loginDelegate?.openExternalURL(url)
            return decisionHandler(.cancel)
        }

        if components.scheme == "about" && components.path == "blank" {
            return decisionHandler(.cancel)
        }

        let queryItems = components.queryItems
        if // wait for "https://canvas/login?code="
            url.absoluteString.hasPrefix("https://canvas/login"),
            let code = queryItems?.first(where: { $0.name == "code" })?.value, !code.isEmpty,
            let mobileVerify = mobileVerifyModel, let baseURL = mobileVerify.base_url {
            task?.cancel()
            task = URLSessionAPI().makeRequest(PostLoginOAuthRequest(client: mobileVerify, code: code)) { [weak self] (response, _, error) in performUIUpdate {
                guard let self = self else { return }
                guard let token = response, error == nil else {
                    self.showError(error ?? NSError.internalError())
                    return
                }
                let session = LoginSession(
                    accessToken: token.access_token,
                    baseURL: baseURL,
                    expiresAt: token.expires_in.flatMap { Clock.now + $0 },
                    locale: token.user.effective_locale,
                    refreshToken: token.refresh_token,
                    userID: token.user.id.value,
                    userName: token.user.name,
                    clientID: mobileVerify.client_id,
                    clientSecret: mobileVerify.client_secret
                )
                self.env.router.show(LoadingViewController.create(), from: self)
                self.loginDelegate?.userDidLogin(session: session)
            } }
            return decisionHandler(.cancel)
        } else if queryItems?.first(where: { $0.name == "error" }) != nil {
            let error = NSError.instructureError(NSLocalizedString("Authentication failed. Most likely the user denied the request for access.", bundle: .core, comment: ""))
            self.showError(error)
            return decisionHandler(.cancel)
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let login = mdmLogin else { return }
        mdmLogin = nil
        webView.evaluateJavaScript("""
        const form = document.querySelector('#login_form')
        form.querySelector('[type=email],[type=text]').value = \(CoreWebView.jsString(login.username))
        form.querySelector('[type=password]').value = \(CoreWebView.jsString(login.password))
        form.submit()
        """)
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard [NSURLAuthenticationMethodNTLM, NSURLAuthenticationMethodHTTPBasic].contains(challenge.protectionSpace.authenticationMethod) else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        performUIUpdate {
            let alert = UIAlertController(title: NSLocalizedString("Login", bundle: .core, comment: ""), message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = NSLocalizedString("Username", bundle: .core, comment: "")
            }
            alert.addTextField { textField in
                textField.placeholder = NSLocalizedString("Password", bundle: .core, comment: "")
                textField.isSecureTextEntry = true
            }
            alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel) { _ in
                completionHandler(.performDefaultHandling, nil)
            })
            alert.addAction(AlertAction(NSLocalizedString("OK", bundle: .core, comment: ""), style: .default) { _ in
                if let username = alert.textFields?.first?.text, let password = alert.textFields?.last?.text {
                    let credential = URLCredential(user: username, password: password, persistence: .forSession)
                    completionHandler(.useCredential, credential)
                }
            })
            self.env.router.show(alert, from: self, options: .modal())
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
