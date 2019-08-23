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

import Foundation
import WebKit

enum AuthenticationMethod {
    case normalLogin
    case canvasLogin
    case siteAdminLogin
    case manualOAuthLogin
}

struct LoginParams {
    var host = ""
    var authenticationProvider: String?
    var method: AuthenticationMethod = .normalLogin
}

protocol LoginWebViewProtocol: ErrorViewController {
    func loadRequest(_ request: URLRequest)
    func evaluateJavaScript(_ script: String)
    func show(_ vc: UIViewController, sender: Any?)
}

class LoginWebPresenter {
    var mobileVerifyModel: APIVerifyClient?
    var authenticationProvider: String?
    var host = ""
    var session: URLSession = URLSessionAPI.defaultURLSession
    weak var loginDelegate: LoginDelegate?
    var method = AuthenticationMethod.normalLogin
    var task: URLSessionTask?
    weak var view: LoginWebViewProtocol?
    var mdmLogin: MDMLogin?

    init(
        authenticationProvider: String?,
        host: String,
        mdmLogin: MDMLogin? = nil,
        loginDelegate: LoginDelegate?,
        method: AuthenticationMethod,
        view: LoginWebViewProtocol
    ) {
        self.authenticationProvider = authenticationProvider
        self.host = host
        self.loginDelegate = loginDelegate
        self.method = method
        self.mdmLogin = mdmLogin
        self.view = view
    }

    deinit {
        task?.cancel()
    }

    func viewIsReady() {
        // Manual OAuth provided mobileVerifyModel
        if mobileVerifyModel != nil {
            loadLoginWebRequest()
            return
        }

        // Lookup OAuth from mobile verify
        task?.cancel()
        task = URLSessionAPI(urlSession: session).makeRequest(GetMobileVerifyRequest(domain: host)) { [weak self] (response, _, _) in
            self?.mobileVerifyModel = response
            self?.task = nil
            DispatchQueue.main.async { self?.loadLoginWebRequest() }
        }
    }

    func loadLoginWebRequest() {
        let params = LoginParams(host: host, authenticationProvider: authenticationProvider, method: method)
        if let verify = mobileVerifyModel, let url = verify.base_url, let clientID = verify.client_id {
            let requestable = LoginWebRequest(clientID: clientID, params: params)
            if let request = try? requestable.urlRequest(relativeTo: url, accessToken: nil, actAsUserID: nil) {
                view?.loadRequest(request)
            }
        }
    }

    func navigationActionPolicyForURL(url: URL) -> WKNavigationActionPolicy {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .allow
        }

        let queryItems = components.queryItems

        if components.host?.contains("community.canvaslms.com") == true {
            loginDelegate?.openExternalURL(url)
            return .cancel
        }

        if components.scheme == "about" && components.path == "blank" {
            return .cancel
        }

        if // wait for "https://canvas/login?code="
            url.absoluteString.hasPrefix("https://canvas/login"),
            let code = queryItems?.first(where: { $0.name == "code" })?.value, !code.isEmpty,
            let mobileVerify = mobileVerifyModel, let baseURL = mobileVerify.base_url {
            task?.cancel()
            task = URLSessionAPI(urlSession: session).makeRequest(PostLoginOAuthRequest(client: mobileVerify, code: code)) { [weak self] (response, _, error) in
                if let model = response {
                    DispatchQueue.main.async {
                        self?.view?.show(LoadingViewController.create(), sender: nil)
                        self?.loginDelegate?.userDidLogin(session: LoginSession(
                            accessToken: model.access_token,
                            baseURL: baseURL,
                            expiresAt: model.expires_in.flatMap { Date().addingTimeInterval($0) },
                            locale: model.user.effective_locale,
                            refreshToken: model.refresh_token,
                            userID: model.user.id.value,
                            userName: model.user.name,
                            userEmail: model.user.email,
                            clientID: mobileVerify.client_id,
                            clientSecret: mobileVerify.client_secret
                        ))
                    }
                }
                if let error = error {
                    DispatchQueue.main.async {
                        self?.view?.showError(error)
                    }
                }
            }

            return .cancel
        } else if queryItems?.first(where: { $0.name == "error" }) != nil {
            let error = NSError.instructureError(NSLocalizedString("Authentication failed. Most likely the user denied the request for access.", comment: ""))
            self.view?.showError(error)
            return .cancel
        }
        return .allow
    }

    func webViewFinishedLoading() {
        if let login = mdmLogin {
            self.mdmLogin = nil
            submitLogin(login)
        }
    }

    private func submitLogin(_ login: MDMLogin) {
        let js = """
        const form = document.querySelector('#login_form')
        form.querySelector('[type=email],[type=text]').value = \(CoreWebView.jsString(login.username))
        form.querySelector('[type=password]').value = \(CoreWebView.jsString(login.password))
        form.submit()
        """
        view?.evaluateJavaScript(js)
    }
}
