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
import SwiftUI
import WebKit

public enum AuthenticationMethod {
    case normalLogin
    case canvasLogin
    case siteAdminLogin
    case manualOAuthLogin
}

public class LoginWebViewController: UIViewController, ErrorViewController {
    private enum FailureReason {
        case invalidDomain
        case timeout

        public var text: Text {
            switch self {
            case .invalidDomain:
                return Text("Go back and make sure you entered a valid institution name.")
            case .timeout:
                return Text("We received no response from the institution.\nGo back and make sure you entered a valid institution name.")
            }
        }
    }

    var mobileVerifyModel: APIVerifyClient?
    var mdmLogin: MDMLogin?
    var host = ""
    var authenticationProvider: String?
    var method = AuthenticationMethod.normalLogin
    var pairingCode: String?
    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        return WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
    }()

    private let progressView = UIProgressView()
    private let indeterminateLoadingIndicator = CircleProgressView()
    private let env = AppEnvironment.shared
    private weak var loginDelegate: LoginDelegate?
    private var task: APITask?
    private var canGoBackObservation: NSKeyValueObservation?
    private var loadObservation: NSKeyValueObservation?

    deinit {
        task?.cancel()
    }

    public static func create(
        authenticationProvider: String? = nil,
        host: String,
        mdmLogin: MDMLogin? = nil,
        loginDelegate: LoginDelegate?,
        method: AuthenticationMethod,
        pairingCode: String? = nil
    ) -> LoginWebViewController {
        let controller = LoginWebViewController()
        controller.title = host
        controller.authenticationProvider = authenticationProvider
        controller.host = host
        controller.mdmLogin = mdmLogin
        controller.loginDelegate = loginDelegate
        controller.method = method
        controller.pairingCode = pairingCode
        return controller
    }

    // MARK: - ViewController Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        setupNavigateBackInWebViewToolbar()
        setupWebView()
        setupProgressView()
        setupIndeterminateLoadingIndicator()

        // Manual OAuth provided mobileVerifyModel
        if mobileVerifyModel != nil {
            return loadLoginWebRequest()
        }

        // Lookup OAuth from mobile verify
        task?.cancel()
        task = API().makeRequest(GetMobileVerifyRequest(domain: host)) { [weak self] (response, _, _) in performUIUpdate {
            self?.mobileVerifyModel = response
            self?.task = nil
            self?.loadLoginWebRequest()
        } }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(!webView.canGoBack, animated: true)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }

    // MARK: - Private Methods

    private func setupWebView() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        webView.accessibilityIdentifier = "LoginWeb.webView"
        webView.backgroundColor = .backgroundLightest
        webView.customUserAgent = UserAgent.safari.description
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.handle("selfRegistrationError") { [weak self] _ in performUIUpdate {
            self?.showAlert(
                title: NSLocalizedString("Self Registration Not Allowed", comment: ""),
                message: NSLocalizedString("Contact your school to create an account.", comment: "")
            )
        } }
    }

    private func setupIndeterminateLoadingIndicator() {
        indeterminateLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indeterminateLoadingIndicator)
        indeterminateLoadingIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        indeterminateLoadingIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        indeterminateLoadingIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        indeterminateLoadingIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        indeterminateLoadingIndicator.startAnimating()
    }

    private func hideIndeterminateLoadingIndicator() {
        UIView.animate(withDuration: 0.3) { [indeterminateLoadingIndicator] in
            indeterminateLoadingIndicator.alpha = 0
        } completion: { [indeterminateLoadingIndicator] _ in
            indeterminateLoadingIndicator.stopAnimating()
        }
    }

    private func setupNavigateBackInWebViewToolbar() {
        let goBack = UIBarButtonItem(image: .arrowOpenLeftSolid, style: .plain, target: webView, action: #selector(WKWebView.goBack))
        toolbarItems = [goBack]
        navigationController?.setToolbarHidden(true, animated: false)
        canGoBackObservation = webView.observe(\.canGoBack) { [weak self] webView, _ in
            self?.navigationController?.setToolbarHidden(!webView.canGoBack, animated: true)
        }
    }

    private func setupProgressView() {
        view.addSubview(progressView)
        progressView.pin(inside: view, leading: 0, trailing: 0, top: nil, bottom: nil)
        progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        progressView.progress = 0
        progressView.progressTintColor = Brand.shared.primary
        loadObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] webView, _ in
            guard let progressView = self?.progressView else { return }
            let newValue = Float(webView.estimatedProgress)
            progressView.setProgress(newValue, animated: newValue >= progressView.progress)
            guard newValue >= 1 else { return }
            UIView.animate(withDuration: 0.3, animations: {
                progressView.alpha = 0
            }, completion: { _ in
                progressView.isHidden = true
            })
        }
    }

    private func loadLoginWebRequest() {
        guard let verify = mobileVerifyModel, let url = verify.base_url, let clientID = verify.client_id else {
            showFailedPanda(reason: .invalidDomain)
            return
        }

        let requestable = LoginWebRequest(authMethod: method, clientID: clientID, provider: authenticationProvider)
        if var request = try? requestable.urlRequest(relativeTo: url, accessToken: nil, actAsUserID: nil) {
            request.timeoutInterval = 30
            webView.load(request)
        }
    }

    private func showSelfRegistration(pairingCode: String) {
        webView.evaluateJavaScript("""
        function showSelfRegistration() {
            var meta = document.createElement('meta')
            meta.name = 'viewport'
            meta.content = 'initial-scale=1, minimum-scale=1, maximum-scale=1, user-scalable=no'
            var head = document.querySelector('head')
            head.appendChild(meta)

            let registerLink = document.querySelector('a#register_link')
            if (registerLink) {
                registerLink.click()
                return
            }
            let enrollLink = document.querySelector('a[data-template="newParentDialog"]') || document.querySelector('#coenrollment_link a') || document.querySelector('a#signup_parent')
            if (!enrollLink) {
                window.webkit.messageHandlers.selfRegistrationError.postMessage('')
                return
            }
            enrollLink.click()
            document.querySelector('input#pairing_code').value = \(CoreWebView.jsString(pairingCode))
            document.querySelector('.ui-dialog-titlebar-close').style.display = 'none'
            document.querySelector('.ui-dialog-buttonpane button.dialog_closer').style.display = 'none'
            let content = document.querySelector('.ui-dialog-content')
            let height = `${parseInt(content.style.height) - \(view.frame.origin.y)}px`
            content.style.height = height
            document.querySelector('.ui-widget-overlay').style.height = height
        }
        showSelfRegistration()
        """)
    }

    private func showFailedPanda(reason: FailureReason) {
        let panda = InteractivePanda(scene: NoResultsPanda(),
                                     title: Text("Failed to Load Login Page"),
                                     subtitle: reason.text)
        let hostVC = CoreHostingController(panda)
        addChild(hostVC)
        view.addSubview(hostVC.view)
        hostVC.view.pin(inside: view)

        hostVC.view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            hostVC.view.alpha = 1
        }
    }
}

