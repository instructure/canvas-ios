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
    func show(_ vc: UIViewController, sender: Any?)
}

class LoginWebPresenter {
    var mobileVerifyModel: APIVerifyClient?
    var authenticationProvider: String?
    var host = ""
    var session: URLSession = URLSession.shared
    weak var loginDelegate: LoginDelegate?
    var method = AuthenticationMethod.normalLogin
    var task: URLSessionTask?
    weak var view: LoginWebViewProtocol?

    init(authenticationProvider: String?, host: String, loginDelegate: LoginDelegate?, method: AuthenticationMethod, view: LoginWebViewProtocol) {
        self.authenticationProvider = authenticationProvider
        self.host = host
        self.loginDelegate = loginDelegate
        self.method = method
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

    func navigationActionPolicyForUrl(url: URL) -> WKNavigationActionPolicy {
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

        // I dunno why, but we have to wait for the code to be the first param cuz it can keep changing as we follow redirects
        //  "/canvas/login?code="
        if let code = codeFromQueryItems(queryItems), let mobileVerify = mobileVerifyModel, let baseURL = mobileVerify.base_url {
            task?.cancel()
            task = URLSessionAPI(urlSession: session).makeRequest(PostLoginOAuthRequest(client: mobileVerify, code: code)) { [weak self] (response, _, error) in
                if let model = response {
                    DispatchQueue.main.async {
                        self?.view?.show(LoadingViewController.create(), sender: nil)
                        self?.loginDelegate?.userDidLogin(keychainEntry: KeychainEntry(
                            accessToken: model.access_token,
                            baseURL: baseURL,
                            expiresAt: model.expires_in.flatMap { Date().addingTimeInterval($0) },
                            locale: model.user.effective_locale,
                            refreshToken: model.refresh_token,
                            userID: model.user.id.value,
                            userName: model.user.name,
                            userEmail: model.user.email
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

    private func codeFromQueryItems(_ queryItems: [URLQueryItem]?) -> String? {
        guard queryItems?.first?.name == "code", let value = queryItems?.first?.value, !value.isEmpty else { return nil }
        return value
    }
}