// MARK: - WKNavigationDelegate

extension LoginWebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return decisionHandler(.allow)
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
            task = API().makeRequest(PostLoginOAuthRequest(client: mobileVerify, code: code)) { [weak self] (response, _, error) in performUIUpdate {
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
        } else if queryItems?.first(where: { $0.name == "error" })?.value == "access_denied" {
            // access_denied is the only currently implemented error code
            // https://canvas.instructure.com/doc/api/file.oauth.html#oauth2-flow-2
            let error = NSError.instructureError(NSLocalizedString("Authentication failed. Most likely the user denied the request for access.", bundle: .core, comment: ""))
            self.showError(error)
            return decisionHandler(.cancel)
        }
        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.alpha = 1
        progressView.isHidden = false
    }

    /** A navigation inside the main frame failed. */
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // In case we cancel a navigation we receive a "Frame load interrupted" error, we can ignore that.
        if error.isFrameLoadInterrupted {
            return
        }

        let nsError = error as NSError
        let reason: FailureReason = nsError.code == NSURLErrorTimedOut ? .timeout : .invalidDomain
        showFailedPanda(reason: reason)
        hideIndeterminateLoadingIndicator()
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideIndeterminateLoadingIndicator()

        if let login = mdmLogin {
            mdmLogin = nil
            webView.evaluateJavaScript("""
            const form = document.querySelector('#login_form')
            form.querySelector('[type=email],[type=text]').value = \(CoreWebView.jsString(login.username))
            form.querySelector('[type=password]').value = \(CoreWebView.jsString(login.password))
            form.submit()
            """)
        } else if let pairingCode = pairingCode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showSelfRegistration(pairingCode: pairingCode)
            }
        }
    }

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
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

// MARK: - WKUIDelegate

extension LoginWebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame != true {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
